//
//  NoteEditVC.swift
//  note_Coding_Comrades_iOS
//
//  Created by Sumit Desai on 27/05/21.
//

import UIKit
import MapKit

class NoteEditVC: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var mapKit: MKMapView!
    
    // MAP - LOCATION VARIABLES
    var locationManager = CLLocationManager() // define location manager
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // ------------ location manager init -----------
        locationManager.delegate = self // assign location manager delegate
        locationManager.desiredAccuracy = kCLLocationAccuracyBest // define location manager accuracy
        locationManager.requestWhenInUseAuthorization() // define request authorization
        locationManager.startUpdatingLocation() // start updating the location
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
