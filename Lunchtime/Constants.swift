//
//  Constants.swift
//  Lunchtime
//
//  Created by Julio Marquez on 1/24/21.
//

import UIKit

enum Constants {
    enum Color {
        case alltrailsGreen

        var colorValue: UIColor {
            switch self {
            case .alltrailsGreen:
                return UIColor(red:0.260, green:0.543, blue:0.075, alpha:1.000)
            }
        }
    }

    enum Symbol: String {
        case emptyHeart = "♡"
        case fullHeart = "♥"
    }
}
