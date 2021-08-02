//
//  ARSettingsVC.swift
//  Cryptfolio
//
//  Created by Andre Staffa on 2021-08-01.
//  Copyright © 2021 Andre Staffa. All rights reserved.
//

import UIKit;

private struct ARSettingSection {
    public var headerTitle:String;
    public var cellTitle:String;
}

class ARSettingsVC: UIViewController {

    // MARK: - Member Fields
    
    
    private var settings:Array<Array<ARSettingSection>> = Array<Array<ARSettingSection>>();
    
    // Lighting section member fields
    private var lightingSelectedIndex:Int = 0;
    
    let settingsTableView : UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped);
        tableView.translatesAutoresizingMaskIntoConstraints = false;
        return tableView;
    }();
    
    // MARK: - Constructor
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .mainBackgroundColor;
        self.createSettings();
        
        self.settingsTableView.delegate = self;
        self.settingsTableView.dataSource = self;
        self.settingsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "ARSettingsCell");
        self.settingsTableView.register(ColorSectionCell.self, forCellReuseIdentifier: ColorSectionCell.reuseIdentifier);
        self.settingsTableView.separatorStyle = .none;
        self.settingsTableView.backgroundColor = .mainBackgroundColor;
        
        self.setupConstraints();
    }
    
    // MARK: - Setting Up Constraints
    
    private func setupConstraints() -> Void {
        self.view.addSubview(self.settingsTableView);
        
        // constraints for settingsTableView
        self.settingsTableView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true;
        self.settingsTableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true;
        self.settingsTableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true;
        self.settingsTableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true;
        
    }
    
    private func createSettings() -> Void {
        let lightingSection:Array<ARSettingSection> = [ARSettingSection(headerTitle: "Lighting", cellTitle: "Spotlight"), ARSettingSection(headerTitle: "Lighting", cellTitle: "Omnidirectional")];
        let colorSection:Array<ARSettingSection> = [ARSettingSection(headerTitle: "Color", cellTitle: "Brightness"), ARSettingSection(headerTitle: "Color", cellTitle: "Red"), ARSettingSection(headerTitle: "Color", cellTitle: "Green"), ARSettingSection(headerTitle: "Color", cellTitle: "Blue"), ARSettingSection(headerTitle: "Color", cellTitle: "Random")];
        self.settings = [lightingSection, colorSection];
    }

}

// MARK: - Table Methods

extension ARSettingsVC : UITableViewDelegate, UITableViewDataSource {
    
