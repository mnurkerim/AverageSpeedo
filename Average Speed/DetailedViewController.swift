//
//  DetailedViewController.swift
//  Average Speed
//
//  Created by Muhammed Nurkerim on 31/05/2017.
//  Copyright © 2017 Muhammed Nurkerim. All rights reserved.
//

import UIKit
import MapKit

class DetailedViewController: UIViewController, MKMapViewDelegate {

    var drive:Drive?
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.delegate = self
        // Do any additional setup after loading the view.
        
        configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureView() {
//        let distanceQuantity = HKQuantity(unit: HKUnit.meterUnit(), doubleValue: run.distance.doubleValue)
//        distanceLabel.text = "Distance: " + distanceQuantity.description
//        
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateStyle = .MediumStyle
//        dateLabel.text = dateFormatter.stringFromDate(run.timestamp)
//        
//        let secondsQuantity = HKQuantity(unit: HKUnit.secondUnit(), doubleValue: run.duration.doubleValue)
//        timeLabel.text = "Time: " + secondsQuantity.description
//        
//        let paceUnit = HKUnit.secondUnit().unitDividedByUnit(HKUnit.meterUnit())
//        let paceQuantity = HKQuantity(unit: paceUnit, doubleValue: run.duration.doubleValue / run.distance.doubleValue)
//        paceLabel.text = "Pace: " + paceQuantity.description
        
        loadMap()
    }
    
    func mapRegion() -> MKCoordinateRegion {
        let initialLoc = drive?.locations.firstObject as! Location
        
        var minLat = initialLoc.latitude.doubleValue
        var minLng = initialLoc.longitude.doubleValue
        var maxLat = minLat
        var maxLng = minLng
        
        let locations = drive?.locations.array as! [Location]
        
        for location in locations {
            minLat = min(minLat, location.latitude.doubleValue)
            minLng = min(minLng, location.longitude.doubleValue)
            maxLat = max(maxLat, location.latitude.doubleValue)
            maxLng = max(maxLng, location.longitude.doubleValue)
        }
        
        return MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: (minLat + maxLat)/2,
                                           longitude: (minLng + maxLng)/2),
            span: MKCoordinateSpan(latitudeDelta: (maxLat - minLat)*1.1,
                                   longitudeDelta: (maxLng - minLng)*1.1))
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if !overlay.isKind(of: MKPolyline.self) {
            //Do nothing
        }
        
        let polyline = overlay as! MKPolyline
        let renderer = MKPolylineRenderer(polyline: polyline)
        renderer.strokeColor = UIColor.black
        renderer.lineWidth = 6
        return renderer
    }
    
    func polyline() -> MKPolyline {
        var coords = [CLLocationCoordinate2D]()
        
        let locations = drive!.locations!.array as! [Location]
        for location in locations {
            coords.append(CLLocationCoordinate2D(latitude: location.latitude.doubleValue,
                                                 longitude: location.longitude.doubleValue))
        }
        
        return MKPolyline(coordinates: &coords, count: drive!.locations!.count)
    }
    
    func loadMap() {
        if drive!.locations.count > 0 {
            mapView.isHidden = false
            
            // Set the map bounds
            mapView.region = mapRegion()
            
            // Make the line(s!) on the map
            mapView.add(polyline())
        } else {
            // No locations were found!
            mapView.isHidden = true
            
            let alertController = UIAlertController(title: "Error", message: "Sorry, this run has no locations saved?", preferredStyle: .actionSheet)
            let okayAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
            alertController.addAction(okayAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
