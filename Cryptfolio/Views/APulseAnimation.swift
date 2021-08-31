//
//  APulseAnimation.swift
//  Cryptfolio
//
//  Created by Andre Staffa on 2021-08-29.
//  Copyright © 2021 Andre Staffa. All rights reserved.
//

import Foundation;
import UIKit;

class APulseAnimation : CALayer {
	
	private var animationGroup = CAAnimationGroup();
	private var animationDuration:TimeInterval = 1.5;
	private var radius:CGFloat = 50;
	private var numberOfPulses:Float = Float.infinity;
	
	override init(layer: Any) {
		super.init(layer: layer);
	}
	required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented"); }
	
	init(radius:CGFloat, numberOfPulses:Float = Float.infinity, position:CGPoint) {
		super.init();
		self.backgroundColor = UIColor.black.cgColor;
		self.contentsScale = UIScreen.main.scale;
		self.opacity = 0;
		self.radius = radius;
		self.numberOfPulses = numberOfPulses;
		self.position = position;
		
		self.bounds = CGRect(x: 0, y: 0, width: radius * 2, height: radius * 2);
		self.cornerRadius = radius;
		
		DispatchQueue.global(qos: .default).async {
			self.setupAnimationGroup();
			DispatchQueue.main.async {
				self.add(self.animationGroup, forKey: "pulse");
			}
		}
		
	}
	
	private func scaleAnimation() -> CABasicAnimation {
		let scaleAnimation = CABasicAnimation(keyPath: "transform.scale.xy");
		scaleAnimation.fromValue = NSNumber(value: 0);
		scaleAnimation.toValue = NSNumber(value: 1);
		scaleAnimation.duration = self.animationDuration;
		return scaleAnimation;
	}
	
	private func opacityAnimation() -> CAKeyframeAnimation {
		let opacityAnimation = CAKeyframeAnimation(keyPath: "opacity");
		opacityAnimation.duration = self.animationDuration;
		opacityAnimation.keyTimes = [0, 0.3, 1];
		opacityAnimation.values = [0.4, 0.8, 0];
		return opacityAnimation;
	}
	
	private func setupAnimationGroup() -> Void {
		self.animationGroup.duration = self.animationDuration;
		self.animationGroup.repeatCount = self.numberOfPulses;
		self.animationGroup.timingFunction = CAMediaTimingFunction(name: .default);
		self.animationGroup.animations = [self.scaleAnimation(), self.opacityAnimation()];
	}
	
}
