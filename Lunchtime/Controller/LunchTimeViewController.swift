//
//  LunchTimeViewController.swift
//  Lunchtime
//
//  Created by Julio Marquez on 1/23/21.
//

import UIKit
import CoreLocation
import MapKit

class LunchTimeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, MKMapViewDelegate, CLLocationManagerDelegate, PlaceDetailViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        configObservers()
        configUI()
    }

    deinit {
        removeObservers()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        handleLocationAuthorization(manager: locationManager)

        selectedAnnotationView?.setSelected(false, animated: true)
        guard let indexPath = selectedIndexPath else { return }
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        locationManager.stopUpdatingLocation()
    }

    //MARK: - TableView Delegate + Datasource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PlaceTableViewCell.reuseIdentifier, for: indexPath)
        if let cell = cell as? PlaceTableViewCell {
            let place = places[indexPath.row]
            let isFavorite = FavoriteHelper.checkIsFavorite(placeId: place.placeId)
            cell.config(place: place, currentLocation: currentLocation, isFavorite: isFavorite)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
        let place = places[indexPath.row]
        presentDetailsFor(place: place)
    }

    //MARK: - DetailViewControllerDelegate

    func didUpdateFavorite() {
        tableView.reloadData()
        tableView.selectRow(at: selectedIndexPath, animated: false, scrollPosition: .none)
    }
    
    //MARK: - MapViewDelegate
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = view.annotation as? LunchAnnotation,
              let place = annotation.place else { return }
        
        selectedAnnotationView = view
        presentDetailsFor(place: place)
    }

    //MARK: - TextFieldDelegate

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchPlace(query: textField.text)
        return true
    }

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    //MARK: - LocationManagerDelegate

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        handleLocationAuthorization(manager: manager)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let newLocation = locations.first {
            if let location = currentLocation {
               if location.distance(from: newLocation) > 100 {
                    currentLocation = newLocation
               }
            } else {
                currentLocation = newLocation
                searchPlace()
            }
        }
    }

    //MARK: - Private

    private var selectedIndexPath: IndexPath?
    private var selectedAnnotationView: MKAnnotationView?
    
    lazy private var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PlaceTableViewCell.self, forCellReuseIdentifier: PlaceTableViewCell.reuseIdentifier)
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 100))
        tableView.tableFooterView = footerView
        tableView.rowHeight = 64
        tableView.keyboardDismissMode = .onDrag
        return tableView
    }()

    lazy private var mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.delegate = self
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "Annot")
        return mapView
    }()

    lazy private var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.searchTextField.delegate = self
        searchBar.placeholder = "Search for a restaurant"
        return searchBar
    }()

    lazy private var toggleBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.backgroundColor = Constants.Color.alltrailsGreen.colorValue
        btn.layer.cornerRadius = 5
        btn.addTarget(self, action: #selector(didTapBtn), for: .touchUpInside)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .heavy)
        btn.setTitle("Map", for: .normal)
        btn.setImage(UIImage(named: "location"), for: .normal)
        btn.imageView?.contentMode = .scaleAspectFit
        btn.tintColor = .white
        btn.imageEdgeInsets = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 10)

        return btn
    }()

    private var loaderView: LoaderView = LoaderView()

    private var places: [PlaceInterface] = []

    private var currentLocation: CLLocation? {
        didSet {
            tableView.reloadData()
        }
    }
    
    private func presentDetailsFor(place: PlaceInterface) {
        let detailViewController = PlaceDetailViewController(place: place)
        detailViewController.delegate = self
        navigationController?.pushViewController(detailViewController, animated: true)
    }

    private func configObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }

    private func removeObservers() {
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
    }

    private func configUI() {
        configNavBar()
        configTableView()
        configMapView()
        configToggleBtn()
        configLoaderView()
    }

    private func configLoaderView() {
        view.addSubview(loaderView)
        loaderView.translatesAutoresizingMaskIntoConstraints = false
        loaderView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        loaderView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        loaderView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        loaderView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }

    private func configNavBar() {
        navigationItem.titleView = searchBar
    }

    private func configTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive =  true
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive =  true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive =  true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive =  true
    }

    private func configMapView() {
        view.addSubview(mapView)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive =  true
        mapView.topAnchor.constraint(equalTo: view.topAnchor).isActive =  true
        mapView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive =  true
        mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive =  true

        mapView.register(MKAnnotationView.self, forAnnotationViewWithReuseIdentifier: "MapCell")
        mapView.isHidden = true
    }

    private func reloadMap() {
        for annotation in mapView.annotations {
            mapView.removeAnnotation(annotation)
        }

        for place in places {
            let pin =  LunchAnnotation()//MKPointAnnotation()
            pin.place = place
            mapView.addAnnotation(pin)
        }

        mapView.showAnnotations(mapView.annotations, animated: false)
    }
    
    private func searchPlace(query: String? = nil) {
        guard let location = currentLocation else { return }
        loaderView.start()
        ApiHelper.getRestaurants(query:query, location: location) { (places, error) in
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            self.loaderView.stop()
            self.toggleBtn.isHidden = false
            guard let places = places,
                  error == nil else {
                //TODO: handle api errors
                print("Error: \(String(describing: error))")
                return
            }

            self.places = places
            self.tableView.reloadData()
            self.reloadMap()
        }
    }

    @objc
    private func didTapBtn() {
        mapView.isHidden = !mapView.isHidden
        let btnTitle: String = mapView.isHidden ? "Map" : "List"
        let btnImage: String = mapView.isHidden ? "location" : "list"
        toggleBtn.setTitle(btnTitle, for: .normal)
        toggleBtn.setImage(UIImage(named: btnImage), for: .normal)
    }

    lazy private var locationManager: CLLocationManager = {
        let locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = 500
        locationManager.allowsBackgroundLocationUpdates = false
        locationManager.distanceFilter = 500
        return locationManager
    }()

    private func configToggleBtn() {
        view.addSubview(toggleBtn)
        toggleBtn.isHidden = true
        toggleBtn.translatesAutoresizingMaskIntoConstraints = false
        toggleBtn.widthAnchor.constraint(equalToConstant: 100).isActive = true
        toggleBtn.heightAnchor.constraint(equalToConstant: 44).isActive = true
        toggleBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        toggleBtn.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30).isActive = true
    }

    private var locationAlertController: UIAlertController = {
        let locationAlertController = UIAlertController(title: "Location Error", message: "Lunchtime needs your current location to work, please enable permissions.", preferredStyle: .alert)
        locationAlertController.addAction(UIAlertAction(title: "Settings", style: .default, handler: { (alert) in
            UIApplication.shared.openDeviceSettings()

        }))
        locationAlertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (alert) in

        }))



        return locationAlertController
    }()

    private func handleLocationAuthorization(manager: CLLocationManager) {
        let enabled = manager.authorizationStatus == .authorizedAlways || manager.authorizationStatus == .authorizedWhenInUse

        if enabled {
            locationManager.startUpdatingLocation()
            presentingModal = false
            locationAlertController.dismiss(animated: false)
        } else {
            currentLocation = nil
            if !presentingModal {
                presentingModal = true
                present(locationAlertController, animated: true, completion: nil)
            }
        }
    }

    private var presentingModal = false

    @objc
    private func appMovedToBackground() {
        locationManager.stopUpdatingLocation()
        locationAlertController.dismiss(animated: false)
        presentingModal = false
    }

    @objc
    private func appMovedToForeground() {
        handleLocationAuthorization(manager: locationManager)
    }
}

extension UIApplication {

    @objc
    public func openDeviceSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
            return
        }

        guard canOpenURL(settingsURL) else {
           return
        }

        open(settingsURL, options: [:], completionHandler: nil)
    }
}
