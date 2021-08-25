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
    
    // transformation settings
    public var transformationType:Set<String> = ["Move", "Rotate", "Scale"];
    public var transformationSensitivity:Float = 0.001;

    // Lighting settings
    public var lightingTypeSettings:SCNLight.LightType = .spot;
    public var intensitySetting:CGFloat = 2500.0;
    public var temperatureSetting:CGFloat = 6500.0;
    
    // Color settings
    public var isGreen:Bool = false;
    public var adjustedColor:Bool = false;
    public var brightnessPrecentage:CGFloat = 100.0;
    public var redValue:CGFloat = 0.0;
    public var greenValue:CGFloat = 0.0;
    public var blueValue:CGFloat = 0.0;
    
    // Animation settings
    public var animationTypeSetting:Optional<ARChartPresenter.AnimationType> = .grow;
    public var animationDuration:Double = 2.0;
    
    // Viewables settings
    public var viewableType:Set<String> = Set<String>();
    public var viewableCoinImage:UIImage? = nil;
    
    // Graphics settings
    public let graphicsCycles:Array<Array<String>> = [["Medium", "High", "Ultra", "Custom", "Low"], ["MXAA 4x", "None", "MXAA 2x"], ["60", "30", "45"]];
    public var presetIndex:Int = 0;
    public var antiAliasingIndex:Int = 0;
    public var framerateIndex:Int = 0;
    public var numberOfBars:Int = 60;
	public var motionBlurToggle:Bool = false;
	public var filmGrainToggle:Bool = false;
	public var hdrToggle:Bool = true;
	public var dofToggle:Bool = false;
	public var showLabelsToggle:Bool = true;
	public var showStats:Bool = false;
	
	
    private init() {}
    
    public func resetAllSettings() -> Void {
        self.transformationType = ["Move", "Rotate", "Scale"];
        self.transformationSensitivity = 0.001;
        self.lightingTypeSettings = .spot;
        self.intensitySetting = 2500.0;
        self.temperatureSetting = 6500.0
        self.adjustedColor = false;
        self.brightnessPrecentage = 100.0;
        self.redValue = 0.0;
        self.greenValue = 0.0;
        self.blueValue = 0.0;
        self.animationTypeSetting = .grow;
        self.animationDuration = 2.0;
        self.viewableType = Set<String>();
        self.viewableCoinImage = nil;
        self.presetIndex = 0;
        self.antiAliasingIndex = 0;
        self.framerateIndex = 0;
        self.numberOfBars = 60;
		self.motionBlurToggle = false;
		self.filmGrainToggle = false;
		self.hdrToggle = true;
		self.dofToggle = false;
		self.showLabelsToggle = true;
		self.showStats = false;
    }
    
    public func resetTransformationSettings() -> Void {
        self.transformationType = ["Move", "Rotate", "Scale"];
        self.transformationSensitivity = 0.001;
    }
    
    public func resetLightingSettings() -> Void {
        self.lightingTypeSettings = .spot;
        self.intensitySetting = 2500.0;
        self.temperatureSetting = 6500.0;
    }
    
    public func resetColorSettings() -> Void {
        self.adjustedColor = false;
        self.brightnessPrecentage = 100;
        self.redValue = ARSettings.shared.isGreen ? 0.0 : 255.0 / 2.0;
        self.greenValue = ARSettings.shared.isGreen ? 255.0 / 2.0 : 0.0;
        self.blueValue = 0.0;
    }
    
    public func resetAnimationSettings() -> Void {
        self.animationTypeSetting = .grow;
        self.animationDuration = 2.0;
    }
    
    public func resetViewablesSettings() -> Void {
        self.viewableType = Set<String>();
    }
    
    public func resetGraphicsSettings() -> Void {
        self.presetIndex = 0;
        self.antiAliasingIndex = 0;
		self.framerateIndex = 0;
        self.numberOfBars = 60;
		self.motionBlurToggle = false;
		self.filmGrainToggle = false;
		self.hdrToggle = true;
		self.dofToggle = false;
		self.showLabelsToggle = true;
		self.showStats = false;
    }
	
	public func lowGraphicsPreset() -> Void {
		self.antiAliasingIndex = 1;
		self.numberOfBars = 30;
		self.motionBlurToggle = false;
		self.filmGrainToggle = false;
		self.hdrToggle = false;
		self.dofToggle = false;
		self.showLabelsToggle = false;
		self.animationTypeSetting = .none;
		self.resetViewablesSettings();
	}
	
	public func mediumGraphicsPreset() -> Void {
		self.antiAliasingIndex = 2;
		self.numberOfBars = 60;
		self.motionBlurToggle = true;
		self.filmGrainToggle = false;
		self.hdrToggle = true;
		self.dofToggle = false;
		self.showLabelsToggle = true;
		self.animationTypeSetting = .grow;
	}
	
	public func highGraphicsPreset() -> Void {
		self.antiAliasingIndex = 0;
		self.numberOfBars = 120;
		self.motionBlurToggle = true;
		self.filmGrainToggle = false;
		self.hdrToggle = true;
		self.dofToggle = false;
		self.showLabelsToggle = true;
		self.animationTypeSetting = .grow;
	}
	
	public func ultraGraphicsPreset() -> Void {
		self.antiAliasingIndex = 0;
		self.numberOfBars = 240;
		self.motionBlurToggle = true;
		self.filmGrainToggle = true;
		self.hdrToggle = true;
		self.dofToggle = true;
		self.showLabelsToggle = true;
		self.animationTypeSetting = .grow;
	}
	
	public func setGraphicsPreset() -> Void {
		let preset:String = ARSettings.shared.graphicsCycles[0][ARSettings.shared.presetIndex];
		if (preset == "Low") {
			ARSettings.shared.lowGraphicsPreset();
		} else if (preset == "Medium") {
			ARSettings.shared.mediumGraphicsPreset();
		} else if (preset == "High") {
			ARSettings.shared.highGraphicsPreset();
		} else if (preset == "Ultra") {
			ARSettings.shared.ultraGraphicsPreset();
		}
	}
	
	
    
}

