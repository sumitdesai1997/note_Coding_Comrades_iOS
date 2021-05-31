//
//  NoteEditVC.swift
//  note_Coding_Comrades_iOS
//
//  Created by Sumit Desai on 27/05/21.
//

import UIKit
import MapKit
import AVFoundation

class NoteEditVC: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate, AVAudioRecorderDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var mapKit: MKMapView!
    @IBOutlet weak var notePictureImg: UIImageView!
    @IBOutlet weak var titleTF: UITextField!
    @IBOutlet weak var detailsTF: UITextView!
    @IBOutlet weak var takePictureBtn: UIButton!
    @IBOutlet weak var uploadPictureBtn: UIButton!

    @IBOutlet weak var takePictureHeight: NSLayoutConstraint!
    @IBOutlet weak var uploadPictureHeight: NSLayoutConstraint!
    @IBOutlet weak var notePictureHeight: NSLayoutConstraint!
    @IBOutlet weak var recordWidth: NSLayoutConstraint!
    @IBOutlet weak var playHeight: NSLayoutConstraint!
    @IBOutlet weak var scrubberWidth: NSLayoutConstraint!
    @IBOutlet weak var changePictureHeight: NSLayoutConstraint!
    @IBOutlet weak var changePictureBtn: UIButton!
    
    var delegate : NoteTVC?
    var selectedNote : Note?
    var shallSave = true
    
    // AUDIO VARIABLES
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    var audioURL: URL? = nil
    var timer = Timer()

    // MAP - LOCATION VARIABLES
    var locationManager = CLLocationManager() // define location manager
    var currentLocation: CLLocationCoordinate2D? = nil // set current location variable
    var userLocation = CLLocation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        mapKit.showsUserLocation = false // show user location
        mapKit.isZoomEnabled = false// disable zoom
        // define style for the details text field
        detailsTF.layer.borderColor = CGColor(red: 0, green: 0, blue: 0, alpha: 0.1) // set the descriptionfield border color
        detailsTF.layer.borderWidth = 1.0 // set the descriptionfield border width
        detailsTF.layer.cornerRadius = 5.0 // set the descriptionfield corner radius
        // ------------ location manager init -----------
        locationManager.delegate = self // assign location manager delegate
        mapKit.delegate = self // this class handles the delegate mapkit
        locationManager.desiredAccuracy = kCLLocationAccuracyBest // define location manager accuracy
        locationManager.requestWhenInUseAuthorization() // define request authorization
        locationManager.startUpdatingLocation() // start updating the location
        
        recordingSession = AVAudioSession.sharedInstance()

        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem:  .save, target: self, action: #selector(shallDisappear))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem:  .cancel, target: self, action: #selector(dismissWithoutSaving))
        
        do {
            try recordingSession.setCategory(.record, mode: .default)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                }
            }
        } catch {
            // failed to record!
        }
        
        if(selectedNote == nil){
            
//            notePictureHeight.constant = 0
//            notePictureImg.isHidden = true
//            view.layoutIfNeeded()
            
            viewVisibility(constraint: notePictureHeight, button: notePictureImg, hide: true, constant: 0)
            viewVisibility(constraint: changePictureHeight, button: changePictureBtn, hide: true, constant: 0)
            viewVisibility(constraint: playHeight, button: playBtn, hide: true, constant: 0)
            viewVisibility(constraint: scrubberWidth, button: scrubberSld, hide: true, constant: 0)
        } else {
           
            // pre-populating the data if exist in selected data
            titleTF.text = selectedNote?.title
            detailsTF.text = selectedNote?.details
            if let image = selectedNote?.image{
                notePictureImg.image = UIImage(data: image)
                
                viewVisibility(constraint: takePictureHeight, button: takePictureBtn, hide: true, constant: 0)
                viewVisibility(constraint: uploadPictureHeight, button: uploadPictureBtn, hide: true, constant: 0)
            } else {
                viewVisibility(constraint: notePictureHeight, button: notePictureImg, hide: true, constant: 0)
                viewVisibility(constraint: changePictureHeight, button: changePictureBtn, hide: true, constant: 0)
            }
            
            if let coordinateX = selectedNote?.coordinateX, let coordinateY = selectedNote?.coordinateY{
                getLocation(coordinate: CLLocationCoordinate2D(latitude: CLLocationDegrees(coordinateX), longitude: CLLocationDegrees(coordinateY)))
            }
            scrubberSld.value = 0
            if let audio = selectedNote?.audio{
                do {
                    try audioPlayer = AVAudioPlayer(data: audio)
                    audioPlayer.pause()
                    audioPlayer.currentTime = 0
                    playBtn.isEnabled = true
                    scrubberSld.isEnabled = true
                    scrubberSld.maximumValue = Float(audioPlayer.duration)
                    
                } catch {
                    print(error)
                }
            } else {
                viewVisibility(constraint: playHeight, button: playBtn, hide: true, constant: 0)
                viewVisibility(constraint: scrubberWidth, button: scrubberSld, hide: true, constant: 0)
            }
        }
        
    	
    }

    override func viewWillDisappear(_ animated: Bool) {
        if shallSave {
            
            
            if (selectedNote == nil){
                selectedNote =  Note(context: delegate!.context)
                selectedNote?.parentCategory = delegate?.selectedCategory
                selectedNote?.coordinateX = userLocation.coordinate.latitude
                selectedNote?.coordinateY = userLocation.coordinate.longitude
                selectedNote?.date = Date()
            }
            
            selectedNote?.title = titleTF.text
            selectedNote?.details = detailsTF.text
            
            
            if(notePictureImg.image != nil){
                selectedNote?.image = notePictureImg.image!.pngData()!
                print("image: \(notePictureImg.image!.pngData()!)")
            }
            
            if (audioURL != nil){
                selectedNote?.audio = try? Data(contentsOf: audioURL!)
            }
            
            delegate!.saveNotes()
        }

   }
    
    // validates before dismissing the view controller
    @objc func shallDisappear() {
        shallSave = true
        
        if titleTF.text == "" {
            showAlert(title: "Title empty", message: "Please set a title")

        }else if detailsTF.text == "" {
            showAlert(title: "Description empty", message: "Please set a description")
        }else {
        
            var notesTitles = delegate?.noteList.map({$0.title!.lowercased()})
            if selectedNote != nil {
                notesTitles = notesTitles!.filter({$0 != self.selectedNote?.title!.lowercased()})
            }
            if (notesTitles!.contains(titleTF.text!.lowercased())){
                showAlert(title: "Title Taken", message: "Please choose another title")

            }else{
                navigationController?.popViewController(animated: true)
            }
        }
    }
    @objc func dismissWithoutSaving() {
        shallSave = false
        navigationController?.popViewController(animated: true)
    }
    
    func showAlert(title:String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
        titleTF.text =  selectedNote != nil ?  selectedNote?.title : ""
    }

        
    func viewVisibility(constraint: NSLayoutConstraint, button: UIView, hide: Bool, constant: Double){
        
        constraint.constant = CGFloat(constant)
        button.isHidden = hide
        view.layoutIfNeeded()
    }

