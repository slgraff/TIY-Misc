//
//  ViewController.swift
//  TrackMe
//
//  Created by Steve Graff on 6/12/16.
//  Copyright © 2016 Steve Graff. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation


class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var walkButton: UIButton!
    
    var locationManager: CLLocationManager!
    
    var locations = [CLLocation]()
    
    var timer = NSTimer()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        
        // Ask for auth to access location
        var status = CLLocationManager.authorizationStatus()
        if status == .NotDetermined || status == .Denied || status == .AuthorizedWhenInUse {
            // display alert indicating authorization required
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
        }
        
        locationManager.startUpdatingLocation()

        // MapView setup to show user location
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.mapType = MKMapType.Standard
        mapView.userTrackingMode = MKUserTrackingMode.Follow
    }
    
    
    override func viewWillAppear(animated: Bool) {
//        locationManager.startUpdatingLocation()
//        locationManager.startUpdatingHeading()
    }
    
    override func viewWillDisappear(animated: Bool) {
        locationManager.stopUpdatingLocation()
    }
    
    // MARK: CLLocationManager Delegates
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        locationManager.stopUpdatingLocation()

    }
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        self.locations.append(locations[0] as CLLocation)
        
        let spanX = 0.007
        let spanY = 0.007
        var newRegion = MKCoordinateRegion(center: mapView.userLocation.coordinate, span: MKCoordinateSpanMake(spanX, spanY))
        if (self.locations.count > 1) {
            var sourceIndex = self.locations.count - 1
            var destinationIndex = self.locations.count - 2
            
            let c1 = self.locations[sourceIndex].coordinate
            let c2 = self.locations[destinationIndex].coordinate
            var a = [c1, c2]
            var polyline = MKPolyline(coordinates: &a, count: a.count)
            
            mapView.addOverlay(polyline)
            
        }
        
        
//        
//        for location in locations {
//            if self.locations.count > 0 {
//                var coords = [CLLocationCoordinate2D]()
//                coords.append(self.locations.last!.coordinate)
//                coords.append(location.coordinate)
//                
//                mapView.addOverlay(MKPolyline(coordinates: &coords, count: coords.count))
//                
//            }
//            
//        }
        
//        let userLocation:CLLocation = locations.last!
//        print("Location is lat: \(userLocation.coordinate.latitude), long: \(userLocation.coordinate.longitude)")
        
    
    
//    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
//        
//        // print("present location: \(newLocation.coordinate.latitude), \(newLocation.coordinate.longitude)")
//        
//
//            
//            // Conditional added to handle issue with simulator
//            // where initial coords are always (0,0)
//            // if oldCoordinates.latitude != 0 {
//            // var area = [oldCoordinates, newCoordinates]
//            // var polyline = MKPolyline(coordinates: &area, count: area.count)
//            // mapView.addOverlay(polyline)
//            // }
//
//        }
        
//        // Stop updating location
//        locationManager.stopUpdatingLocation()
//        
//        // Schedule to start updating in 60 seconds
//        timer = NSTimer.scheduledTimerWithTimeInterval(60, target: self, selector: #selector(turnOnLocationManager), userInfo: nil, repeats: false)
    }
    
//    func turnOnLocationManager() {
//        locationManager.startUpdatingLocation()
//    }
    
    // MARK: MKMapView Delegates
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        
        if (overlay is MKPolyline) {
            let polyRenderer = MKPolylineRenderer(overlay: overlay)
            polyRenderer.strokeColor = UIColor.redColor()
            polyRenderer.lineWidth = 5
            return polyRenderer
        }
        return MKPolylineRenderer()
    }
    
    
    // MARK: Add annotations to map
    func addAnnotationsOnMap(locationToPoint: CLLocation) {
        var annotation = MKPointAnnotation()
        annotation.coordinate = locationToPoint.coordinate
        var geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(locationToPoint, completionHandler: { (placemarks, error) -> Void in
            if let placemarks = placemarks where placemarks.count > 0 {
                var placemark = placemarks[0]
                var addressDictionary = placemark.addressDictionary
                annotation.title = addressDictionary!["Name"] as? String
                self.mapView.addAnnotation(annotation)
            }
        })
    }

    
    // Start/Stop tracking movement
    @IBAction func walkButton(sender: AnyObject) {
        
        if walkButton.titleLabel!.text == "Start Walk" {
            
            locationManager.startUpdatingLocation()
            locationManager.startUpdatingHeading()
            
            print("Started updating location")
            
            walkButton.setTitle("End Walk", forState: .Normal)
            
        } else if walkButton.titleLabel!.text == "End Walk" {
        
            locationManager.stopUpdatingLocation()
            locationManager.stopUpdatingHeading()
            
            print("Stopped updating location")

            
            walkButton.setTitle("Start Walk", forState: .Normal)
            
        }
    

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
        mapView.mapType = MKMapType(rawValue: 0)!
    }


}