class ARChartViewController: UIViewController, ARSCNViewDelegate, SideMenuNavigationControllerDelegate, UINavigationControllerDelegate {
    
    override var prefersStatusBarHidden: Bool { return true; }
    
    private var sideMenu : SideMenuNavigationController?
    
    private var flashToggle:Bool = true;
    
    let sceneView : ARSCNView = {
        let sceneView = ARSCNView();
        sceneView.translatesAutoresizingMaskIntoConstraints = false;
        return sceneView;
    }();
    
    let chartButton : UIButton = {
        let button = UIButton();
		button.frame = CGRect(x: 0, y: 0, width: 65, height: 65);
		button.setImage(UIImage(named: "plus")?.withRenderingMode(.alwaysTemplate), for: .normal);
		button.tintColor = .white
		button.backgroundColor = .mainBackgroundColor;
		button.layer.borderWidth = 1.0;
		button.layer.borderColor = UIColor.orange.cgColor;
		button.layer.cornerRadius = button.bounds.size.width / 2;
		button.layer.masksToBounds = true;
		button.clipsToBounds = true;
		button.translatesAutoresizingMaskIntoConstraints = false;
		return button
    }();
	
	let screenshotButton : UIButton = {
		let button = UIButton();
		button.frame = CGRect(x: 0, y: 0, width: 65, height: 65);
		button.setImage(UIImage(named: "screenshot")?.withRenderingMode(.alwaysTemplate), for: .normal);
		button.tintColor = .white
		button.backgroundColor = .mainBackgroundColor;
		button.layer.borderWidth = 1.0;
		button.layer.borderColor = UIColor.orange.cgColor;
		button.layer.cornerRadius = button.bounds.size.width / 2;
		button.layer.masksToBounds = true;
		button.clipsToBounds = true;
		button.translatesAutoresizingMaskIntoConstraints = false;
		return button
	}();
	