//
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
        
        viewVisibility(constraint: notePictureHeight, button: notePictureImg, hide: false, constant: 128)
        viewVisibility(constraint: changePictureHeight, button: changePictureBtn, hide: false, constant: 34)
        
        notePictureImg.image = image
        
        viewVisibility(constraint: takePictureHeight, button: takePictureBtn, hide: true, constant: 0)
        viewVisibility(constraint: uploadPictureHeight, button: uploadPictureBtn, hide: true, constant: 0)

        // print out the image size as a test
        print(image.size)
    }
    
    //*************** AUDIO HANDLING ******************************
    @IBOutlet weak var scrubberSld: UISlider!
   
    @IBOutlet weak var recordBtn: UIButton!
    @IBOutlet weak var playBtn: UIButton!
    
    @IBAction func scrubberChange(_ sender: UISlider) {
        if sender.isEnabled {
            sender.value = Float(audioPlayer.currentTime)
            if scrubberSld.value == sender.minimumValue {
                playBtn.setImage( UIImage(systemName: "play.fill"), for: [] )
                timer.invalidate()
            }
        }

    }
    @IBAction func playClick(_ sender: UIButton) {
        if audioPlayer.isPlaying {
            sender.setImage(UIImage(systemName: "play.fill"), for:[])
            audioPlayer.pause()
            timer.invalidate()
        }else {
            sender.setImage( UIImage(systemName: "pause.fill"), for: [])
            audioPlayer.play()
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateScrubber), userInfo: nil, repeats: true)
        }
    }
    
    @objc func updateScrubber(){
        scrubberSld.value = Float(audioPlayer.currentTime)
        if scrubberSld.value == scrubberSld.minimumValue{
            playBtn.setImage(UIImage(systemName: "play.fill"), for:[])
            timer.invalidate()
        }
    }
    
    @IBAction func recordingClick(_ sender: UIButton) {
        if audioRecorder == nil {
                startRecording()
            } else {
                finishRecording(success: true)
            }
    }
    
    func startRecording() {
        if (audioPlayer != nil) && audioPlayer.isPlaying{
            audioPlayer.stop()
            timer.invalidate()
            playBtn.setImage(UIImage(systemName: "play.fill"), for:[])
        }
        
        recordBtn.tintColor = .systemRed
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
        return paths[0]
    }
    
    func finishRecording(success: Bool) {
        audioRecorder.stop()
        audioURL = audioRecorder?.url
        let audioData =  try? Data(contentsOf: audioURL!)
        
            do {
                try audioPlayer = AVAudioPlayer(data: audioData!)
                audioPlayer.pause()
                audioPlayer.currentTime = 0
                playBtn.isEnabled = true
                scrubberSld.isEnabled = true
                scrubberSld.value = 0
                scrubberSld.maximumValue = Float(audioPlayer.duration)
                recordBtn.tintColor = .systemBlue
            } catch {
                print(error)
            }
                   
        audioRecorder = nil
        viewVisibility(constraint: playHeight, button: playBtn, hide: false, constant: 30)
        viewVisibility(constraint: scrubberWidth, button: scrubberSld, hide: false, constant: 150)
        
        
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
    
    
    //*************** MAP HANDLING ******************************
    // creates an annotation depending on the coordinates
    func getLocation(coordinate: CLLocationCoordinate2D){
        let newLocation: CLLocation =  CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude) // creates the location as CLLocation

        CLGeocoder().reverseGeocodeLocation(newLocation) { (placemarks, error) in
            if error != nil { // if there was an error
                print("error reverseGeocodeLocation" , error!) // print the error
            } else {
                if let _ = placemarks?[0] {
                    self.mapKit.removeAnnotations(self.mapKit.annotations)
                    let latDelta: CLLocationDegrees = 0.2 // latitude delta
                    let lngDelta: CLLocationDegrees = 0.2 // longitude delta
                    let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lngDelta) // sets the span for the coordinates
                    self.mapKit.setRegion(MKCoordinateRegion(center: coordinate, span: span), animated: true) // sets the region for the map
                    
                    let annotation = MKPointAnnotation() // creates the point annotation object

                    annotation.title = "Your Location" // sets the annotation title
                    annotation.subtitle = "" // sets the annotation subtitle
                    annotation.coordinate = coordinate // sets the annotation coordinate
                    self.mapKit.addAnnotation(annotation) // adds the annotation to the map
                }
            }
        }
    }
}

//MARK: - MKMap Extension Class
extension ViewController: MKMapViewDelegate {
    // ViewFor annotation method
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation { // if the annotation is the user location
            return nil // return nothing
        }
        let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "droppablePin") // create the annotation view
        annotationView.animatesDrop = true // set true annotation animation
        annotationView.canShowCallout = true // set true can show callout
        annotationView.pinTintColor = UIColor.cyan
        return annotationView
    }
}

//MARK: - Location Manager Extension Class
extension NoteEditVC : CLLocationManagerDelegate{
    // gets the current location and creates the annotation for it, as well as centers the map into the region closer to the location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if(selectedNote == nil && currentLocation == nil){
            userLocation = locations[0] // gets the location of the user
            
            let latitude = userLocation.coordinate.latitude // user latitude
            let longitude = userLocation.coordinate.longitude // user longitude
            currentLocation = CLLocationCoordinate2D(latitude: latitude, longitude: longitude) // sets the current location into the global variable
            getLocation(coordinate: currentLocation!)

        }

    }
}
