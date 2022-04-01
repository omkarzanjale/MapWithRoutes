//`
//  ViewController.swift
//  MapKitDemo
//
//  Created by Admin on 11/03/22.
//

import UIKit
import MapKit
import CoreLocation
import GooglePlaces
import Toast_Swift

enum RouteColor:Int {
    case red,blue,green,purple
    var selectedColor: UIColor{
        switch self {
        case .red:
            return UIColor.red
        case .blue:
            return UIColor.blue
        case .green:
            return UIColor.green
        case .purple:
            return UIColor.purple
        }
    }
}

class HomeVC: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var titleSubtitleView: UIView!
    @IBOutlet weak var directionDetailsView: UIView!
    @IBOutlet weak var pin: UIImageView!
    @IBOutlet weak var lblSource: UILabel!
    @IBOutlet weak var lblDistination: UILabel!
    @IBOutlet weak var lblPinTitle: UILabel!
    @IBOutlet weak var lblPinSubtitle: UILabel!
    @IBOutlet weak var lblDistance: UILabel!
    @IBOutlet weak var img: UIImageView!
    lazy var locationManager = CLLocationManager()
    lazy var currentLocation = CLLocationCoordinate2D()
    lazy var autoCompleteController = GMSAutocompleteViewController()
    var mapViewModel = MapViewModel()
    var isPinTapped = false
    var transportType = "Walking"
    var routeColor: RouteColor?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        img.transform = CGAffineTransform(scaleX: -2, y: 1);
        config()
    }
    
    private func config() {
        self.titleSubtitleView.isHidden = true
        self.directionDetailsView.isHidden = true
        mapView.delegate = self
        if ((lblAddress.text?.isEmpty) != nil){
            self.lblAddress.isHidden = true
        }
    
        //Map tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureAction))
        self.mapView.addGestureRecognizer(tapGesture)
        //Pin tap gesture
        pin.isUserInteractionEnabled = true
        pin.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(pinTapped)))
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        if (CLLocationManager.locationServicesEnabled()){
            locationManager.startUpdatingLocation()
        }
    }
    //
    //MARK: Button Actions
    //
    @IBAction func searchBtnAction(_ sender: Any) {
        self.view.makeToast("Add API Key first!")
        autoCompleteController.delegate = self
        let fields = GMSPlaceField(rawValue: UInt(GMSPlaceField.name.rawValue) | UInt(GMSPlaceField.placeID.rawValue))
        autoCompleteController.placeFields = fields
        
        let filter = GMSAutocompleteFilter()
        filter.type = .noFilter
        filter.country = "IN"
        autoCompleteController.autocompleteFilter = filter
        
        present(autoCompleteController, animated: true)
    }
    
    @IBAction func directionBtnAction(_ sender: Any) {
        let directionDetailsVC = storyboard?.instantiateViewController(withIdentifier: "DirectionDetailsVC") as! DirectionDetailsVC
        directionDetailsVC.delegate = self
        directionDetailsVC.currentLocation = currentLocation
        self.present(directionDetailsVC, animated: true)
    }
    
    @IBAction func currentLocBtnAction(_ sender: Any) {
        self.setPinUsingMKPointAnnotation(location: self.currentLocation)
    }
    
    @objc func tapGestureAction(sender: UIGestureRecognizer) {
        let locFromTap = sender.location(in: mapView)
        let coordinatesOnMap = mapView.convert(locFromTap, toCoordinateFrom: mapView)
        self.setPinUsingMKPointAnnotation(location: coordinatesOnMap)
    }
    
    @objc private func pinTapped(_ recognizer: UITapGestureRecognizer) {
        self.isPinTapped = !isPinTapped
        if isPinTapped {
            self.titleSubtitleView.isHidden = false
        }else {
            self.titleSubtitleView.isHidden = true
        }
    }
}
//
//MARK: MKMapViewDelegate
//
extension HomeVC: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if routeColor == nil {
            let center = mapView.centerCoordinate
            let queue1 = DispatchQueue.global(qos: .background)
            queue1.async {
                self.mapViewModel.getAddress(coordnates: center) { address in
                    if let address = address {
                        self.pin.isHidden = false
                        self.lblAddress.isHidden = false
                        self.lblAddress.text = address.fullAddress
                        self.lblPinTitle.text = address.name
                        self.lblPinSubtitle.text = address.city
                    }else{
                        self.lblAddress.isHidden = true
                        self.view.makeToast("Location out of INDIA!")
                    }
                }
            }
        }else {
            self.pin.isHidden = true
            self.lblAddress.isHidden = true
        }
    }
    //
    //MARK: Render route line
    //
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = self.routeColor?.selectedColor
        renderer.lineWidth = 5.0
        if transportType == "Walking" {
            renderer.lineDashPattern = [0, 10]
        }
        return renderer
    }
}