    public var dataPoints:Array<Array<Double>>!;
    public var coin:Coin!;
    
    var barChart: ARBarChart? {
        didSet {
			self.chartButton.setImage((self.barChart == nil) ? UIImage(named: "plus")?.withRenderingMode(.alwaysTemplate) : UIImage(named: "minus")?.withRenderingMode(.alwaysTemplate), for: .normal);
        }
    }
    
    var session: ARSession {
        return sceneView.session
    }
    
    var screenCenter: CGPoint?
    
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
		self.screenshotButton.addTarget(self, action: #selector(self.handleTapScreenshotButton(_:)), for: .touchUpInside);
		
        sceneView.delegate = self
        sceneView.scene = SCNScene()
		sceneView.showsStatistics = ARSettings.shared.showStats;
		let antiAliasingMode = ARSettings.shared.graphicsCycles[1][ARSettings.shared.antiAliasingIndex];
		if (antiAliasingMode == "MXAA 4x") {
			self.sceneView.antialiasingMode = .multisampling4X;
		} else if (antiAliasingMode == "MXAA 2x") {
			self.sceneView.antialiasingMode = .multisampling2X;
		} else if (antiAliasingMode == "None") {
			self.sceneView.antialiasingMode = .none;
		}
        sceneView.automaticallyUpdatesLighting = true
        sceneView.contentScaleFactor = 1.0
		sceneView.rendersMotionBlur = ARSettings.shared.motionBlurToggle;
		sceneView.rendersCameraGrain = ARSettings.shared.filmGrainToggle;
		sceneView.preferredFramesPerSecond = Int(ARSettings.shared.graphicsCycles[2][ARSettings.shared.framerateIndex])!;
        DispatchQueue.main.async {
            self.screenCenter = self.sceneView.bounds.mid
        }
        
        if let camera = sceneView.pointOfView?.camera {
			camera.wantsHDR = ARSettings.shared.hdrToggle;
            camera.wantsExposureAdaptation = true
            camera.exposureOffset = -1
            camera.minimumExposure = -1
			camera.wantsDepthOfField = ARSettings.shared.dofToggle;
        }
        
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
    
    private func adjustTransformationSettings() -> Void {
        self.view.gestureRecognizers?.removeAll();
        if (ARSettings.shared.transformationType.count == 3) {
            self.setupTranslationGesture();
            self.setupRotationGesture();
            self.setupPinchScaleGesture();
        } else if (ARSettings.shared.transformationType.count == 2) {
            if (ARSettings.shared.transformationType.contains("Move") && ARSettings.shared.transformationType.contains("Rotate")) {
                self.setupTranslationGesture();
                self.setupRotationGesture();
            } else if (ARSettings.shared.transformationType.contains("Move") && ARSettings.shared.transformationType.contains("Scale")) {
                self.setupTranslationGesture();
                self.setupPinchScaleGesture();
            } else if (ARSettings.shared.transformationType.contains("Rotate") && ARSettings.shared.transformationType.contains("Scale")) {
                self.setupRotationGesture();
                self.setupPinchScaleGesture();
            }
        } else if (ARSettings.shared.transformationType.count == 1) {
            if (ARSettings.shared.transformationType.contains("Move")) {
                self.setupTranslationGesture();
            } else if ARSettings.shared.transformationType.contains("Rotate") {
                self.setupRotationGesture();
            } else if (ARSettings.shared.transformationType.contains("Scale")) {
                self.setupPinchScaleGesture();
            }
        }
    }
    
    private func adjustViewablesSettings(barChart:ARBarChart) -> Void {
        if (ARSettings.shared.viewableType.count == 2) {
            let sphere = self.addSphere(contents: UIImage(named: "Images/\(self.coin.ticker.symbol.lowercased()).png"), position: SCNVector3(0, 0.30, 0));
            sphere.scale = SCNVector3(sphere.scale.x, sphere.scale.y, sphere.scale.z / 2);
            barChart.addChildNode(sphere);
            let priceText = self.add3dText(message: CryptoData.convertToDollar(price: self.coin!.ticker.price), position: SCNVector3(-0.035, -0.040, 0));
            sphere.addChildNode(priceText);
            sphere.eulerAngles = SCNVector3(0, -Double.pi/2, 0);
        } else if (ARSettings.shared.viewableType.count == 1) {
            if (ARSettings.shared.viewableType.contains("Coin Symbol")) {
                let sphere = self.addSphere(contents: UIImage(named: "Images/\(self.coin.ticker.symbol.lowercased()).png"), position: SCNVector3(0, 0.30, 0));
                sphere.scale = SCNVector3(sphere.scale.x, sphere.scale.y, sphere.scale.z / 2);
                sphere.eulerAngles = SCNVector3(0, -Double.pi/2, 0);
                barChart.addChildNode(sphere);
            } else if (ARSettings.shared.viewableType.contains("Coin Price")) {
                let priceText = self.add3dText(message: CryptoData.convertToDollar(price: self.coin!.ticker.price), position: SCNVector3(0, 0.30, 0));
                priceText.eulerAngles = SCNVector3(0, -Double.pi/2, 0);
                barChart.addChildNode(priceText);
            }
        }
    }
    
    private func adjustLightingSettings() -> Void {
        addLightSource(ofType: ARSettings.shared.lightingTypeSettings, intensity: ARSettings.shared.intensitySetting, temperature: ARSettings.shared.temperatureSetting);
    }
	
	private func adjustGraphicsSettings() -> Void {
	
		let antiAliasingMode = ARSettings.shared.graphicsCycles[1][ARSettings.shared.antiAliasingIndex];
		let framerateLock = ARSettings.shared.graphicsCycles[2][ARSettings.shared.framerateIndex];
		
		if (antiAliasingMode == "MXAA 4x") {
			self.sceneView.antialiasingMode = .multisampling4X;
		} else if (antiAliasingMode == "MXAA 2x") {
			self.sceneView.antialiasingMode = .multisampling2X;
		} else if (antiAliasingMode == "None") {
			self.sceneView.antialiasingMode = .none;
		}
		
		self.sceneView.showsStatistics = ARSettings.shared.showStats;
		self.sceneView.rendersMotionBlur = ARSettings.shared.motionBlurToggle;
		self.sceneView.rendersCameraGrain = ARSettings.shared.filmGrainToggle;
		self.sceneView.preferredFramesPerSecond = Int(framerateLock)!;
		
		if let camera = self.sceneView.pointOfView?.camera {
			camera.wantsHDR = ARSettings.shared.hdrToggle;
			camera.wantsDepthOfField = ARSettings.shared.dofToggle;
		}
		
	}
    
    func sideMenuDidAppear(menu: SideMenuNavigationController, animated: Bool) {
        self.chartButton.isUserInteractionEnabled = false;
        
        // external settings to bring into ARSettingsVC
        ARSettings.shared.viewableCoinImage = UIImage(named: "Images/\(self.coin.ticker.symbol.lowercased()).png");
        
    }
    
    func sideMenuDidDisappear(menu: SideMenuNavigationController, animated: Bool) {
        
        // internal settings affecting the ARBarChart object
        if (self.barChart != nil) {
            let lastPosition = self.barChart!.position;
            let lastSize = self.barChart!.size;
            let lastScale = self.barChart!.scale;
            let angles = self.barChart!.eulerAngles
            let rotation = self.barChart!.rotation;
            self.barChart!.removeFromParentNode();
            self.barChart = nil;
            self.barChart = ARBarChart();
            
            let values = self.scaledPrices(divider: Int(ceil(Double(self.dataPoints.count) / Double(ARSettings.shared.numberOfBars))));
            let colors = self.getColors();
            
            let dataSeries = ARDataSeries(withValues: values.0);
            dataSeries.spaceForIndexLabels = 0.2;
            dataSeries.spaceForIndexLabels = 0.2;
            dataSeries.barColors = colors;
            dataSeries.barOpacity = 1;
            
			if (ARSettings.shared.showLabelsToggle) {
				let labels = self.getSeriesLabels(values: values);
				dataSeries.seriesLabels = labels;
			}
			
            self.barChart!.dataSource = dataSeries
            self.barChart!.delegate = dataSeries
            self.barChart!.animationType = .none;
            self.barChart!.animationDuration = 0;
            self.barChart!.size = lastSize;
            self.barChart!.scale = lastScale;
            self.barChart!.position = lastPosition;
            self.barChart!.eulerAngles = angles;
            self.barChart!.rotation = rotation;
            self.barChart!.draw();
            self.sceneView.scene.rootNode.addChildNode(self.barChart!);
            self.adjustViewablesSettings(barChart: self.barChart!);
        }
        
        // external settings outside of the ARBarChart object.
        self.chartButton.isUserInteractionEnabled = true;
        self.adjustLightingSettings();
        self.adjustTransformationSettings();
		self.adjustGraphicsSettings();
        
    }
    
    func sideMenuWillDisappear(menu: SideMenuNavigationController, animated: Bool) {
        // MAYBE HERE
    }
    
    private func setupSideMenu() -> Void {
        self.sideMenu = SideMenuNavigationController(rootViewController: ARSettingsVC());
        self.sideMenu?.delegate = self;
        self.sideMenu?.setNavigationBarHidden(true, animated: false);
        self.sideMenu?.menuWidth = self.view.frame.width * 0.8;
        self.sideMenu?.enableSwipeToDismissGesture = false;
        SideMenuManager.default.rightMenuNavigationController = self.sideMenu;
        
        // right bar items
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
		
		let flashButton = UIButton();
		flashButton.frame = CGRect(x: 0, y: 0, width: 45, height: 50);
		flashButton.setImage(UIImage(named: "flash_off")?.withRenderingMode(.alwaysTemplate), for: .normal);
		flashButton.tintColor = .white
		flashButton.backgroundColor = .mainBackgroundColor;
		flashButton.layer.borderWidth = 1.0;
		flashButton.layer.borderColor = UIColor.orange.cgColor;
		flashButton.layer.cornerRadius = settingsButton.bounds.size.width / 2;
		flashButton.layer.masksToBounds = true;
		flashButton.clipsToBounds = true;
		flashButton.addTarget(self, action: #selector(self.flashButtonTapped(_:)), for: .touchUpInside);
        
        let rightBarButtons = [UIBarButtonItem(customView: settingsButton), UIBarButtonItem(customView: flashButton)];
        self.navigationItem.rightBarButtonItems = rightBarButtons;
        
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
    
    @objc private func flashButtonTapped(_ sender:UIButton) -> Void {
		sender.setImage((self.flashToggle) ? UIImage(named: "flash_on")?.withRenderingMode(.alwaysTemplate) : UIImage(named: "flash_off")?.withRenderingMode(.alwaysTemplate), for: .normal);
        self.toggleTorch(on: self.flashToggle);
        self.flashToggle = !self.flashToggle;
    }
    
    @objc private func exitButtonTapped() -> Void {
        self.navigationController?.popViewController(animated: true);
    }
    
    private func toggleTorch(on: Bool) -> Void {
        guard let device = AVCaptureDevice.default(for: .video) else { return; }
        if (device.hasTorch) {
            do {
                try device.lockForConfiguration();
                device.torchMode = (on) ? .on : .off;
                device.unlockForConfiguration();
            } catch {
                print("Torch could not be used");
            }
        } else {
            print("Torch is not available");
        }
    }
    
    private func setupConstraints() -> Void {
        self.view.addSubview(self.sceneView);
        self.view.addSubview(self.chartButton);
		self.view.addSubview(self.screenshotButton);
		
        // constraiints for sceneView
        self.sceneView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true;
        self.sceneView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true;
        self.sceneView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true;
        self.sceneView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true;
        
        // constraints for chartView
        self.chartButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -25.0).isActive = true;
		self.chartButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 45).isActive = true;
		self.chartButton.widthAnchor.constraint(equalToConstant: 65.0).isActive = true;
        self.chartButton.heightAnchor.constraint(equalToConstant: 65.0).isActive = true;
		
		// constraints for screenshotButton
		self.screenshotButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -25.0).isActive = true;
		self.screenshotButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: -45.0).isActive = true;
		self.screenshotButton.widthAnchor.constraint(equalToConstant: 65.0).isActive = true;
		self.screenshotButton.heightAnchor.constraint(equalToConstant: 65.0).isActive = true;
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
    