    private func setTextOfHeader(label:UILabel!, text: String) {
        label.text = text;
        label.sizeToFit();
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView();
        headerView.backgroundColor = UIColor.clear;
        
        let sectionLabel = UILabel(frame: CGRect(x: 8, y: 20, width: tableView.bounds.size.width, height: tableView.bounds.size.height));
        sectionLabel.font = UIFont.systemFont(ofSize: 18.0, weight: .bold);
        sectionLabel.textColor = .white;
        
        self.setTextOfHeader(label: sectionLabel, text: self.settings[section][0].headerTitle);
        headerView.addSubview(sectionLabel);
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0;
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0;
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.settings.count;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.settings[section].count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.section == 0) {
            let cell = self.initLightingCell(tableView: tableView, indexPath: indexPath);
            return cell;
        } else if (indexPath.section == 1) {
            let cell = self.initColorCell(indexPath: indexPath, tableView: tableView);
            return cell;
        }
        return UITableViewCell();
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true);
        if (indexPath.section == 0) {
            self.didSelectLightingCell(cell: tableView.cellForRow(at: indexPath)!, indexPath: indexPath, tableView: tableView);
        }
    }
    
    // MARK: - Lighting Cell Methods
    
    private func initLightingCell(tableView:UITableView, indexPath:IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ARSettingsCell", for: indexPath);
        cell.textLabel?.text = self.settings[indexPath.section][indexPath.row].cellTitle;
        cell.tintColor = .orange;
        cell.backgroundColor = .clear;
        if (indexPath.row == self.lightingSelectedIndex) {
            cell.accessoryType = .checkmark;
            cell.textLabel?.textColor = .orange;
        } else {
            cell.accessoryType = .none;
            cell.textLabel?.textColor = .white;
        }
        return cell;
    }
    
    private func didSelectLightingCell(cell:UITableViewCell, indexPath:IndexPath, tableView:UITableView) -> Void {
        let impact = UIImpactFeedbackGenerator(style: .light);
        impact.impactOccurred();
        cell.textLabel?.highlightedTextColor = .orange;
        switch (indexPath.row) {
            case 0:
                if (self.lightingSelectedIndex == indexPath.row) { break; }
                self.lightingSelectedIndex = 0;
                ARSettings.shared.lightingSettings = .spot;
                break;
            case 1:
                if (self.lightingSelectedIndex == indexPath.row) { break; }
                self.lightingSelectedIndex = 1;
                ARSettings.shared.lightingSettings = .omni;
                break;
            default:
                break;
        }
        self.lightingSelectedIndex = indexPath.row;
        tableView.reloadSections(IndexSet(integer: indexPath.section), with: .middle);
    }
    
    // MARK: - Color Cell Methods
    
    private func initColorCell(indexPath:IndexPath, tableView:UITableView) -> ColorSectionCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ColorSectionCell.reuseIdentifier, for: indexPath) as! ColorSectionCell;
        cell.settingLabel.text = self.settings[indexPath.section][indexPath.row].cellTitle;
        if (indexPath.row == 0) { cell.randomColorButton.isHidden = true; cell.slider.isHidden = false; }
        cell.slider.tag = indexPath.row;
        if (cell.slider.tag == 0) {
            cell.slider.maximumValue = 255;
            cell.slider.minimumValue = 50;
            cell.slider.value = 100;
            self.setSlider(slider: cell.slider);
        } else if (cell.slider.tag == 1) {
            cell.slider.maximumValue = 255;
            cell.slider.minimumValue = 0;
            cell.slider.value = Float(ARSettings.shared.redValue);
            cell.slider.tintColor = .red;
        } else if (cell.slider.tag == 2) {
            cell.slider.maximumValue = 255;
            cell.slider.minimumValue = 0;
            cell.slider.value = Float(ARSettings.shared.greenValue);
            cell.slider.tintColor = .green;
        } else if (cell.slider.tag == 3) {
            cell.slider.maximumValue = 255;
            cell.slider.minimumValue = 0;
            cell.slider.value = Float(ARSettings.shared.blueValue);
            cell.slider.tintColor = .blue;
        } else if (cell.slider.tag == 4) {
            cell.slider.isHidden = true;
            cell.randomColorButton.isHidden = false;
            cell.randomColorButton.addTarget(self, action: #selector(self.randomButtonTapped(_:)), for: .touchUpInside);
        }
        cell.slider.addTarget(self, action: #selector(self.sliderChanged(_:)), for: .valueChanged);
        return cell;
    }
    
    private func setSlider(slider:UISlider) {
        let tgl = CAGradientLayer();
        let frame = CGRect.init(x: 0, y: 0, width: slider.frame.size.width, height: 5);
        tgl.frame = frame;
        tgl.colors = [UIColor.blue.cgColor, UIColor.green.cgColor, UIColor.yellow.cgColor, UIColor.orange.cgColor, UIColor.red.cgColor];
        tgl.startPoint = CGPoint.init(x: 0.0, y: 0.5);
        tgl.endPoint = CGPoint.init(x: 1.0, y: 0.5);
        UIGraphicsBeginImageContextWithOptions(tgl.frame.size, tgl.isOpaque, 0.0);
        tgl.render(in: UIGraphicsGetCurrentContext()!);
        if let image = UIGraphicsGetImageFromCurrentImageContext() {
            UIGraphicsEndImageContext();
            image.resizableImage(withCapInsets: UIEdgeInsets.zero);
            slider.setMinimumTrackImage(image, for: .normal);
        }
    }
    
    @objc private func sliderChanged(_ sender:UISlider) -> Void {
        if (sender.tag == 0) {
            ARSettings.shared.brightnessPrecentage = CGFloat(sender.value);
        } else if (sender.tag == 1) {
            ARSettings.shared.adjustedColor = true;
            ARSettings.shared.redValue = CGFloat(sender.value);
        } else if (sender.tag == 2) {
            ARSettings.shared.adjustedColor = true;
            ARSettings.shared.greenValue = CGFloat(sender.value);
        } else if (sender.tag == 3) {
            ARSettings.shared.adjustedColor = true;
            ARSettings.shared.blueValue = CGFloat(sender.value);
        }
    }
    
    @objc private func randomButtonTapped(_ sender:UIButton) -> Void {
        let impact = UIImpactFeedbackGenerator(style: .light);
        impact.impactOccurred();
        ARSettings.shared.adjustedColor = true;
        ARSettings.shared.redValue = CGFloat.random(in: 0...255);
        ARSettings.shared.greenValue = CGFloat.random(in: 0...255);
        ARSettings.shared.blueValue = CGFloat.random(in: 0...255);
        self.settingsTableView.reloadSections(IndexSet(integer: 1), with: .middle);
    }
        
}