extension HomeVC: CLLocationManagerDelegate {
    //
    //MARK: Get current Location
    //
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last{
            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            self.currentLocation = center
        }
    }
}

extension HomeVC {
    //MARK: Set Pin
    private func setCustomPin(location: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        mapView.addAnnotation(annotation)
    }
    
    func setPinUsingMKPointAnnotation(location: CLLocationCoordinate2D){
        self.mapViewModel.getAddress(coordnates: location) { address in
            if let address = address {
                self.lblAddress.isHidden = false
                self.lblAddress.text = address.fullAddress
                self.lblPinTitle.text = address.name
                self.lblPinSubtitle.text = address.city
                let coordinateRegion = MKCoordinateRegion(center: location, latitudinalMeters: 800, longitudinalMeters: 800)
                self.mapView.setRegion(coordinateRegion, animated: true)
            }else {
                self.lblAddress.isHidden = true
                self.view.makeToast("Location out of INDIA!")
            }
        }
    }
}
//
//MARK: GMSAutocompleteViewControllerDelegate
//
extension HomeVC: GMSAutocompleteViewControllerDelegate{
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        self.mapViewModel.searchBaseOn(name: place.name ?? "") {[weak self] coordinate in
            self?.setPinUsingMKPointAnnotation(location: coordinate)
            self?.dismiss(animated: true)
        }
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true)
    }
}
//
//MARK: Map Routes
//
extension HomeVC: DirectionProtocol {
    
    private func displayRoutes(_ routes: [MKRoute]) {
        for i in 0..<routes.count {
            self.routeColor = RouteColor(rawValue: i) ?? .red
            self.mapView.addOverlay(routes[i].polyline)
            self.mapView.setVisibleMapRect(routes[i].polyline.boundingMapRect, edgePadding: UIEdgeInsets(top: 100, left: 100, bottom: 100, right: 100), animated: true)
        }
    }
    
    func closeDirection() {
        self.routeColor = nil
        self.pin.isHidden = false
        self.directionDetailsView.isHidden = true
        self.mapView.removeOverlays(mapView.overlays)
        for previousAnnotation in mapView.annotations {
            mapView.removeAnnotation(previousAnnotation)
        }
    }
    
    private func calculateDistance(startPoint: CLLocationCoordinate2D, endPoint: CLLocationCoordinate2D) {
        let start = CLLocation(latitude: startPoint.latitude, longitude: startPoint.longitude)
        let distination = CLLocation(latitude: endPoint.latitude, longitude: endPoint.longitude)
        let distance = start.distance(from: distination)
        let result = Double(distance) / 1000
        let y = Double(round(10 * result)) / 10
        self.lblDistance.text = String(y) + " km"
    }
    
    func directionDetails(sourcePoint: String, distinationPoint: String,transportType: String) {
        self.directionDetailsView.isHidden = false
        self.transportType = transportType
        self.mapView.removeOverlays(mapView.overlays)
        for previousAnnotation in mapView.annotations {
            mapView.removeAnnotation(previousAnnotation)
        }
        mapViewModel.searchBaseOn(name: sourcePoint){ [weak self] sourceCoordinates in
            self?.setCustomPin(location: sourceCoordinates)
            self?.mapViewModel.searchBaseOn(name: distinationPoint) { distinationCoordinates in
                self?.setCustomPin(location: distinationCoordinates)
                self?.calculateDistance(startPoint: sourceCoordinates, endPoint: distinationCoordinates)
                self?.lblSource.text = sourcePoint
                self?.lblDistination.text = distinationPoint
                if transportType == "Walking" {
                    self?.mapViewModel.showRouteOnMap(pickupCoordinate: sourceCoordinates, destinationCoordinate: distinationCoordinates, transportType: .walking, complesherHandler: { routes in
                        self?.displayRoutes(routes)
                    })
                }else {
                    self?.mapViewModel.showRouteOnMap(pickupCoordinate: sourceCoordinates, destinationCoordinate: distinationCoordinates, transportType: .automobile, complesherHandler: { routes in
                        self?.displayRoutes(routes)
                    })
                }
                
            }
        }
    }
}
