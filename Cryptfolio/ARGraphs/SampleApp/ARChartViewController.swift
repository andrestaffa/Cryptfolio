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

class ARChartViewController: UIViewController, ARSCNViewDelegate {
    
    let chartButton : UIButton = {
        let button = UIButton();
        button.setTitle("Add Chart", for: .normal)
        button.setTitleColor(.white, for: .normal);
        button.backgroundColor = .orange
        button.layer.cornerRadius = 5.0;
        button.layer.cornerRadius = 3.0;
        button.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor;
        button.layer.shadowOffset = CGSize(width: 0.0, height: 2.0);
        button.layer.shadowOpacity = 1.0;
        button.layer.shadowRadius = 5.0;
        button.translatesAutoresizingMaskIntoConstraints = false;
        return button;
    }();
    
    let sceneView : ARSCNView = {
        let sceneView = ARSCNView();
        sceneView.translatesAutoresizingMaskIntoConstraints = false;
        return sceneView;
    }();
    
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
    var prices:[[Double]] = [];
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // BTC: Qwsogvtv82FCd
        // ETH: razxDUgYGNAdQ
        // USDT: HIVsRcGKkPFtW
        // DOGE: a91GCGd_u96cF
        self.getCoinHistory(id: "Qwsogvtv82FCd", timeFrame: "24h") { (history, error) in
            if let error = error { print(error.localizedDescription); return; }
            if let history = history {
                for v in history {
                    self.prices.append([v]);
                }
            }
        }
        
        self.setupConstraints();
        self.chartButton.addTarget(self, action: #selector(self.handleTapChartButton(_:)), for: .touchUpInside);
        
        sceneView.delegate = self
        sceneView.scene = SCNScene()
        sceneView.showsStatistics = false
        sceneView.antialiasingMode = .multisampling4X
        sceneView.automaticallyUpdatesLighting = false
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
        setupRotationGesture()
        setupPinchScaleGesture();
        setupHighlightGesture()

        addLightSource(ofType: .spot);
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
        
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - ANDRE METHODS
    
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
    
    private func getCoinHistory(id: String, timeFrame:String, completion:@escaping ([Double]?, Error?) -> Void) -> Void {
        if let url = URL(string: "https://api.coinranking.com/v2/coin/\(id)/history?timePeriod=\(timeFrame)") {
            var request = URLRequest(url: url);
            request.httpMethod = "GET";
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let error = error { completion(nil, error); }
                if let data = data {
                    if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? Dictionary<String, Any> {
                        if let d = json["data"] as? Dictionary<String, Any> {
                            let historys = d["history"] as! [[String: Any]];
                            var prices = [Double]();
                            for i in 0...historys.count - 1 {
                                let price = historys[i]["price"] as? String;
                                let priceDouble = Double(price ?? "0.0");
                                prices.append(priceDouble!);
                            }
                            DispatchQueue.main.async { completion(prices, nil); }
                        } else {
                            DispatchQueue.main.async { completion(nil, nil); }
                        }
                    } else {
                        DispatchQueue.main.async { completion(nil, nil); }
                    }
                } else {
                    DispatchQueue.main.async { completion(nil, nil); }
                }
            }.resume();
        } else {
            DispatchQueue.main.async { completion(nil, nil); }
        }
    }
    
    private func getMaxMin() -> (Double, Double) {
        var max:Double = Double.leastNormalMagnitude;
        var min:Double = Double.greatestFiniteMagnitude;
        for col in self.prices {
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
        for i in 0..<self.prices.count {
            if (i % divider == 0) {
                for j in 0..<self.prices[i].count {
                    let a = ((max - self.prices[i][j]) / delta);
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
        if let first = self.prices.first, let last = self.prices.last {
            if (!first[0].isLess(than: last[0])) {
                colors = [
                    UIColor(red: 100.0/255.0, green: 0, blue: 0, alpha: 1.0),
                    UIColor(red: 100.0/255.0, green: 0, blue: 0, alpha: 1.0),
                    UIColor(red: 110.0/255.0, green: 0, blue: 0, alpha: 1.0),
                    UIColor(red: 100.0/255.0, green: 0, blue: 0, alpha: 1.0),
                    UIColor(red: 110.0/255.0, green: 0, blue: 0, alpha: 1.0),
                    UIColor(red: 110.0/255.0, green: 0, blue: 0, alpha: 1.0),
                    UIColor(red: 100.0/255.0, green: 0, blue: 0, alpha: 1.0)
                ]
            } else {
                colors = [
                    UIColor(red: 0, green: 100.0/255.0, blue: 0, alpha: 1.0),
                    UIColor(red: 0, green: 100.0/255.0, blue: 0, alpha: 1.0),
                    UIColor(red: 0, green: 110.0/255.0, blue: 0, alpha: 1.0),
                    UIColor(red: 0, green: 100.0/255.0, blue: 0, alpha: 1.0),
                    UIColor(red: 0, green: 110.0/255.0, blue: 0, alpha: 1.0),
                    UIColor(red: 0, green: 110.0/255.0, blue: 0, alpha: 1.0),
                    UIColor(red: 0, green: 100.0/255.0, blue: 0, alpha: 1.0)
                ]
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
            setupGraph()
            barChart.position = position
            barChart.draw()
            sceneView.scene.rootNode.addChildNode(barChart)
        }
    }
    
    private func setupGraph() {
        barChart?.animationType = ARChartPresenter.AnimationType.grow;
        // 0.08, 0.25, 0.5
        barChart?.size = SCNVector3(0.08, 0.25, 0.5);
    }
    
    private func addLightSource(ofType type: SCNLight.LightType, at position: SCNVector3? = nil) {
        let light = SCNLight()
        light.color = UIColor.white
        light.type = type
        light.intensity = 2500 // Default SCNLight intensity is 1000
        
        let lightNode = SCNNode()
        lightNode.light = light
        if let lightPosition = position {
            // Fix the light source in one location
            lightNode.position = lightPosition
            self.sceneView.scene.rootNode.addChildNode(lightNode)
        } else {
            // Make the light source follow the camera position
            self.sceneView.pointOfView?.addChildNode(lightNode)
        }
    }
    
    private func setupRotationGesture() {
        let rotationGestureRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(handleRotation))
        self.view.addGestureRecognizer(rotationGestureRecognizer)
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
    
    // MARK: Navigation
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
}
