//
//  ApiHelper.swift
//  Lunchtime
//
//  Created by Julio Marquez on 1/23/21.
//

import Foundation
import CoreLocation

class ApiHelper {
    //MARK: - Public

    /// Retrieve restaurants nearby location
    /// - Parameters:
    ///   - query: String to use for the query
    ///   - location: Location passed to use as center to make search
    /// - Returns: Array with PlaceInterface and Error
    static func getRestaurants(query: String? = nil, location: CLLocation, completion: @escaping (([PlaceInterface]?, Error?) -> ())) {
        guard let url = Constants.URL.searchRestaurants(keyword: query, location: location).urlCompoment.url else { return }

        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }

            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase

            do {
                let placeSearchData = try decoder.decode(PlaceSearchModel.self, from: data)
                let places = placeSearchData.results.map({ return PlaceInterface(place: $0) })
                DispatchQueue.main.async {
                    completion(places, nil)
                }
            } catch let e {
                DispatchQueue.main.async {
                    completion(nil, e)
                }
            }

        }.resume()
    }

    //MARK: - Private

    private enum Constants: String {
        case apiKey = "AIzaSyDIKzjfQQCahwJ9yEr8gBU9TqJ3MvbPXyY"
        case urlScheme = "https"
        case host = "maps.googleapis.com"

        enum URLPath: String {
            case nearbySearch = "/maps/api/place/nearbysearch/json"
        }

        enum URL {
            case searchRestaurants(keyword: String?, location: CLLocation)

            var urlCompoment: URLComponents {
                switch self {
                case .searchRestaurants(let keyword, let location):
                    var urlComponent = URLComponents()
                    urlComponent.scheme = Constants.urlScheme.rawValue
                    urlComponent.host = Constants.host.rawValue
                    urlComponent.path = Constants.URLPath.nearbySearch.rawValue

                    var queryItems = [
                        URLQueryItem(name: "location", value: "\(location.coordinate.latitude),\(location.coordinate.longitude)"),
                        URLQueryItem(name: "type", value: "restaurant"),
                        URLQueryItem(name: "rankby", value: "distance"),
                        URLQueryItem(name: "key", value: Constants.apiKey.rawValue)
                    ]

                    if let keyword = keyword {
                        queryItems.append(URLQueryItem(name: "keyword", value: keyword))
                    }

                    urlComponent.queryItems = queryItems
                    return urlComponent
                }
            }
        }
    }
}