    private func scaledPrices(divider:Int) -> ([[Double]], [Double]) {
        var values:[[Double]] = [];
        var realValues:[Double] = [];
        let (max, min) = self.getMaxMin();
        let delta:Double = (max - (0.999 * min));
        for i in 0..<self.dataPoints.count {
            if (i % divider == 0) {
                for j in 0..<self.dataPoints[i].count {
                    let a = ((max - self.dataPoints[i][j]) / delta);
                    let b = (1 - a) * max;
                    values.append([b]);
                    realValues.append(self.dataPoints[i][j]);
                }
            }
        }
        return (values, realValues);
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
    
    private func getSeriesLabels(values:([[Double]], [Double])) -> Array<String> {
        var label:Array<String> = Array<String>();
        for i in 0..<values.0.count {
            for _ in values.0[i] {
                if (i == 0) {
                    label.append("START");
                } else if (i == values.0.count / 2) {
                    label.append("MID")
                } else if (i == values.0.count - 1) {
                    label.append("END");
                } else {
                    label.append("\(String(format: "%.2f", values.1[i]))");
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
                
        let values = self.scaledPrices(divider: Int(ceil(Double(self.dataPoints.count) / Double(ARSettings.shared.numberOfBars))));
        let colors = self.getColors();
        let labels = self.getSeriesLabels(values: values);
        
        let dataSeries = ARDataSeries(withValues: values.0);
        dataSeries.spaceForIndexLabels = 0.2
        dataSeries.spaceForIndexLabels = 0.2
        dataSeries.barColors = colors;
        dataSeries.barOpacity = 1;
        
        dataSeries.seriesLabels = labels;
        
        barChart = ARBarChart()
        if let barChart = barChart {
            barChart.dataSource = dataSeries
            barChart.delegate = dataSeries
            barChart.animationType = ARSettings.shared.animationTypeSetting;
            barChart.animationDuration = ARSettings.shared.animationDuration;
            barChart.size = SCNVector3(0.08, 0.25, 0.5);  // 0.08, 0.25, 0.5
            barChart.position = position
            barChart.draw()
            sceneView.scene.rootNode.addChildNode(barChart)
            self.adjustViewablesSettings(barChart: barChart);
            barChart.eulerAngles = SCNVector3(0, Double.pi/2, 0);
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
	
	@objc private func handleTapScreenshotButton(_ sender:UIButton) -> Void {
		let impact = UIImpactFeedbackGenerator(style: .light);
		impact.prepare();
		impact.impactOccurred();
		let image = self.sceneView.snapshot();
		let screenshotView = AScreenshotView(viewController: self, image: image);
		screenshotView.show();
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
            barChart.position = SCNVector3(startingTranslation.x + (Float(translation.x) * ARSettings.shared.transformationSensitivity), startingTranslation.y, startingTranslation.z + (Float(translation.y) * ARSettings.shared.transformationSensitivity));
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
