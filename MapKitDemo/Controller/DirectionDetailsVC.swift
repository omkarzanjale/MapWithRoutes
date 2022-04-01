//
//  DirectionDetailsVC.swift
//  MapKitDemo
//
//  Created by Admin on 22/03/22.
//
import UIKit
import MapKit

protocol DirectionProtocol: AnyObject {
    func directionDetails(sourcePoint: String, distinationPoint: String, transportType: String)
    func closeDirection()
}

class DirectionDetailsVC: UIViewController {

    @IBOutlet weak var segTransportType: UISegmentedControl!
    @IBOutlet weak var tfSourcePoint: UITextField!
    @IBOutlet weak var tfDistinationPoint: UITextField!
    @IBOutlet weak var suggestionsTableView: UITableView!
    var resultSearchController:UISearchController? = nil
    var currentLocation: CLLocationCoordinate2D?
    lazy var mapViewModel = MapViewModel()
    var selectedTextfield: UITextField?
    var selectedSeg = "Walking"
    var matchingItems = [MKMapItem]()
    weak var delegate: DirectionProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        config()
    }
    
    private func config() {
        self.tfSourcePoint.delegate = self
        self.tfDistinationPoint.delegate = self
        resultSearchController = UISearchController(searchResultsController: self)
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        definesPresentationContext = true
        resultSearchController?.searchResultsUpdater = self
    }
    //
    //MARK: Button Actions
    //
    @IBAction func closeBtnAction(_ sender: Any) {
        self.delegate?.closeDirection()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func currentLocBtnAction(_ sender: Any) {
        guard let location = currentLocation else {return}
        self.tfSourcePoint.text = "\(location.latitude) \(location.longitude)"
        mapViewModel.getAddress(coordnates: location) { address in
            guard let address = address else {
                return
            }
            self.tfSourcePoint.text = "\(address.name) \(address.city)"
        }
    }
    
    @IBAction func directionBtnAction(_ sender: Any) {
        delegate?.directionDetails(sourcePoint: tfSourcePoint.text ?? "", distinationPoint: tfDistinationPoint.text ?? "", transportType: selectedSeg)
        self.dismiss(animated: true)
    }
    
    @IBAction func transportTypeSegAction(_ sender: Any) {
        if segTransportType.selectedSegmentIndex == 0 {
            selectedSeg = "walking"
        }else {
            selectedSeg = "automobile"
        }
    }
}
//
//MARK: Search Suggestions
//
extension DirectionDetailsVC : UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchBarText = searchController.searchBar.text else { return }
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchBarText
        let search = MKLocalSearch(request: request)
        search.start { [weak self] response, error in
            guard let response = response else {return}
            self?.matchingItems = response.mapItems
            self?.suggestionsTableView.reloadData()
        }
    }
}
//
//MARK: UITextFieldDelegate
//
extension DirectionDetailsVC: UITextFieldDelegate{

    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField.text == "" {
            print("please enter text")
        }else {
            self.selectedTextfield = textField
            resultSearchController?.searchBar.text = textField.text
        }
    }
}
//
//MARK: UITableViewDataSource
//
extension DirectionDetailsVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        matchingItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = suggestionsTableView.dequeueReusableCell(withIdentifier: "Cell")
        let matchItem = matchingItems[indexPath.row]
        cell?.textLabel?.text = matchItem.name
        return cell!
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        "Suggestions"
    }
}
//
//MARK: UITableViewDelegate
//
extension DirectionDetailsVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = matchingItems[indexPath.row]
        if selectedTextfield == tfSourcePoint{
            self.tfSourcePoint.text = selectedItem.name
        } else {
            self.tfDistinationPoint.text = selectedItem.name
        }
    }
}
