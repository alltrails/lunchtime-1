//
//  PlaceDetailViewController.swift
//  Lunchtime
//
//  Created by Julio Marquez on 1/24/21.
//

import UIKit
import MapKit

protocol PlaceDetailViewControllerDelegate: NSObjectProtocol {
    func didUpdateFavorite()
}

class PlaceDetailViewController: UIViewController {

    weak public var delegate: PlaceDetailViewControllerDelegate?

    //MARK: - Initializer

    convenience init(place: PlaceInterface, currentLocation: CLLocation? = nil) {
        self.init()
        self.place = place
        configUI()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        print("\(String(describing: place))")
    }

    private var place: PlaceInterface?

    private var currentLocation: CLLocation?

    lazy private var nameLb: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        return label
    }()

    lazy private var ratingLb: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.numberOfLines = 0
        return label
    }()

    lazy private var priceLb: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        return label
    }()

    lazy private var iconView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()

    lazy private var openLb: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24, weight: .black)
        label.textAlignment = .center
        label.textColor = .white
        label.layer.cornerRadius = 4
        label.clipsToBounds = true
        label.backgroundColor = Constants.Color.alltrailsGreen.colorValue

        return label
    }()

    lazy private var mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.layer.cornerRadius = 10
        mapView.layer.borderWidth = 0.75
        mapView.layer.borderColor = UIColor.black.cgColor
        mapView.clipsToBounds = true
        return mapView
    }()

    private func configUI() {
        guard let place = place else { return }
        navigationItem.title = place.name
        let isFavorite = FavoriteHelper.checkIsFavorite(placeId: place.placeId)
        let favoriteBtn = FavoriteBarBtn(isFavorite: isFavorite, target: self, action: #selector(didTapFavorite(sender:)))
        navigationItem.rightBarButtonItem = favoriteBtn

        let pin = MKPointAnnotation()
        pin.title = place.name
        pin.coordinate = CLLocationCoordinate2D(latitude: place.location.latitude, longitude: place.location.longitude)
        mapView.addAnnotation(pin)
        mapView.showAnnotations(mapView.annotations, animated: false)

        view.addSubview(mapView)
        view.addSubview(ratingLb)
        view.addSubview(iconView)
        view.addSubview(priceLb)
        view.addSubview(openLb)

        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true
        mapView.topAnchor.constraint(equalToSystemSpacingBelow:view.topAnchor , multiplier: 15).isActive = true
        mapView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15).isActive = true
        mapView.heightAnchor.constraint(equalToConstant: view.frame.height * 0.3).isActive = true

        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.centerXAnchor.constraint(equalTo: mapView.centerXAnchor, constant: 0).isActive = true
        iconView.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: 20).isActive = true
        iconView.widthAnchor.constraint(equalToConstant: 42).isActive = true
        iconView.heightAnchor.constraint(equalTo: iconView.widthAnchor).isActive = true

        ratingLb.translatesAutoresizingMaskIntoConstraints = false
        ratingLb.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true
        ratingLb.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 20).isActive = true
        ratingLb.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15).isActive = true

        priceLb.translatesAutoresizingMaskIntoConstraints = false
        priceLb.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        priceLb.topAnchor.constraint(equalTo: ratingLb.bottomAnchor, constant: 20).isActive = true
        priceLb.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true

        openLb.translatesAutoresizingMaskIntoConstraints = false
        openLb.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true
        openLb.topAnchor.constraint(equalTo: priceLb.bottomAnchor, constant: 20).isActive = true
        openLb.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15).isActive = true
        openLb.heightAnchor.constraint(equalToConstant: 44).isActive = true

        nameLb.text = place.name
        ratingLb.text = "\(place.address)\n\(place.ratingString)"

        let placeLocation = CLLocation(latitude: place.location.latitude, longitude: place.location.longitude)

        let distanceString = placeLocation.getDistanceStringFrom(location: currentLocation)
        priceLb.text = "\(place.priceLevelString)\(distanceString)"

        favoriteBtn.isFavorite = isFavorite

        let openLbString: String
        let openLbColor: UIColor
        if place.permanentlyClosed == true {
            openLbString = "Permanently closed "
            openLbColor = .red
        } else if place.isOpen {
            openLbString = "Open "
            openLbColor = Constants.Color.alltrailsGreen.colorValue
        } else {
            openLbString = "Closed"
            openLbColor = .systemRed
        }

        openLb.text = openLbString
        openLb.backgroundColor = openLbColor

        if let url = URL(string: place.icon) {
            iconView.sd_setImage(with: url, placeholderImage: UIImage(named: ""), options: .waitStoreCache, context: nil)
        }
    }

    @objc
    private func didTapFavorite(sender: FavoriteBtn) {
        guard let place = place else { return }
        FavoriteHelper.handleFavorite(placeId: place.placeId)
        sender.isFavorite = FavoriteHelper.checkIsFavorite(placeId: place.placeId)
        delegate?.didUpdateFavorite()
    }
}

