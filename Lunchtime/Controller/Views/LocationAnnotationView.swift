//
//  LocationAnnotationView.swift
//  Lunchtime
//
//  Created by Julio Marquez on 1/24/21.
//

import UIKit
import MapKit

final class LocationAnnotationView: MKAnnotationView {

    // MARK: - Initialization

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)

        frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        centerOffset = CGPoint(x: 0, y: -frame.size.height / 2)

        canShowCallout = true
        setupUI()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private

    private func setupUI() {
        backgroundColor = .clear

        let view = UIView()
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        view.backgroundColor = .orange
        addSubview(view)

        view.frame = bounds

        let accView = UIView(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        accView.backgroundColor = .purple
        accView.layer.cornerRadius = 12
        accView.clipsToBounds = true
        detailCalloutAccessoryView = accView
    }
}