class ColorSectionCell : UITableViewCell {
    
    // MARK: - Member Fields
    
    public static let reuseIdentifier = "colorSectionCell";
    
    let settingLabel : UILabel = {
        let label = UILabel();
        label.text = "Brightness";
        label.textColor = .gray;
        label.textAlignment = .left;
        label.adjustsFontSizeToFitWidth = true;
        label.translatesAutoresizingMaskIntoConstraints = false;
        return label;
    }();
    
    let slider : UISlider = {
        let slider = UISlider();
        slider.tintColor = .orange;
        slider.translatesAutoresizingMaskIntoConstraints = false;
        return slider;
    }();
    
    let randomColorButton : UIButton = {
        let button = UIButton();
        button.isHidden = true;
        button.setTitle("Random Color", for: .normal)
        button.setTitleColor(.white, for: .normal);
        button.layer.borderWidth = 1;
        button.layer.borderColor = UIColor.orange.cgColor;
        button.backgroundColor = UIColor(red: 41/255, green: 46/255, blue: 47/255, alpha: 1);
        button.layer.cornerRadius = 10.0;
        button.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor;
        button.layer.shadowOffset = CGSize(width: 0.0, height: 2.0);
        button.layer.shadowOpacity = 1.0;
        button.layer.shadowRadius = 5.0;
        button.translatesAutoresizingMaskIntoConstraints = false;
        return button;
    }();
    
    
    // MARK: - Constructor
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier);
        
        self.contentView.isUserInteractionEnabled = false;
        self.selectionStyle = .none;
        self.backgroundColor = .clear;
        
        self.setupConstraints();
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented"); }
    
    
    // MARK: - Setting Up Constraints
    
    private func setupConstraints() -> Void {
        self.addSubview(self.settingLabel);
        self.addSubview(self.slider);
        self.addSubview(self.randomColorButton);
        
        // constraints for settingLabel
        self.settingLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10.0).isActive = true;
        self.settingLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true;
        self.settingLabel.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.4).isActive = true;
        self.settingLabel.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true;
        
        // constraints for brightnessSlider
        self.slider.leadingAnchor.constraint(equalTo: self.settingLabel.trailingAnchor, constant: 5.0).isActive = true;
        self.slider.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true;
        self.slider.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true;
        self.slider.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true;
        
        // constraints for randomColorButton
        self.randomColorButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10.0).isActive = true;
        self.randomColorButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true;
        self.randomColorButton.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.5).isActive = true;
        self.randomColorButton.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.7).isActive = true;
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse();
        self.layoutSubviews();
        self.sizeToFit();
    }
    
    
}
