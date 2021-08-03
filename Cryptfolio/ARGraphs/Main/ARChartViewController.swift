//
//  ViewController.swift
//  ARCharts
//
//  Created by Bobo on 7/5/17.
//  Copyright © 2017 Boris Emorine. All rights reserved.
//

import ARCharts
import ARKit
import SceneKit
import UIKit
import SideMenu

public class ARSettings {
    
    public static let shared = ARSettings();
    
    // global boolean whether or not chart is default green or red
    public var isGreen:Bool = false;
    
    // Lighting settings
    public var lightingTypeSettings:SCNLight.LightType = .spot;
    public var intensitySetting:CGFloat = 2500.0;
    public var temperatureSetting:CGFloat = 6500.0;
    
    // Color settings
    public var adjustedColor:Bool = false;
    public var brightnessPrecentage:CGFloat = 100.0;
    public var redValue:CGFloat = 0.0;
    public var greenValue:CGFloat = 0.0;
    public var blueValue:CGFloat = 0.0;
    
    private init() {}
    
    public func resetAllSettings() -> Void {
        ARSettings.shared.lightingTypeSettings = .spot;
        ARSettings.shared.intensitySetting = 2500.0;
        ARSettings.shared.temperatureSetting = 6500.0
        ARSettings.shared.adjustedColor = false;
        ARSettings.shared.brightnessPrecentage = 100.0;
        ARSettings.shared.redValue = 0.0;
        ARSettings.shared.greenValue = 0.0;
        ARSettings.shared.blueValue = 0.0;
    }
    
    public func resetLightingSettings() -> Void {
        ARSettings.shared.lightingTypeSettings = .spot;
        ARSettings.shared.intensitySetting = 2500.0;
        ARSettings.shared.temperatureSetting = 6500.0;
    }
    
    public func resetColorSettings() -> Void {
        ARSettings.shared.adjustedColor = false;
        ARSettings.shared.brightnessPrecentage = 100;
        ARSettings.shared.redValue = ARSettings.shared.isGreen ? 0.0 : 255.0 / 2.0;
        ARSettings.shared.greenValue = ARSettings.shared.isGreen ? 255.0 / 2.0 : 0.0;
        ARSettings.shared.blueValue = 0.0;
    }
    
}

class ARChartViewController: UIViewController, ARSCNViewDelegate, SideMenuNavigationControllerDelegate, UINavigationControllerDelegate {
    
    override var prefersStatusBarHidden: Bool { return true; }
    
    private var sideMenu : SideMenuNavigationController?
    
    let sceneView : ARSCNView = {
        let sceneView = ARSCNView();
        sceneView.translatesAutoresizingMaskIntoConstraints = false;
        return sceneView;
    }();
    
    let chartButton : UIButton = {
        let button = UIButton();
        button.setTitle("Add Chart", for: .normal)
        button.setTitleColor(.white, for: .normal);
        button.backgroundColor = .mainBackgroundColor;
        button.layer.borderWidth = 1.0;
        button.layer.borderColor = UIColor.orange.cgColor;
        button.layer.cornerRadius = 5.0;
        button.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor;
        button.layer.shadowOffset = CGSize(width: 0.0, height: 2.0);
        button.layer.shadowOpacity = 1.0;
        button.layer.shadowRadius = 5.0;
        button.translatesAutoresizingMaskIntoConstraints = false;
        return button;
    }();
    
    public var dataPoints:Array<Array<Double>>!;
    public var coin:Coin!;
    
    var barChart: ARBarChart? {
        didSet {
            chartButton.setTitle(barChart == nil ? "Add Chart" : "Remove Chart", for: .normal)
        }
    }
    
    var session: ARSession {
        return sceneView.session
    }
    
    var screenCenter: CGPoint?
    var dataSeries: ARDataSeries?
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let first = self.dataPoints.first, let last = self.dataPoints.last {
            if (!first[0].isLess(than: last[0])) {
                ARSettings.shared.isGreen = false;
                ARSettings.shared.redValue = 255.0 / 2.0;
            } else {
                ARSettings.shared.isGreen = true;
                ARSettings.shared.greenValue = 255.0 / 2.0;
            }
        }
        
