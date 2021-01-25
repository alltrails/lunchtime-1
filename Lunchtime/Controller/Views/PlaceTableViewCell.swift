//
//  PlaceTableViewCell.swift
//  Lunchtime
//
//  Created by Julio Marquez on 1/23/21.
//

import UIKit
import SDWebImage
import CoreLocation

class PlaceTableViewCell: UITableViewCell {

    static let reuseIdentifier: String = "PlaceCellReuseIdentifier"

    //MARK: - Public

    func config(place: PlaceInterface, currentLocation: CLLocation?, isFavorite: Bool) {

        self.place = place

        nameLb.text = place.name
        ratingLb.text = place.ratingString

        let placeLocation = CLLocation(latitude: place.location.latitude, longitude: place.location.longitude)

        let distanceString = placeLocation.getDistanceStringFrom(location: currentLocation)
        priceLb.text = "\(place.priceLevelString)\(distanceString)"

        favoriteBtn.isFavorite = isFavorite

        if let url = URL(string: place.icon) {
            iconView.sd_setImage(with: url, placeholderImage: UIImage(named: "empty"), options: .waitStoreCache, context: nil)
        }
    }

    //MARK: - Initialize

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK: - Private

    private var place: PlaceInterface?

    lazy private var nameLb: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        return label
    }()

    lazy private var ratingLb: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10, weight: .light)
        return label
    }()

    lazy private var priceLb: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10, weight: .light)
        return label
    }()

    lazy private var iconView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()

    lazy private var favoriteBtn: FavoriteBtn = {
        return FavoriteBtn()
    }()

    @objc
    private func didTapFavorite(sender: FavoriteBtn) {
        guard let place = place else { return }
        FavoriteHelper.handleFavorite(placeId: place.placeId)
        favoriteBtn.isFavorite = FavoriteHelper.checkIsFavorite(placeId: place.placeId)
    }

    private func setup() {
        contentView.isUserInteractionEnabled = false

        addSubview(nameLb)
        addSubview(ratingLb)
        addSubview(iconView)
        addSubview(priceLb)
        addSubview(favoriteBtn)

        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.leftAnchor.constraint(equalTo: leftAnchor, constant: 15).isActive = true
        iconView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        iconView.widthAnchor.constraint(equalToConstant: 24).isActive = true
        iconView.heightAnchor.constraint(equalTo: iconView.widthAnchor).isActive = true

        nameLb.translatesAutoresizingMaskIntoConstraints = false
        nameLb.leftAnchor.constraint(equalTo: iconView.rightAnchor, constant: 10).isActive = true
        nameLb.topAnchor.constraint(equalTo: iconView.topAnchor, constant: -5).isActive = true
        nameLb.rightAnchor.constraint(equalTo: favoriteBtn.leftAnchor, constant: -10).isActive = true

        ratingLb.translatesAutoresizingMaskIntoConstraints = false
        ratingLb.leftAnchor.constraint(equalTo: nameLb.leftAnchor).isActive = true
        ratingLb.topAnchor.constraint(equalTo: nameLb.bottomAnchor, constant: 0).isActive = true
        ratingLb.rightAnchor.constraint(equalTo: nameLb.rightAnchor).isActive = true

        priceLb.translatesAutoresizingMaskIntoConstraints = false
        priceLb.leftAnchor.constraint(equalTo: nameLb.leftAnchor).isActive = true
        priceLb.topAnchor.constraint(equalTo: ratingLb.bottomAnchor, constant: 0).isActive = true
        priceLb.rightAnchor.constraint(equalTo: nameLb.rightAnchor).isActive = true

        favoriteBtn.addTarget(self, action: #selector(didTapFavorite(sender:)), for: .touchUpInside)
        favoriteBtn.translatesAutoresizingMaskIntoConstraints = false
        favoriteBtn.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        favoriteBtn.rightAnchor.constraint(equalTo: rightAnchor, constant: -10).isActive = true
        favoriteBtn.widthAnchor.constraint(equalToConstant: 35).isActive = true
    }
}

extension CLLocation {
    func getDistanceStringFrom(location: CLLocation?) -> String {
        guard let location = location else {
            return ""
        }

        let distance = location.distance(from: self)
        let distanceFormatter = MeasurementFormatter()
        let numberFormatter = NumberFormatter()
        numberFormatter.maximumFractionDigits = 2
        distanceFormatter.numberFormatter = numberFormatter
        distanceFormatter.locale = Locale.current
        let measurement = Measurement(value: distance, unit: UnitLength.meters)
        return "﹒\(distanceFormatter.string(from: measurement)) away"
    }
}
