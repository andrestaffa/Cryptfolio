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
    
    // Animation sectio member fields
    private var animationSelectedIndex:Int = 0;
    
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
        self.settingsTableView.register(SelectionSectionCell.self, forCellReuseIdentifier: SelectionSectionCell.reuseIdentifier);
        self.settingsTableView.register(SliderSectionCell.self, forCellReuseIdentifier: SliderSectionCell.reuseIdentifier);
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
        let transformationSection:Array<ARSettingSection> = [ARSettingSection(headerTitle: "Transformation", cellTitle: "Move"), ARSettingSection(headerTitle: "Transformation", cellTitle: "Rotate"), ARSettingSection(headerTitle: "Transformation", cellTitle: "Scale")];
        let lightingSection:Array<ARSettingSection> = [ARSettingSection(headerTitle: "Lighting", cellTitle: "Spotlight"), ARSettingSection(headerTitle: "Lighting", cellTitle: "Omnidirectional"), ARSettingSection(headerTitle: "Lighting", cellTitle: "Intensity"), ARSettingSection(headerTitle: "Lighting", cellTitle: "Temperature")];
        let colorSection:Array<ARSettingSection> = [ARSettingSection(headerTitle: "Color", cellTitle: "Brightness"), ARSettingSection(headerTitle: "Color", cellTitle: "Red"), ARSettingSection(headerTitle: "Color", cellTitle: "Green"), ARSettingSection(headerTitle: "Color", cellTitle: "Blue"), ARSettingSection(headerTitle: "Color", cellTitle: "Random")];
        let animationSection:Array<ARSettingSection> = [ARSettingSection(headerTitle: "Animation", cellTitle: "Grow"), ARSettingSection(headerTitle: "Animation", cellTitle: "Fade"), ARSettingSection(headerTitle: "Animation", cellTitle: "Duration")];
        self.settings = [transformationSection, lightingSection, colorSection, animationSection];
    }

}

// MARK: - Table Methods

extension ARSettingsVC : UITableViewDelegate, UITableViewDataSource {
    
    @objc private func resetButtonTapped(_ sender: UIButton) -> Void {
        let impact = UIImpactFeedbackGenerator(style: .light);
        impact.prepare();
        impact.impactOccurred();
        sender.alpha = 0.5;
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { sender.alpha = 1.0; }
        if (sender.tag == 0) {
            ARSettings.shared.resetTransformationSettings();
            var indexPaths:Array<IndexPath> = Array<IndexPath>();
            for row in 0...2 {
                indexPaths.append(IndexPath(row: row, section: 0));
            }
            self.settingsTableView.reloadRows(at: indexPaths, with: .none);
        } else if (sender.tag == 1) {
            ARSettings.shared.resetLightingSettings();
            self.lightingSelectedIndex = 0;
            var indexPaths:Array<IndexPath> = Array<IndexPath>();
            for row in 0...3 {
                indexPaths.append(IndexPath(row: row, section: 1));
            }
            self.settingsTableView.reloadRows(at: indexPaths, with: .none);
        } else if (sender.tag == 2) {
            ARSettings.shared.resetColorSettings();
            var indexPaths:Array<IndexPath> = Array<IndexPath>();
            for row in 0...3 {
                indexPaths.append(IndexPath(row: row, section: 2));
            }
            self.settingsTableView.reloadRows(at: indexPaths, with: .none);
        } else if (sender.tag == 3) {
            ARSettings.shared.resetAnimationSettings();
            self.animationSelectedIndex = 0;
            var indexPaths:Array<IndexPath> = Array<IndexPath>();
            for row in 0...2 {
                indexPaths.append(IndexPath(row: row, section: 3));
            }
            self.settingsTableView.reloadRows(at: indexPaths, with: .none);
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView();
        headerView.backgroundColor = UIColor.clear;
        
        let sectionLabel = UILabel(frame: CGRect(x: 0, y: 25, width: tableView.bounds.size.width * 0.4, height: tableView.bounds.size.height));
        sectionLabel.font = UIFont.systemFont(ofSize: 18.0, weight: .bold);
        sectionLabel.textColor = .white;
        sectionLabel.text = self.settings[section][0].headerTitle;
        sectionLabel.sizeToFit();
        
        let resetButton = UIButton(frame: CGRect(x: tableView.bounds.size.width * 0.75, y: 20, width: tableView.bounds.size.width * 0.3, height: tableView.bounds.size.height));
        resetButton.tag = section;
        resetButton.setAttributedTitle(NSAttributedString(string: "Reset", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15.0, weight: .bold)]), for: .normal);
        resetButton.setTitleColor(.orange, for: .normal);
        resetButton.sizeToFit();
        