        self.setupSideMenu();
        self.setupConstraints();
        self.chartButton.addTarget(self, action: #selector(self.handleTapChartButton(_:)), for: .touchUpInside);
        
        sceneView.delegate = self
        sceneView.scene = SCNScene()
        sceneView.showsStatistics = false
        sceneView.antialiasingMode = .multisampling4X
        sceneView.automaticallyUpdatesLighting = true
        sceneView.contentScaleFactor = 1.0
        sceneView.preferredFramesPerSecond = 60
        DispatchQueue.main.async {
            self.screenCenter = self.sceneView.bounds.mid
        }
        
        if let camera = sceneView.pointOfView?.camera {
            camera.wantsHDR = true
            camera.wantsExposureAdaptation = true
            camera.exposureOffset = -1
            camera.minimumExposure = -1
        }
        
        chartButton.layer.cornerRadius = 5.0
        chartButton.clipsToBounds = true
        
        setupFocusSquare()
        setupRotationGesture();
        setupTranslationGesture();
        setupPinchScaleGesture();
        setupHighlightGesture();
        
        addLightSource(ofType: ARSettings.shared.lightingTypeSettings, intensity: ARSettings.shared.intensitySetting, temperature: ARSettings.shared.temperatureSetting);
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.configuration?.isLightEstimationEnabled = true
        sceneView.session.run(configuration)
        sceneView.delegate = self
        
        screenCenter = self.sceneView.bounds.mid
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        ARSettings.shared.resetAllSettings();
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - ANDRE METHODS
    
    func sideMenuDidAppear(menu: SideMenuNavigationController, animated: Bool) {
        self.removeBarChart();
        self.chartButton.isUserInteractionEnabled = false;
    }
    
    func sideMenuDidDisappear(menu: SideMenuNavigationController, animated: Bool) {
        self.chartButton.isUserInteractionEnabled = true;
        addLightSource(ofType: ARSettings.shared.lightingTypeSettings, intensity: ARSettings.shared.intensitySetting, temperature: ARSettings.shared.temperatureSetting);
    }
    
    private func setupSideMenu() -> Void {
        self.sideMenu = SideMenuNavigationController(rootViewController: ARSettingsVC());
        self.sideMenu?.delegate = self;
        self.sideMenu?.setNavigationBarHidden(true, animated: false);
        self.sideMenu?.menuWidth = self.view.frame.width * 0.8;
        self.sideMenu?.enableSwipeToDismissGesture = false;
        SideMenuManager.default.rightMenuNavigationController = self.sideMenu;
        
        // right bar item
        let settingsButton = UIButton();
        settingsButton.frame = CGRect(x: 0, y: 0, width: 45, height: 50);
        settingsButton.setImage(UIImage(named: "settings")?.withRenderingMode(.alwaysTemplate), for: .normal);
        settingsButton.tintColor = .white
        settingsButton.backgroundColor = .mainBackgroundColor;
        settingsButton.layer.borderWidth = 1.0;
        settingsButton.layer.borderColor = UIColor.orange.cgColor;
        settingsButton.layer.cornerRadius = settingsButton.bounds.size.width / 2;
        settingsButton.layer.masksToBounds = true;
        settingsButton.clipsToBounds = true;
        settingsButton.addTarget(self, action: #selector(self.openSettings), for: .touchUpInside);
        let rightBarButton = UIBarButtonItem(customView: settingsButton);
        self.navigationItem.rightBarButtonItem = rightBarButton;
        
        // left bar item
        self.navigationItem.backBarButtonItem = nil;
        let exitButton = UIButton();
        exitButton.frame = CGRect(x: 0, y: 0, width: 45, height: 50);
        exitButton.setImage(UIImage(named: "exit")?.withRenderingMode(.alwaysTemplate), for: .normal);
        exitButton.tintColor = .white
        exitButton.backgroundColor = .mainBackgroundColor;
        exitButton.layer.borderWidth = 1.0;
        exitButton.layer.borderColor = UIColor.orange.cgColor;
        exitButton.layer.cornerRadius = exitButton.bounds.size.width / 2;
        exitButton.layer.masksToBounds = true;
        exitButton.clipsToBounds = true;
        exitButton.addTarget(self, action: #selector(self.exitButtonTapped), for: .touchUpInside);
        let leftBarButton = UIBarButtonItem(customView: exitButton);
        self.navigationItem.leftBarButtonItem = leftBarButton;
        
    }
    
    @objc private func openSettings() -> Void {
        if let sideMenu = self.sideMenu {
            self.present(sideMenu, animated: true, completion: nil);
        }
    }
    
    @objc private func exitButtonTapped() -> Void {
        self.navigationController?.popViewController(animated: true);
    }
    
    private func setupConstraints() -> Void {
        self.view.addSubview(self.sceneView);
        self.view.addSubview(self.chartButton);
        
        // constraiints for sceneView
        self.sceneView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true;
        self.sceneView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true;
        self.sceneView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true;
        self.sceneView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true;
        
        // constraints for chartView
        self.chartButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -15.0).isActive = true;
        self.chartButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true;
        self.chartButton.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.8).isActive = true;
        self.chartButton.heightAnchor.constraint(equalToConstant: 60.0).isActive = true;
        
    }
        
    private func getMaxMin() -> (Double, Double) {
        var max:Double = Double.leastNormalMagnitude;
        var min:Double = Double.greatestFiniteMagnitude;
        for col in self.dataPoints {
            for val in col {
                if (val > max) {
                    max = val;
                }
                if (val < min) {
                    min = val;
                }
            }
        }
        return (max, min);
    }
    
    private func scaledPrices(divider:Int) -> [[Double]] {
        var values:[[Double]] = [];
        let (max, min) = self.getMaxMin();
        let delta:Double = (max - (0.999 * min));
        for i in 0..<self.dataPoints.count {
            if (i % divider == 0) {
                for j in 0..<self.dataPoints[i].count {
                    let a = ((max - self.dataPoints[i][j]) / delta);
                    var b = (1 - a) * max;
                    if (b == 0) { b = max; }
                    values.append([b]);
                }
            }
        }
        return values;
    }

    private func getColors() -> Array<UIColor> {
        var colors:Array<UIColor> = Array<UIColor>();
        if (ARSettings.shared.adjustedColor) {
            if let first = self.dataPoints.first, let last = self.dataPoints.last {
                if (!first[0].isLess(than: last[0])) {
                    var color = UIColor(red: ARSettings.shared.redValue/255.0, green: ARSettings.shared.greenValue/255.0, blue: ARSettings.shared.blueValue/255.0, alpha: 1.0);
                    color = color.adjust(by: ARSettings.shared.brightnessPrecentage);
                    colors = [color];
                } else {
                    var color = UIColor(red: ARSettings.shared.redValue/255.0, green: ARSettings.shared.greenValue/255.0, blue: ARSettings.shared.blueValue/255.0, alpha: 1.0);
                    color = color.adjust(by: CGFloat(ARSettings.shared.brightnessPrecentage));
                    colors = [color];
                }
            }
        } else {
            if let first = self.dataPoints.first, let last = self.dataPoints.last {
                if (!first[0].isLess(than: last[0])) {
                    var color = UIColor(red: 100/255.0, green: 0.0, blue: 0.0, alpha: 1.0)
                    color = color.adjust(by: ARSettings.shared.brightnessPrecentage);
                    colors = [color];
                } else {
                    var color = UIColor(red: 0.0, green: 100.0/255.0, blue: 0.0, alpha: 1.0)
                    color = color.adjust(by: ARSettings.shared.brightnessPrecentage);
                    colors = [color];
                }
            }
        }
        return colors;
    }
    
    private func getSeriesLabels(values:[[Double]]) -> Array<String> {
        var label:Array<String> = Array<String>();
        for i in 0..<values.count {
            for val in values[i] {
                if (i == 0) {
                    label.append("START");
                } else if (i == values.count / 2) {
                    label.append("MID")
                } else if (i == values.count - 1) {
                    label.append("END");
                } else {
                    label.append("\(String(format: "%.2f", val))");
                }
            }
        }
        return label;
    }
    
    private func removeBarChart() -> Void {
        if (self.barChart != nil) {
            self.barChart?.removeFromParentNode()
            self.barChart = nil
        }
    }
    
    // MARK: - ANDRE METHODS (END)
    
    
    // MARK - Setups
    
    var focusSquare = FocusSquare()
    
    func setupFocusSquare() {
        focusSquare.isHidden = true
        focusSquare.removeFromParentNode()
        sceneView.scene.rootNode.addChildNode(focusSquare)
    }
    
    private func addBarChart(at position: SCNVector3) {
        if barChart != nil {
            barChart?.removeFromParentNode()
            barChart = nil
        }
        
        let _ = Int(self.dataPoints.count / 100);
                
        let values = self.scaledPrices(divider: 5);
        let colors = self.getColors();
        let labels = self.getSeriesLabels(values: values);
        
        dataSeries = ARDataSeries(withValues: values);
        dataSeries?.spaceForIndexLabels = 0.2
        dataSeries?.spaceForIndexLabels = 0.2
        dataSeries?.barColors = colors;
        dataSeries?.barOpacity = 1;
        
        dataSeries?.seriesLabels = labels;
        
        
        barChart = ARBarChart()
        if let barChart = barChart {
            barChart.dataSource = dataSeries
            barChart.delegate = dataSeries
            barChart.animationType = ARChartPresenter.AnimationType.grow;
            barChart.size = SCNVector3(0.08, 0.25, 0.5);  // 0.08, 0.25, 0.5
            barChart.position = position
            barChart.draw()
            sceneView.scene.rootNode.addChildNode(barChart)
            
            let sphere = self.addSphere(contents: UIImage(named: "Images/\(self.coin.ticker.symbol.lowercased()).png"), position: SCNVector3(0, 0.30, 0));
            sphere.scale = SCNVector3(sphere.scale.x, sphere.scale.y, sphere.scale.z / 2);
            barChart.addChildNode(sphere);
            
            let priceText = self.add3dText(message: CryptoData.convertToDollar(price: self.coin!.ticker.price, hasSymbol: true), position: SCNVector3(-0.035, -0.040, 0));
            sphere.addChildNode(priceText);
            
            barChart.eulerAngles = SCNVector3(0, Double.pi/2, 0);
            sphere.eulerAngles = SCNVector3(0, -Double.pi/2, 0);
            
        }
    }
    
    private func add3dText(message:String, position: SCNVector3) -> SCNNode {
        let text = SCNText(string: message, extrusionDepth: 1);
        let material = SCNMaterial();
        material.diffuse.contents = UIColor.orange;
        text.materials = [material];
        let textNode = SCNNode();
        textNode.position = position;
        textNode.scale = SCNVector3(0.0012, 0.0012, 0.0012);
        textNode.geometry = text;
        return textNode;
    }
    
    private func addSphere(contents:Any?, position: SCNVector3) -> SCNNode {
        let sphereGeometry = SCNSphere(radius: 0.015)
        let material = SCNMaterial();
        material.diffuse.contents = contents;
        sphereGeometry.materials = [material];
        let sphereNode = SCNNode(geometry: sphereGeometry)
        sphereNode.position = position;
        return sphereNode;
    }
    
    private func addLightSource(ofType type: SCNLight.LightType, intensity:CGFloat, temperature:CGFloat, at position: SCNVector3? = nil) {
        let light = SCNLight()
        light.color = UIColor.white
        light.type = type
        light.intensity = intensity // Default SCNLight intensity is 1000
        light.temperature = temperature; // Default SCNLight temperature is 6500
        
        let lightNode = SCNNode()
        lightNode.light = light
        if let lightPosition = position {
            // Fix the light source in one location
            lightNode.position = lightPosition
            self.sceneView.scene.rootNode.addChildNode(lightNode)
        } else {
            // Make the light source follow the camera position
            self.sceneView.pointOfView?.enumerateChildNodes({ (node, stop) in node.removeFromParentNode(); });
            self.sceneView.pointOfView?.addChildNode(lightNode)
        }
    }
    
    private func setupRotationGesture() {
        let rotationGestureRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(handleRotation))
        self.view.addGestureRecognizer(rotationGestureRecognizer)
    }
    
