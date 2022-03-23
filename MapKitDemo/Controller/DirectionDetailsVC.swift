//
//  DirectionDetailsVC.swift
//  MapKitDemo
//
//  Created by Admin on 22/03/22.
//

import UIKit
protocol DirectionProtocol: AnyObject {
    func directionDetails(sourcePoint: String, distinationPoint: String)
}
class DirectionDetailsVC: UIViewController {

    @IBOutlet weak var tfSourcePoint: UITextField!
    @IBOutlet weak var tfDistinationPoint: UITextField!
    
    weak var delegate: DirectionProtocol?
    var mapViewModel = MapViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func directionBtnAction(_ sender: Any) {
        delegate?.directionDetails(sourcePoint: tfSourcePoint.text ?? "", distinationPoint: tfDistinationPoint.text ?? "")
        self.dismiss(animated: true)
    }
    
}


