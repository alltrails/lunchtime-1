//
//  Place.swift
//  Lunchtime
//
//  Created by Julio Marquez on 1/23/21.
//

import Foundation
import CoreLocation

struct PlaceSearchModel: Decodable {
    let nextPageToken: String?
    let results: [Place]
    let status: String
    let errorDescription: String?
}

struct Place: Decodable {
    let businessStatus: String?
    let icon: String
    let openingHours: OpenHours?
    let name: String
    let geometry: PlaceGeometry
    let permanentlyClosed: Bool?
    let placeId: String
    let plusCode: [String: String]
    let priceLevel: Int?
    let rating: Double?
    let reference: String
    let scope: String
    let types: [String]
    let userRatingsTotal: Int?
    let vicinity: String
}

struct OpenHours: Codable {
    let openNow: Bool?
}

struct PlaceGeometry: Codable {
    let location: PlaceLocation
}

struct PlaceLocation: Codable {
    let lat: Double
    let lng: Double
}

struct PlaceInterface {

    let businessStatus: String?
    let icon: String
    let name: String
    let location: CLLocationCoordinate2D
    let placeId: String
    let priceLevel: Int?
    let rating: Double?
    let userRatingsTotal: Int?
    let isOpen: Bool
    let address: String
    let permanentlyClosed: Bool?

    var priceLevelString: String {
        var st: String = ""
        for _ in 0...(priceLevel ?? 0) {
            st.append("$")
        }

        return st
    }

    var ratingString: String {
        //★☆
        guard let rating = rating else { return "" }
        var st: String = ""
        for _ in 0..<Int(rating) {
            st.append("★")
        }

        for _ in 0..<(5-Int(rating)) {
            st.append("☆")
        }

        return "\(st) (\(userRatingsTotal ?? 0))"
    }

    init(place: Place) {
        self.businessStatus = place.businessStatus
        self.icon = place.icon
        self.name = place.name
        self.location = CLLocationCoordinate2D(latitude: place.geometry.location.lat, longitude: place.geometry.location.lng)
        self.placeId = place.placeId
        self.priceLevel = place.priceLevel
        self.rating = place.rating
        self.userRatingsTotal = place.userRatingsTotal
        self.address = place.vicinity
        self.isOpen = place.openingHours?.openNow == true
        self.permanentlyClosed = place.permanentlyClosed
    }
}