        resetButton.addTarget(self, action: #selector(self.resetButtonTapped(_:)), for: .touchUpInside);
        
        headerView.addSubview(sectionLabel);
        headerView.addSubview(resetButton);
        
        return headerView;
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 70.0;
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0;
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
            let cell = self.initTransformationCell(tableView: tableView, indexPath: indexPath);
            return cell;
        } else if (indexPath.section == 1) {
            let cell = self.initLightingCell(tableView: tableView, indexPath: indexPath);
            return cell;
        } else if (indexPath.section == 2) {
            let cell = self.initColorCell(indexPath: indexPath, tableView: tableView);
            return cell;
        } else if (indexPath.section == 3) {
            let cell = self.initAnimationCell(tableView: tableView, indexPath: indexPath);
            return cell;
        }
        let cell = UITableViewCell();
        cell.backgroundColor = .clear;
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true);
        if (indexPath.section == 0) {
            if let cell = tableView.cellForRow(at: indexPath) as? SelectionSectionCell {
                self.didSelectTransformationCell(cell: cell, indexPath: indexPath);
            }
        } else if (indexPath.section == 1) {
            if let cell = tableView.cellForRow(at: indexPath) as? SelectionSectionCell {
                self.didSelectLightingCell(cell: cell, indexPath: indexPath, tableView: tableView);
            }
        } else if (indexPath.section == 3) {
            if let cell = tableView.cellForRow(at: indexPath) as? SelectionSectionCell {
                self.didSelectAnimationCell(cell: cell, indexPath: indexPath, tableView: tableView);
            }
        }
    }
    
    // MARK: - Transformation Cell Methods
    
    private func initTransformationCell(tableView:UITableView, indexPath:IndexPath) -> UITableViewCell {
        let cell = SelectionSectionCell(style: .default, reuseIdentifier: SelectionSectionCell.reuseIdentifier);
        cell.settingLabel.text = self.settings[indexPath.section][indexPath.row].cellTitle;
        self.transformationSelectedLogic(cell: cell, indexPath: indexPath);
        if (indexPath.row == 0) {
            cell.settingsImageView.image = UIImage(named: "move");
        } else if (indexPath.row == 1) {
            cell.settingsImageView.image = UIImage(named: "rotate");
        } else if (indexPath.row == 2) {
            cell.settingsImageView.image = UIImage(named: "scale");
        }
        return cell;
    }
    
    private func didSelectTransformationCell(cell:SelectionSectionCell, indexPath:IndexPath) -> Void {
        let impact = UIImpactFeedbackGenerator(style: .light);
        impact.impactOccurred();
        if (cell.accessoryType == .checkmark) {
            cell.accessoryType = .none;
            cell.tintColor = .white;
            cell.settingLabel.textColor = .white;
            cell.settingLabel.highlightedTextColor = .white;
            ARSettings.shared.transformationType.remove(self.settings[indexPath.section][indexPath.row].cellTitle);
        } else {
            cell.tintColor = .orange;
            cell.settingLabel.tintColor = .orange;
            cell.settingLabel.textColor = .orange;
            cell.settingLabel.highlightedTextColor = .orange;
            cell.accessoryType = .checkmark;
            ARSettings.shared.transformationType.insert(self.settings[indexPath.section][indexPath.row].cellTitle);
        }
    }
    
    private func transformationSelectedLogic(cell:SelectionSectionCell, indexPath:IndexPath) -> Void {
        if (ARSettings.shared.transformationType.count == 3) {
            self.transformationSelectedCell(cell: cell);
        } else if (ARSettings.shared.transformationType.count == 2) {
            if (ARSettings.shared.transformationType.contains("Move") && ARSettings.shared.transformationType.contains("Rotate")) {
                if (indexPath.row == 0 || indexPath.row == 1) {
                    self.transformationSelectedCell(cell: cell);
                } else {
                    self.transformationUnselectedCell(cell: cell);
                }
            } else if (ARSettings.shared.transformationType.contains("Move") && ARSettings.shared.transformationType.contains("Scale")) {
                if (indexPath.row == 0 || indexPath.row == 2) {
                    self.transformationSelectedCell(cell: cell);
                } else {
                    self.transformationUnselectedCell(cell: cell);
                }
            } else if (ARSettings.shared.transformationType.contains("Rotate") && ARSettings.shared.transformationType.contains("Scale")) {
                if (indexPath.row == 1 || indexPath.row == 2) {
                    self.transformationSelectedCell(cell: cell);
                } else {
                    self.transformationUnselectedCell(cell: cell);
                }
            }
        } else if (ARSettings.shared.transformationType.count == 1) {
            if (ARSettings.shared.transformationType.contains("Move")) {
                if (indexPath.row == 0) {
                    self.transformationSelectedCell(cell: cell);
                } else {
                    self.transformationUnselectedCell(cell: cell);
                }
            } else if ARSettings.shared.transformationType.contains("Rotate") {
                if (indexPath.row == 1) {
                    self.transformationSelectedCell(cell: cell);
                } else {
                    self.transformationUnselectedCell(cell: cell);
                }
            } else if (ARSettings.shared.transformationType.contains("Scale")) {
                if (indexPath.row == 2) {
                    self.transformationSelectedCell(cell: cell);
                } else {
                    self.transformationUnselectedCell(cell: cell);
                }
            }
        } else {
            self.transformationUnselectedCell(cell: cell);
        }
    }
    
    private func transformationSelectedCell(cell:SelectionSectionCell) -> Void {
        cell.tintColor = .orange;
        cell.settingLabel.tintColor = .orange;
        cell.settingLabel.textColor = .orange;
        cell.settingLabel.highlightedTextColor = .orange;
        cell.accessoryType = .checkmark;
    }
    
    private func transformationUnselectedCell(cell:SelectionSectionCell) -> Void {
        cell.accessoryType = .none;
        cell.tintColor = .white;
        cell.settingLabel.textColor = .white;
        cell.settingLabel.highlightedTextColor = .white;
    }
    
    // MARK: - Lighting Cell Methods
    
    private func initLightingCell(tableView:UITableView, indexPath:IndexPath) -> UITableViewCell {
        if (indexPath.row < 2) {
            let cell = SelectionSectionCell(style: .default, reuseIdentifier: SelectionSectionCell.reuseIdentifier);
            cell.settingLabel.text = self.settings[indexPath.section][indexPath.row].cellTitle;
            if (indexPath.row == 0) {
                cell.settingsImageView.image = UIImage(named: "spotlight");
            } else if (indexPath.row == 1) {
                cell.settingsImageView.image = UIImage(named: "omi_light");
            }
            cell.tintColor = .orange;
            cell.backgroundColor = .clear;
            if (indexPath.row == self.lightingSelectedIndex) {
                cell.accessoryType = .checkmark;
                cell.settingLabel.textColor = .orange;
            } else {
                cell.accessoryType = .none;
                cell.settingLabel.textColor = .white;
            }
            return cell;
        } else {
            let cell = SliderSectionCell(style: .default, reuseIdentifier: SliderSectionCell.reuseIdentifier);
            cell.settingLabel.text = self.settings[indexPath.section][indexPath.row].cellTitle;
            if (indexPath.row == 2 || indexPath.row == 3) { cell.randomButton.isHidden = true; cell.slider.isHidden = false; cell.settingsImageView.isHidden = false; }
            cell.slider.tag = indexPath.row;
            if (cell.slider.tag == 2) {
                cell.slider.maximumValue = 5000;
                cell.slider.minimumValue = 500;
                cell.slider.setValue(Float(ARSettings.shared.intensitySetting), animated: false);
                cell.setSlider(slider: cell.slider, stillColor: UIColor(red: 224/255, green: 184/255, blue: 81/255, alpha: 1));
                cell.settingsImageView.image = UIImage(named: "intensity_color");
            } else if (cell.slider.tag == 3) {
                cell.slider.maximumValue = 40_000;
                cell.slider.minimumValue = 0;
                cell.slider.setValue(40_000 - Float(ARSettings.shared.temperatureSetting), animated: false);
                cell.setSlider(slider: cell.slider, colors: [UIColor.blue.cgColor, UIColor.green.cgColor, UIColor.yellow.cgColor, UIColor.orange.cgColor, UIColor.red.cgColor]);
                cell.settingsImageView.image = UIImage(named: "temp_color");
            }
            cell.slider.addTarget(self, action: #selector(self.lightingSliderChanged(_:)), for: .valueChanged);
            return cell;
        }
    }
    
    private func didSelectLightingCell(cell:SelectionSectionCell, indexPath:IndexPath, tableView:UITableView) -> Void {
        let impact = UIImpactFeedbackGenerator(style: .light);
        impact.impactOccurred();
        cell.settingLabel.highlightedTextColor = .orange;
        switch (indexPath.row) {
            case 0:
                if (self.lightingSelectedIndex == indexPath.row) { break; }
                self.lightingSelectedIndex = 0;
                ARSettings.shared.lightingTypeSettings = .spot;
                break;
            case 1:
                if (self.lightingSelectedIndex == indexPath.row) { break; }
                self.lightingSelectedIndex = 1;
                ARSettings.shared.lightingTypeSettings = .omni;
                break;
            default:
                break;
        }
        self.lightingSelectedIndex = indexPath.row;
        tableView.reloadRows(at: [IndexPath(row: 0, section: indexPath.section), IndexPath(row: 1, section: indexPath.section)], with: .none);
    }
    
    @objc private func lightingSliderChanged(_ sender:UISlider) -> Void {
        if (sender.tag == 2) {
            ARSettings.shared.intensitySetting = CGFloat(sender.value);
        } else if (sender.tag == 3) {
            ARSettings.shared.temperatureSetting = 40_000 - CGFloat(sender.value);
        }
    }
    
    // MARK: - Color Cell Methods
    
    private func initColorCell(indexPath:IndexPath, tableView:UITableView) -> SliderSectionCell {
        let cell = SliderSectionCell(style: .default, reuseIdentifier: SliderSectionCell.reuseIdentifier);
        cell.settingLabel.text = self.settings[indexPath.section][indexPath.row].cellTitle;
        if (indexPath.row != 4) { cell.randomButton.isHidden = true; cell.slider.isHidden = false; cell.settingsImageView.isHidden = false;}
        cell.slider.tag = indexPath.row;
        if (cell.slider.tag == 0) {
            cell.slider.maximumValue = 255;
            cell.slider.minimumValue = 50;
            cell.slider.setValue(Float(ARSettings.shared.brightnessPrecentage), animated: false);
            cell.setSlider(slider: cell.slider, colors: [UIColor.black.cgColor, UIColor.darkGray.cgColor, UIColor.gray.cgColor, UIColor.lightGray.cgColor, UIColor.white.cgColor]);
            cell.settingsImageView.image = UIImage(named: "brightness");
        } else if (cell.slider.tag == 1) {
            cell.slider.maximumValue = 255;
            cell.slider.minimumValue = 0;
            cell.slider.setValue(Float(ARSettings.shared.redValue), animated: false);
            cell.setSlider(slider: cell.slider, stillColor: .red);
            cell.settingsImageView.image = UIImage(named: "red_circle");
        } else if (cell.slider.tag == 2) {
            cell.slider.maximumValue = 255;
            cell.slider.minimumValue = 0;
            cell.slider.setValue(Float(ARSettings.shared.greenValue), animated: false);
            cell.setSlider(slider: cell.slider, stillColor: .green);
            cell.settingsImageView.image = UIImage(named: "green_circle");
        } else if (cell.slider.tag == 3) {
            cell.slider.maximumValue = 255;
            cell.slider.minimumValue = 0;
            cell.slider.setValue(Float(ARSettings.shared.blueValue), animated: false);
            cell.setSlider(slider: cell.slider, stillColor: .blue);
            cell.settingsImageView.image = UIImage(named: "blue_circle");
        } else if (cell.slider.tag == 4) {
            cell.slider.isHidden = true;
            cell.settingsImageView.isHidden = true;
            cell.randomButton.isHidden = false;
            cell.settingLabel.isHidden = true;
            cell.randomButton.setAttributedTitle(NSAttributedString(string: "Random Color", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15.0, weight: .bold)]), for: .normal);
            cell.randomButton.addTarget(self, action: #selector(self.randomButtonTapped(_:)), for: .touchUpInside);
        }
        cell.slider.addTarget(self, action: #selector(self.colorSliderChanged(_:)), for: .valueChanged);
        return cell;
    }
    
    @objc private func colorSliderChanged(_ sender:UISlider) -> Void {
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
        self.settingsTableView.reloadRows(at: [IndexPath(row: 1, section: 2), IndexPath(row: 2, section: 2), IndexPath(row: 3, section: 2)], with: .none);
    }
    
    // MARK: - Animation Cell Methods
    
    private func initAnimationCell(tableView:UITableView, indexPath:IndexPath) -> UITableViewCell {
        if (indexPath.row < 2) {
            let cell = SelectionSectionCell(style: .default, reuseIdentifier: SelectionSectionCell.reuseIdentifier);
            cell.settingLabel.text = self.settings[indexPath.section][indexPath.row].cellTitle;
            if (indexPath.row == 0) {
                cell.settingsImageView.image = UIImage(named: "grow");
            } else if (indexPath.row == 1) {
                cell.settingsImageView.image = UIImage(named: "fade");
            }
            cell.tintColor = .orange;
            cell.backgroundColor = .clear;
            if (indexPath.row == self.animationSelectedIndex) {
                cell.accessoryType = .checkmark;
                cell.settingLabel.textColor = .orange;
            } else {
                cell.accessoryType = .none;
                cell.settingLabel.textColor = .white;
            }
            return cell;
        } else {
            let cell = SliderSectionCell(style: .default, reuseIdentifier: SliderSectionCell.reuseIdentifier);
            cell.settingLabel.text = self.settings[indexPath.section][indexPath.row].cellTitle;
            cell.settingsImageView.image = UIImage(named: "duration");
            if (indexPath.row == 2) { cell.randomButton.isHidden = true; cell.slider.isHidden = false; }
            cell.slider.maximumValue = 5;
            cell.slider.minimumValue = 1;
            cell.slider.setValue(Float(ARSettings.shared.animationDuration), animated: false);
            cell.setSlider(slider: cell.slider, colors: [UIColor.blue.cgColor, UIColor.green.cgColor, UIColor.yellow.cgColor, UIColor.orange.cgColor, UIColor.red.cgColor]);
            cell.slider.addTarget(self, action: #selector(self.animationSliderChanged(_:)), for: .valueChanged);
            return cell;
        }
    }
    
    private func didSelectAnimationCell(cell:SelectionSectionCell, indexPath:IndexPath, tableView:UITableView) -> Void {
        let impact = UIImpactFeedbackGenerator(style: .light);
        impact.impactOccurred();
        cell.settingLabel.highlightedTextColor = .orange;
        switch (indexPath.row) {
            case 0:
                if (self.animationSelectedIndex == indexPath.row) { break; }
                self.animationSelectedIndex = 0;
                ARSettings.shared.animationTypeSetting = .grow;
                break;
            case 1:
                if (self.animationSelectedIndex == indexPath.row) { break; }
                self.animationSelectedIndex = 1;
                ARSettings.shared.animationTypeSetting = .fade;
                break;
            default:
                break;
        }
        self.animationSelectedIndex = indexPath.row;
        tableView.reloadRows(at: [IndexPath(row: 0, section: indexPath.section), IndexPath(row: 1, section: indexPath.section)], with: .none);
    }
    
    @objc private func animationSliderChanged(_ sender:UISlider) -> Void {
        ARSettings.shared.animationDuration = Double(sender.value);
    }
    
        
}

class SelectionSectionCell : UITableViewCell {
    
    // MARK: - Member Fields
    
    public static let reuseIdentifier = "selectionSectionCell";
    
    let settingsImageView : UIImageView = {
        let imageView = UIImageView();
        imageView.contentMode = .scaleAspectFit;
        imageView.translatesAutoresizingMaskIntoConstraints = false;
        return imageView;
    }();
    
    let settingLabel : UILabel = {
        let label = UILabel();
        label.textColor = .white;
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium);
        label.textAlignment = .left;
        label.adjustsFontSizeToFitWidth = true;
        label.translatesAutoresizingMaskIntoConstraints = false;
        return label;
    }();
    
    // MARK: - Constructor
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier);
        
        self.backgroundColor = .clear;
        self.selectionStyle = .none;
        
        self.setupConstraints();
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented"); }
    
    // MARK: - Setting Up Constraints
    
    private func setupConstraints() -> Void {
        self.addSubview(self.settingsImageView);
        self.addSubview(self.settingLabel);
        
        // constraints for settingsImageView
        self.settingsImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true;
        self.settingsImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true;
        self.settingsImageView.widthAnchor.constraint(equalToConstant: 20.0).isActive = true;
        self.settingsImageView.heightAnchor.constraint(equalToConstant: 20.0).isActive = true;
        
        // constraints for settingLabel
        self.settingLabel.leadingAnchor.constraint(equalTo: self.settingsImageView.trailingAnchor, constant: 5.0).isActive = true;
        self.settingLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true;
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse();
        self.layoutSubviews();
        self.sizeToFit();
    }
    
}


