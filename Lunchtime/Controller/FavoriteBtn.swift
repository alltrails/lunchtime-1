//
//  FavoriteBtn.swift
//  Lunchtime
//
//  Created by Julio Marquez on 1/25/21.
//

import UIKit

class FavoriteBarBtn: UIBarButtonItem {
    var isFavorite: Bool = false {
        didSet {
            title = isFavorite ? Constants.Symbol.fullHeart.rawValue : Constants.Symbol.emptyHeart.rawValue
        }
    }

    init(isFavorite: Bool, target: AnyObject?, action:Selector?) {
        super.init()
        self.title = isFavorite ? Constants.Symbol.fullHeart.rawValue : Constants.Symbol.emptyHeart.rawValue
        self.action = action
        self.target = target
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class FavoriteBtn: UIButton {
    var isFavorite: Bool = false {
        didSet {
            let title = isFavorite ? Constants.Symbol.fullHeart.rawValue : Constants.Symbol.emptyHeart.rawValue
            let color: UIColor = isFavorite ? .red : .lightGray
            setTitle(title, for: .normal)
            self.setTitleColor(color, for: .normal)
        }
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
