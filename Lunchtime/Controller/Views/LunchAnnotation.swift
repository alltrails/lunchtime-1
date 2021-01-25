//
//  LunchAnnotation.swift
//  Lunchtime
//
//  Created by Julio Marquez Garcia on 1/25/21.
//

import MapKit

class LunchAnnotation: MKPointAnnotation {
    var place: PlaceInterface? {
        didSet {
            guard let place = place else { return }
            title = place.name
            coordinate = CLLocationCoordinate2D(latitude: place.location.latitude, longitude: place.location.longitude)
        }
    }
}