class SliderSectionCell : UITableViewCell {
    
    // MARK: - Member Fields
    
    public static let reuseIdentifier = "sliderSectionCell";
    
    let settingsImageView : UIImageView = {
        let imageView = UIImageView();
        imageView.contentMode = .scaleAspectFit;
        imageView.translatesAutoresizingMaskIntoConstraints = false;
        return imageView;
    }();
    
    let settingLabel : UILabel = {
        let label = UILabel();
        label.textColor = .white;
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium);
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
    
    let randomButton : UIButton = {
        let button = UIButton();
        button.isHidden = true;
        button.setAttributedTitle(NSAttributedString(string: "Random", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15.0, weight: .bold)]), for: .normal);
        button.setTitleColor(.orange, for: .normal);
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
        self.addSubview(self.settingsImageView);
        self.addSubview(self.settingLabel);
        self.addSubview(self.slider);
        self.addSubview(self.randomButton);
        
        // constraints for settingsImageView
        self.settingsImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true;
        self.settingsImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true;
        self.settingsImageView.widthAnchor.constraint(equalToConstant: 20.0).isActive = true;
        self.settingsImageView.heightAnchor.constraint(equalToConstant: 20.0).isActive = true;
        
        // constraints for settingLabel
        self.settingLabel.leadingAnchor.constraint(equalTo: self.settingsImageView.trailingAnchor, constant: 5.0).isActive = true;
        self.settingLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true;
        
        // constraints for slider
        self.slider.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true;
        self.slider.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true;
        self.slider.leadingAnchor.constraint(equalTo: self.settingLabel.trailingAnchor, constant: 10.0).isActive = true;
        
        // constraints for randomButton
        self.randomButton.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true;
        self.randomButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 5.0).isActive = true;
        self.randomButton.widthAnchor.constraint(equalToConstant: 110.0).isActive = true;
        self.randomButton.heightAnchor.constraint(equalToConstant: 15.0).isActive = true;
        
    }
    
    public func setSlider(slider:UISlider, colors:Array<CGColor>? = nil, stillColor:UIColor? = nil) {
        let tgl = CAGradientLayer();
        let frame = CGRect.init(x: 0, y: 0, width: slider.frame.size.width, height: 5);
        tgl.frame = frame;
        if let stillColor = stillColor {
            tgl.colors = [stillColor.cgColor, stillColor.cgColor, stillColor.cgColor, stillColor.cgColor, stillColor.cgColor];
        } else {
            if let colors = colors {
                tgl.colors = colors;
            }
        }
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
    
    override func prepareForReuse() {
        super.prepareForReuse();
        self.layoutSubviews();
        self.sizeToFit();
    }
    
    
}
