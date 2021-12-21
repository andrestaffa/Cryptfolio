//
//  AvatarImage.swift
//  Cryptfolio
//
//  Created by Andre Staffa on 2021-12-19.
//  Copyright © 2021 Andre Staffa. All rights reserved.
//

import Foundation;
import UIKit;

public class AvatarImage : UIImageView {
	
	private var imagePicker:ImagePicker?;
	
	public let avatarEditImageView : UIImageView = {
		let imageView = UIImageView();
		imageView.image = UIImage(named: "avatar_edit")?.withRenderingMode(.alwaysTemplate);
		imageView.tintColor = .orange;
		imageView.contentMode = .scaleAspectFill;
		imageView.clipsToBounds = true;
		imageView.isUserInteractionEnabled = true;
		imageView.translatesAutoresizingMaskIntoConstraints = false;
		return imageView;
	}();
	
	
	public func initialize() -> Void {
		self.image = UIImage(named: "avatar_image");
		self.contentMode = .scaleAspectFill;
		self.clipsToBounds = true;
		self.isUserInteractionEnabled = true;
		self.translatesAutoresizingMaskIntoConstraints = false;
		self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.avatarImageTapped)));
	}
	
	@objc private func avatarImageTapped() -> Void {
		self.vibrate(style: .light);
		self.imagePicker?.present(from: self);
	}
	
	
	public func initializeWith(view:UIView) -> Void {
		self.setupConstraints(view: view);
	}
	
	public func circleize() -> Void {
		self.layer.cornerRadius = self.frame.width / 2;
		self.layer.masksToBounds = true;
	}
	
	public func setImagePickerDelegate(vc:UIViewController, delegate:ImagePickerDelegate) {
		self.imagePicker = ImagePicker(presentationController: vc, delegate: delegate);
	}
	
	private func setupConstraints(view:UIView) -> Void {
		view.addSubview(self.avatarEditImageView);
		
		self.avatarEditImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true;
		self.avatarEditImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5.0).isActive = true;
		self.avatarEditImageView.widthAnchor.constraint(equalToConstant: 22).isActive = true;
		self.avatarEditImageView.heightAnchor.constraint(equalToConstant: 22).isActive = true;
	}
	
	private func vibrate(style: UIImpactFeedbackGenerator.FeedbackStyle) {
		let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .light);
		impactFeedbackGenerator.impactOccurred()
	}
	
}

// MARK: Image Picker Class

public protocol ImagePickerDelegate: AnyObject {
	func didSelect(image: UIImage?);
}

open class ImagePicker: NSObject {

	private let pickerController: UIImagePickerController;
	private weak var presentationController: UIViewController?;
	private weak var delegate: ImagePickerDelegate?;

	public init(presentationController: UIViewController, delegate: ImagePickerDelegate) {
		self.pickerController = UIImagePickerController();

		super.init();

		self.presentationController = presentationController;
		self.delegate = delegate;

		self.pickerController.delegate = self;
		self.pickerController.allowsEditing = true;
		self.pickerController.mediaTypes = ["public.image"];
	}

	private func action(for type: UIImagePickerController.SourceType, title: String) -> UIAlertAction? {
		guard UIImagePickerController.isSourceTypeAvailable(type) else {
			return nil;
		}

		return UIAlertAction(title: title, style: .default) { [unowned self] _ in
			self.pickerController.sourceType = type;
			self.presentationController?.present(self.pickerController, animated: true);
		}
	}

	public func present(from sourceView: UIView) {

		let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet);

		if let action = self.action(for: .camera, title: "Take photo") {
			alertController.addAction(action);
		}
		if let action = self.action(for: .savedPhotosAlbum, title: "Camera roll") {
			alertController.addAction(action);
		}
		if let action = self.action(for: .photoLibrary, title: "Photo library") {
			alertController.addAction(action);
		}

		alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil));

		if UIDevice.current.userInterfaceIdiom == .pad {
			alertController.popoverPresentationController?.sourceView = sourceView;
			alertController.popoverPresentationController?.sourceRect = sourceView.bounds;
			alertController.popoverPresentationController?.permittedArrowDirections = [.down, .up];
		}

		self.presentationController?.present(alertController, animated: true);
	}

	private func pickerController(_ controller: UIImagePickerController, didSelect image: UIImage?) {
		controller.dismiss(animated: true, completion: nil);

		self.delegate?.didSelect(image: image);
	}
}

extension ImagePicker: UIImagePickerControllerDelegate {

	public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		self.pickerController(picker, didSelect: nil);
	}

	public func imagePickerController(_ picker: UIImagePickerController,
									  didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
		guard let image = info[.editedImage] as? UIImage else {
			return self.pickerController(picker, didSelect: nil);
		}
		self.pickerController(picker, didSelect: image);
	}
}

extension ImagePicker: UINavigationControllerDelegate {}
