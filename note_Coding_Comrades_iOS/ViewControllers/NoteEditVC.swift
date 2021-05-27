//
//  NoteEditVC.swift
//  note_Coding_Comrades_iOS
//
//  Created by Sumit Desai on 27/05/21.
//

import UIKit
import MapKit
import AVFoundation

class NoteEditVC: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate, AVAudioRecorderDelegate {
    
    @IBOutlet weak var mapKit: MKMapView!
    @IBOutlet weak var notePictureImg: UIImageView!
    
    // AUDIO VARIABLES
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    
    // MAP - LOCATION VARIABLES
    var locationManager = CLLocationManager() // define location manager
    var currentLocation: CLLocationCoordinate2D? = nil // set current location variable
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        mapKit.showsUserLocation = false // show user location
        mapKit.isZoomEnabled = false// disable zoom
        
        // ------------ location manager init -----------
        locationManager.delegate = self // assign location manager delegate
        mapKit.delegate = self // this class handles the delegate mapkit
        locationManager.desiredAccuracy = kCLLocationAccuracyBest // define location manager accuracy
        locationManager.requestWhenInUseAuthorization() // define request authorization
        locationManager.startUpdatingLocation() // start updating the location
        
        recordingSession = AVAudioSession.sharedInstance()

        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
//                    if allowed {
//                        self.loadRecordingUI()
//                    } else {
//                        // failed to record!
//                    }
                }
            }
        } catch {
            // failed to record!
        }
    }
    
    //*************** IMAGE HANDLING ******************************
    @IBAction func takePictureClick(_ sender: Any) {
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            let alertController = UIAlertController(title: nil, message: "Device has no camera.", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: { (alert: UIAlertAction!) in
            })
            
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        } else {
            let vc = UIImagePickerController()
            vc.sourceType = .camera
            vc.allowsEditing = true
            vc.delegate = self
            present(vc, animated: true)
        }
    }
    
    @IBAction func uploadPictureClick(_ sender: Any) {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.allowsEditing = true
        vc.delegate = self
        present(vc, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)

        guard let image = info[.editedImage] as? UIImage else {
            print("No image found")
            return
        }
        
        notePictureImg.image = image
        // print out the image size as a test
        print(image.size)
    }
    
    //*************** AUDIO HANDLING ******************************
    
    
    @IBAction func recordingClick(_ sender: UIButton) {
        if audioRecorder == nil {
                startRecording()
            } else {
                finishRecording(success: true)
            }
    }
    
    func startRecording() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")

        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()

            //recordButton.setTitle("Tap to Stop", for: .normal)
        } catch {
            finishRecording(success: false)
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        print("path: \(paths[0])")
        return paths[0]
    }
    
    func finishRecording(success: Bool) {
        audioRecorder.stop()
        audioRecorder = nil
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
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
    
    func getLocation(coordinate: CLLocationCoordinate2D){
        let newLocation: CLLocation =  CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude) // creates the location as CLLocation

        CLGeocoder().reverseGeocodeLocation(newLocation) { (placemarks, error) in
            if error != nil { // if there was an error
                print("error reverseGeocodeLocation" , error!) // print the error
            } else {
                if let placemark = placemarks?[0] {
//                    placemark.country
//                    placemark.administrativeArea
//                    placemark.locality
                    self.addAnnotation(coordinate: coordinate, title: "", subtitle: "" )
                }
            }
        }
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

//MARK: - MKMap Extension Class
extension NoteEditVC: MKMapViewDelegate {
    // ViewFor annotation method
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation { // if the annotation is the user location
            return nil // return nothing
        }
        
        let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "droppablePin" + annotation.title!!) // create the annotation view
        annotationView.animatesDrop = true // set true annotation animation
        annotationView.canShowCallout = true // set true can show callout
//        annotationView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure) // set callout button
        annotationView.pinTintColor = UIColor.cyan
        return annotationView
    }
    
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