    private func setupTranslationGesture() -> Void {
        let translationGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handleTranslation(_:)));
        self.view.addGestureRecognizer(translationGesture);
    }
    
    private func setupPinchScaleGesture() -> Void {
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)));
        self.view.addGestureRecognizer(pinchGesture);
    }
    
    private func setupHighlightGesture() {
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        self.view.addGestureRecognizer(longPressRecognizer)
    }
    
    // MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async {
            self.updateFocusSquare()
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // TODO: Present an error message to the user
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // TODO: Inform the user that the session has been interrupted, for example, by presenting an overlay
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // TODO: Reset tracking and/or remove existing anchors if consistent tracking is required
    }
    
    // MARK: - Actions
    
    @objc private func handleTapChartButton(_ sender: UIButton) {
        guard let lastPosition = focusSquare.lastPosition else {
            return
        }
        if self.barChart != nil {
            self.barChart?.removeFromParentNode()
            self.barChart = nil
        } else {
            self.addBarChart(at: lastPosition)
        }
    }
    
    private var startingRotation: Float = 0.0
    private var startingVectorScale: SCNVector3 = SCNVector3();
    private var startingTranslation: SCNVector3 = SCNVector3();
    
    @objc func handleRotation(rotationGestureRecognizer: UIRotationGestureRecognizer) {
        guard let barChart = barChart,
            let pointOfView = sceneView.pointOfView,
            sceneView.isNode(barChart, insideFrustumOf: pointOfView) == true else {
            return
        }
        
        if rotationGestureRecognizer.state == .began {
            startingRotation = barChart.eulerAngles.y
        } else if rotationGestureRecognizer.state == .changed {
            self.barChart?.eulerAngles.y = startingRotation - Float(rotationGestureRecognizer.rotation)
        }
    }
    
    @objc func handleTranslation(_ gesture: UIPanGestureRecognizer) {
        guard let barChart = self.barChart, let pointOfView = self.sceneView.pointOfView, self.sceneView.isNode(barChart, insideFrustumOf: pointOfView) else { return; }
        if (gesture.state == .began) {
            startingTranslation = barChart.position;
        } else if (gesture.state == .changed) {
            let translation = gesture.translation(in: self.view);
            barChart.position = SCNVector3(startingTranslation.x + (Float(translation.x) * 0.001), startingTranslation.y, startingTranslation.z + (Float(translation.y) * 0.001));
        }
    }

    
    @objc func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        guard let barChart = self.barChart, let pointOfView = self.sceneView.pointOfView, self.sceneView.isNode(barChart, insideFrustumOf: pointOfView) else { return; }
        if (gesture.state == .began) {
            self.startingVectorScale = barChart.scale;
        } else if (gesture.state == .changed) {
            let scale = Float(gesture.scale);
            barChart.scale = SCNVector3(self.startingVectorScale.x * scale, self.startingVectorScale.y * scale, self.startingVectorScale.z * scale);
        }
    }
    
    @objc func handleLongPress(_ gestureRecognizer: UITapGestureRecognizer) {
        guard gestureRecognizer.state == .began else { return }
        var labelToHighlight: ARChartLabel?
        
        let animationStyle = ARChartHighlighter.AnimationStyle.shrink;
        let animationDuration = 0.3
        let longPressLocation = gestureRecognizer.location(in: self.view)
        let selectedNode = self.sceneView.hitTest(longPressLocation, options: nil).first?.node
        if let barNode = selectedNode as? ARBarChartBar {
            barChart?.highlightBar(atIndex: barNode.index, forSeries: barNode.series, withAnimationStyle: animationStyle, withAnimationDuration: animationDuration)
        } else if let labelNode = selectedNode as? ARChartLabel {
            // Detect long press on label text
            labelToHighlight = labelNode
        } else if let labelNode = selectedNode?.parent as? ARChartLabel {
            // Detect long press on label background
            labelToHighlight = labelNode
        }
        
        if let labelNode = labelToHighlight {
            switch labelNode.type {
            case .index:
                barChart?.highlightIndex(labelNode.id, withAnimationStyle: animationStyle, withAnimationDuration: animationDuration)
            case .series:
                barChart?.highlightSeries(labelNode.id, withAnimationStyle: animationStyle, withAnimationDuration: animationDuration)
            }
        }
        
        let tapToUnhighlight = UITapGestureRecognizer(target: self, action: #selector(handleTapToUnhighlight(_:)))
        self.view.addGestureRecognizer(tapToUnhighlight)
    }
    
    @objc func handleTapToUnhighlight(_ gestureRecognizer: UITapGestureRecognizer) {
        barChart?.unhighlight()
        self.view.removeGestureRecognizer(gestureRecognizer)
    }
    
    // MARK: - Helper Functions
    
    func updateFocusSquare() {
        guard let screenCenter = screenCenter else {
            return
        }
        
        if barChart != nil {
            focusSquare.isHidden = true
            focusSquare.hide()
        } else {
            focusSquare.isHidden = false
            focusSquare.unhide()
        }
        
        let (worldPos, planeAnchor, _) = worldPositionFromScreenPosition(screenCenter, objectPos: focusSquare.position)
        if let worldPos = worldPos {
            focusSquare.update(for: worldPos, planeAnchor: planeAnchor, camera: self.session.currentFrame?.camera)
        }
    }
    
    var dragOnInfinitePlanesEnabled = false
    
    func worldPositionFromScreenPosition(_ position: CGPoint,
                                         objectPos: SCNVector3?,
                                         infinitePlane: Bool = false) -> (position: SCNVector3?, planeAnchor: ARPlaneAnchor?, hitAPlane: Bool) {
        
        let planeHitTestResults = sceneView.hitTest(position, types: .existingPlaneUsingExtent)
        if let result = planeHitTestResults.first {
            
            let planeHitTestPosition = SCNVector3.positionFromTransform(result.worldTransform)
            let planeAnchor = result.anchor
            
            return (planeHitTestPosition, planeAnchor as? ARPlaneAnchor, true)
        }
        
        var featureHitTestPosition: SCNVector3?
        var highQualityFeatureHitTestResult = false
        
        let highQualityfeatureHitTestResults = sceneView.hitTestWithFeatures(position, coneOpeningAngleInDegrees: 18, minDistance: 0.2, maxDistance: 2.0)
        
        if !highQualityfeatureHitTestResults.isEmpty {
            let result = highQualityfeatureHitTestResults[0]
            featureHitTestPosition = result.position
            highQualityFeatureHitTestResult = true
        }
        
        if (infinitePlane && dragOnInfinitePlanesEnabled) || !highQualityFeatureHitTestResult {
            
            let pointOnPlane = objectPos ?? SCNVector3Zero
            
            let pointOnInfinitePlane = sceneView.hitTestWithInfiniteHorizontalPlane(position, pointOnPlane)
            if pointOnInfinitePlane != nil {
                return (pointOnInfinitePlane, nil, true)
            }
        }
        
        if highQualityFeatureHitTestResult {
            return (featureHitTestPosition, nil, false)
        }
        
        let unfilteredFeatureHitTestResults = sceneView.hitTestWithFeatures(position)
        if !unfilteredFeatureHitTestResults.isEmpty {
            let result = unfilteredFeatureHitTestResults[0]
            return (result.position, nil, false)
        }
        
        return (nil, nil, false)
    }
    
}
