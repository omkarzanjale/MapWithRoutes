//
//  MapViewModel.swift
//  MapKitDemo
//
//  Created by Admin on 22/03/22.
//

import Foundation
import MapKit

class MapViewModel {
    
    func searchBaseOn(name: String, complisherHandler: @escaping (CLLocationCoordinate2D)->()) {
        let localSearchRequest = MKLocalSearch.Request()
        localSearchRequest.naturalLanguageQuery = name
        let localSearch = MKLocalSearch(request: localSearchRequest)
        localSearch.start { response, error in
            guard error == nil else {return}
            guard let response = response else {return}
            let coordinate = CLLocationCoordinate2D(latitude: response.boundingRegion.center.latitude, longitude: response.boundingRegion.center.longitude)
            complisherHandler(coordinate)
        }
    }
    
    
    //
    //MARK: Show Route
    //
    func showRouteOnMap(pickupCoordinate: CLLocationCoordinate2D, destinationCoordinate: CLLocationCoordinate2D, complesherHandler: @escaping ([MKRoute])->()) {
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: pickupCoordinate, addressDictionary: nil))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destinationCoordinate, addressDictionary: nil))
        request.requestsAlternateRoutes = true
        request.transportType = .automobile
        
        let directions = MKDirections(request: request)
        
        directions.calculate { response, error in
            guard let unwrappedResponse = response else { return }
            complesherHandler(unwrappedResponse.routes)
        }
    }
    //
    //MARK: Get Address
    //
    func getAddress(coordnates: CLLocationCoordinate2D, complisherHandler:@escaping(Address?)->()  ) {
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: coordnates.latitude, longitude: coordnates.longitude)
        geoCoder.reverseGeocodeLocation(location, completionHandler:
                                            { placemarks, error -> Void in
            guard let placeMark = placemarks?.first else { return }
            if placeMark.isoCountryCode == "IN"{
                let address = Address(placeMark: placeMark.name ?? "-", country: placeMark.country ?? "-", city: placeMark.subAdministrativeArea ?? "-", zipCode: placeMark.isoCountryCode ?? "-")
                complisherHandler(address)
            }else {
                complisherHandler(nil)
            }
            
        })
    }
}
