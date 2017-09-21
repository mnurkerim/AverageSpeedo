//
//  ViewController.swift
//  Average Speed
//
//  Created by Muhammed Nurkerim on 30/05/2017.
//  Copyright © 2017 Muhammed Nurkerim. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {

    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var averageSpeedLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var paceLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
    @IBOutlet weak var miniAvgSpeedLabel: UILabel!
    @IBOutlet weak var miniTimeLabel: UILabel!
    @IBOutlet weak var miniDistanceLabel: UILabel!
    @IBOutlet weak var miniStartButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!

    var savedDrive: Drive?
    
    var seconds = 0.0
    var distance = Measurement(value: 0, unit: UnitLength.meters)
    
    var miniSeconds = 0.0
    var miniDistance = Measurement(value: 0, unit: UnitLength.meters)

    private let locationManager = LocationManager.shared

    lazy var locations = [CLLocation]()
    lazy var timer = Timer()
    lazy var miniTimer = Timer()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.allowsBackgroundLocationUpdates = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        stopButton.isHidden = true
        resetButton.isHidden = true
        
        let navigationBarAppearance = self.navigationController?.navigationBar
        let font = UIFont(name: "AvenirNext-Bold", size: 17)
        if let font = font {
            navigationBarAppearance?.titleTextAttributes = [NSAttributedStringKey.font: font, NSAttributedStringKey.foregroundColor: UIColor.black]
        }
        
        //Prevent auto-lock
        UIApplication.shared.isIdleTimerDisabled = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func eachSecond() {
        seconds += 1
        updateDisplay()
    }
    
    @objc func miniEachSecond() {
        miniSeconds += 1
        updateMiniDisplay()
    }

    func saveDrive() {
        let newDrive = Drive(context: CoreDataStack.context)
        newDrive.distance = self.distance.value
        newDrive.duration = Int16(self.seconds as Double)
        newDrive.timestamp = Date()

        for location in locations {
            let savedLocation = Location(context: CoreDataStack.context)
            savedLocation.timestamp = location.timestamp as Date
            savedLocation.latitude = location.coordinate.latitude
            savedLocation.longitude = location.coordinate.longitude
            newDrive.addToLocations(savedLocation)
        }
        
        CoreDataStack.saveContext()
        savedDrive = newDrive
    }

    func saveActionHandler(action: UIAlertAction) {
        timer.invalidate()
        miniTimer.invalidate()
        locationManager.stopUpdatingLocation()
        
        saveDrive()
        resetUiValues()
        resetMiniUiValues()
        
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as! DetailedViewController
        viewController.drive = savedDrive
        self.navigationController?.pushViewController(viewController, animated: true)
    }

    func discardActionHandler(action: UIAlertAction) {
        timer.invalidate()
        miniTimer.invalidate()
        locationManager.stopUpdatingLocation()
        
        resetUiValues()
        resetMiniUiValues()
        
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    private func startLocationUpdates() {
        locationManager.delegate = self
        locationManager.activityType = .automotiveNavigation
        locationManager.distanceFilter = 10
        locationManager.startUpdatingLocation()
    }
    
    private func updateMiniDisplay() {
        let formattedDistance = FormatDisplay.distance(miniDistance)
        let formattedTime = FormatDisplay.time(Int(miniSeconds))
        
        miniDistanceLabel.text = "\(formattedDistance)"
        miniTimeLabel.text = "\(formattedTime)"
        miniAvgSpeedLabel.text = String(format: "%.2f mph", ((miniDistance.value / miniSeconds) * 2.23693629))
    }
    
    private func updateDisplay() {
        let formattedDistance = FormatDisplay.distance(distance)
        let formattedTime = FormatDisplay.time(Int(seconds))
        let formattedPace = FormatDisplay.pace(distance: distance,
                                               seconds: Int(seconds),
                                               outputUnit: UnitSpeed.minutesPerMile)
        
        distanceLabel.text = "\(formattedDistance)"
        timeLabel.text = "\(formattedTime)"
        paceLabel.text = "\(formattedPace)"
        averageSpeedLabel.text = String(format: "%.2f mph", ((distance.value / seconds) * 2.23693629))
    }
    
    private func resetUiValues() {
        averageSpeedLabel.text = "0.00"
        distanceLabel.text = "0.00"
        timeLabel.text = "0:00:00"
        paceLabel.text = "0.00"
        speedLabel.text = "0.00"
    }
    
    private func resetMiniUiValues() {
        miniTimeLabel.text = "0:00:00"
        miniAvgSpeedLabel.text = "0.00 mph"
        miniDistanceLabel.text = "0.00"
    }
    
    @IBAction func miniStartPressed() {
        miniStartButton.isHidden = true
        resetButton.isHidden = false
        
        miniTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ViewController.miniEachSecond), userInfo: nil, repeats: true)
        
        miniSeconds = 0.0
        miniDistance = Measurement(value: 0, unit: UnitLength.meters)
    }
    
    @IBAction func miniResetPressed() {
        miniStartButton.isHidden = false
        resetButton.isHidden = true
        
        miniTimer.invalidate()
        
        miniSeconds = 0.0
        miniDistance = Measurement(value: 0, unit: UnitLength.meters)
    }
    
    @IBAction func startPressed() {
        startButton.isHidden = true
        stopButton.isHidden = false
        
        locations.removeAll(keepingCapacity: false)
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ViewController.eachSecond), userInfo: nil, repeats: true)
        startLocationUpdates()
        
        seconds = 0.0
        distance = Measurement(value: 0, unit: UnitLength.meters)
    }
    
    @IBAction func stopPressed() {
        stopButton.isHidden = true
        startButton.isHidden = false
        
        let alertController = UIAlertController(title: "Tracking Stopped", message: "Save or discard this session?", preferredStyle: .actionSheet)
        let saveAction = UIAlertAction(title: "Save", style: .default, handler: saveActionHandler)
        let discardAction = UIAlertAction(title: "Discard", style: .destructive, handler: discardActionHandler)
        let resumeAction = UIAlertAction(title: "Resume", style: .default, handler: { _ in
            self.stopButton.isHidden = false
            self.startButton.isHidden = true
            
            self.startLocationUpdates()
        })
        alertController.addAction(saveAction)
        alertController.addAction(resumeAction)
        alertController.addAction(discardAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
}

// MARK: - CLLocationManagerDelegate
extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for newLocation in locations {
//            guard newLocation.horizontalAccuracy < 40 else { continue }
            
            if let lastLocation = self.locations.last {
                let delta = newLocation.distance(from: lastLocation)
                distance = distance + Measurement(value: delta, unit: UnitLength.meters)
                miniDistance = miniDistance + Measurement(value: delta, unit: UnitLength.meters)
                speedLabel.text = String(format:"%.1f mph", (newLocation.speed * 2.23693629))
            }
            
            self.locations.append(newLocation)
        }
    }
}

