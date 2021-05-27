//
//  NoteEditVC.swift
//  note_Coding_Comrades_iOS
//
//  Created by Sumit Desai on 27/05/21.
//

import UIKit
import MapKit

class NoteEditVC: UIViewController {

    @IBOutlet weak var mapKit: MKMapView!
    
    // MAP - LOCATION VARIABLES
    var locationManager = CLLocationManager() // define location manager
    var currentLocation: CLLocationCoordinate2D? = nil // set current location variable
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // ------------ location manager init -----------
        locationManager.delegate = self // assign location manager delegate
        locationManager.desiredAccuracy = kCLLocationAccuracyBest // define location manager accuracy
        locationManager.requestWhenInUseAuthorization() // define request authorization
        locationManager.startUpdatingLocation() // start updating the location
    }
    
    //*************** MAP HANDLING ******************************
    // creates an annotation depending on the coordinates
    func addAnnotation(coordinate: CLLocationCoordinate2D, title: String, subtitle: String ){
        let annotation = MKPointAnnotation() // creates the point annotation object
        annotation.title = title // sets the annotation title
        annotation.subtitle = subtitle // sets the annotation subtitle
        annotation.coordinate = coordinate // sets the annotation coordinate
        mapKit.addAnnotation(annotation) // adds the annotation to the map
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

extension NoteEditVC : CLLocationManagerDelegate{
    // gets the current location and creates the annotation for it, as well as centers the map into the region closer to the location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation = locations[0] // gets the location of the user
        
        let latitude = userLocation.coordinate.latitude // user latitude
        let longitude = userLocation.coordinate.longitude // user longitude
        
        let latDelta: CLLocationDegrees = 0.2 // latitude delta
        let lngDelta: CLLocationDegrees = 0.2 // longitude delta
        let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lngDelta) // sets the span for the coordinates
        
        currentLocation = CLLocationCoordinate2D(latitude: latitude, longitude: longitude) // sets the current location into the global variable
        
        mapKit.setRegion(MKCoordinateRegion(center: currentLocation!, span: span), animated: true) // sets the region for the map
        
        addAnnotation(coordinate: currentLocation!, title: "Current Location", subtitle: "You are here" ) // sets the annotation
    }
}
