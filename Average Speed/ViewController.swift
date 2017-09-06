//
//  ViewController.swift
//  Average Speed
//
//  Created by Muhammed Nurkerim on 30/05/2017.
//  Copyright © 2017 Muhammed Nurkerim. All rights reserved.
//

import UIKit
import CoreLocation
import HealthKit

class ViewController: UIViewController {
    
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var averageSpeedLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var paceLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
    var seconds = 0.0
    var distance = 0.0
    
    var savedDrive:Drive?
    
    lazy var locationManager: CLLocationManager = {
        var _locationManager = CLLocationManager()
        _locationManager.delegate = self
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest
        _locationManager.activityType = .automotiveNavigation
        
        // Movement threshold for new events
        _locationManager.distanceFilter = kCLDistanceFilterNone
        return _locationManager
    }()
    
    lazy var locations = [CLLocation]()
    lazy var timer = Timer()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        locationManager.requestAlwaysAuthorization()
        
        stopButton.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer.invalidate()
    }
    
    func eachSecond(timer: Timer) {
        seconds += 1
        let secondsQuantity = HKQuantity(unit: HKUnit.second(), doubleValue: seconds)
        timeLabel.text = "Time: " + secondsQuantity.description
        let distanceQuantity = HKQuantity(unit: HKUnit.meter(), doubleValue: distance)
        distanceLabel.text = "Distance: " + distanceQuantity.description
        
        let paceUnit = HKUnit.second().unitDivided(by: HKUnit.meter())
        let paceQuantity = HKQuantity(unit: paceUnit, doubleValue: seconds / distance)
        paceLabel.text = "Pace: " + paceQuantity.description
        
        averageSpeedLabel.text = String(format: "Average Speed: %.2f mph", ((distance / seconds) * 2.23693629))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    
        //performSegue(withIdentifier: "DetailViewSegue", sender: self)
        
//        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as! DetailedViewController
//        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func startLocationUpdates() {
        // Here, the location manager will be lazily instantiated
        locationManager.startUpdatingLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func startPressed() {
        startButton.isHidden = true
        stopButton.isHidden = false
        
        locations.removeAll(keepingCapacity: false)
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ViewController.eachSecond), userInfo: nil, repeats: true)
        startLocationUpdates()
        
        seconds = 0.0
        distance = 0.0
        
        //mapView.hidden = false
    }
    
    @IBAction func stopPressed() {
        seconds = 0.0
        distance = 0.0
        
        locationManager.stopUpdatingLocation()
        timer.invalidate()
        
        stopButton.isHidden = true
        startButton.isHidden = false
        
        let alertController = UIAlertController(title: "Tracking Stopped", message: "Save or discard this session?", preferredStyle: .actionSheet)
        let saveAction = UIAlertAction(title: "Save", style: .default, handler: saveActionHandler)
        let discardAction = UIAlertAction(title: "Discard", style: .default, handler: discardActionHandler)
        alertController.addAction(saveAction)
        alertController.addAction(discardAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func saveDrive() {
        // 1
        savedDrive = Drive()
        savedDrive?.distance = self.distance as NSNumber
        savedDrive?.duration = self.seconds as NSNumber
        savedDrive?.timestamp = NSDate()
        
        // 2
        var savedLocations = [Location]()
        for location in locations {
            let savedLocation = Location()
            savedLocation.timestamp = location.timestamp as NSDate
            savedLocation.latitude = location.coordinate.latitude as NSNumber
            savedLocation.longitude = location.coordinate.longitude as NSNumber
            savedLocations.append(savedLocation)
        }
        
        savedDrive?.locations = NSOrderedSet(array: savedLocations)
        
        // 3
//        var error: NSError?
//        let success = managedObjectContext!.save(&error)
//        if !success {
//            println("Could not save the run!")
//        }
    }
    
    func saveActionHandler(action: UIAlertAction) {
        saveDrive()
        
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as! DetailedViewController
        viewController.drive = savedDrive
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func discardActionHandler(action: UIAlertAction) {
        self.navigationController?.popToRootViewController(animated: true)
    }

}

// MARK: - CLLocationManagerDelegate
extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for location in locations {
            if location.horizontalAccuracy < 20 {
                //update distance
                if self.locations.count > 0 {
                    distance += location.distance(from: self.locations.last!)
                    speedLabel.text = String(format:"Speed: %.1f mph", (location.speed * 2.23693629))
                }

                //save location
                self.locations.append(location)
            }
        }
    }
}

