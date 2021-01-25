//
//  LoaderView.swift
//  Lunchtime
//
//  Created by Julio Marquez on 1/24/21.
//

import UIKit

class LoaderView: UIImageView {

    //MARK: - Public

    public func start() {
        startAnimation()
    }

    public func stop() {
        stopAnimation()
    }

    //MARK: - Initializer

    public init() {
        super.init(image: UIImage(named: "lunchbox"))
        contentMode = .center
        backgroundColor = .gray
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK: - Private

    private func startAnimation() {
        isHidden = false
        let pulse = CASpringAnimation(keyPath: "transform.scale")
        pulse.duration = 0.4
        pulse.fromValue = 1.0
        pulse.toValue = 1.12
        pulse.autoreverses = true
        pulse.repeatCount = .infinity
        pulse.initialVelocity = 0.5
        pulse.damping = 0.8
        self.layer.add(pulse, forKey: nil)
    }

    private func stopAnimation() {
        self.layer.removeAllAnimations()
        isHidden = true
    }
}
