//
//  FavoriteController.swift
//  Lunchtime
//
//  Created by Julio Marquez on 1/24/21.
//

import Foundation

class FavoriteHelper {

    /// Store placeId in our Favorite Dictionary
    /// - Parameter placeId: String representing a Place
    static public func addToFavorites(placeId: String) {
        var list = FavoriteHelper.favoriteList
        list[placeId] = placeId
        FavoriteHelper.favoriteList = list
    }

    /// Remove placeId from our Favorite Dictionary
    /// - Parameter placeId: String representing a Place
    static public func removeFromFavorites(placeId: String) {
        var list = FavoriteHelper.favoriteList
        list.removeValue(forKey: placeId)
        FavoriteHelper.favoriteList = list
    }

    /// Determines if a place is currently favorite
    /// - Parameter placeId: String representing a Place
    /// - Returns: Bool status of place as favorite
    static public func checkIsFavorite(placeId: String) -> Bool {
        let list = FavoriteHelper.favoriteList
        return list[placeId] != nil
    }

    /// Handle a place Id, if its favorited will unfavorite and vice versa
    /// - Parameter placeId: String representing a Place
    static public func handleFavorite(placeId: String) {
        if FavoriteHelper.checkIsFavorite(placeId: placeId) {
            FavoriteHelper.removeFromFavorites(placeId: placeId)
        } else {
            FavoriteHelper.addToFavorites(placeId: placeId)
        }
    }

    static private var favoriteList: [String: String] {
        get {
            guard let favorites = UserDefaults.standard.value(forKey: Constants.Key.favorites.rawValue) as? [String: String] else { return [:] }
            return favorites
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: Constants.Key.favorites.rawValue)
        }
    }

    private enum Constants {
        enum Key: String {
            case favorites = "LunchTimeFavoritesKey"
        }
    }
}
