//
//  ViewController.swift
//  TrackMe
//
//  Project to figure out how to determine users location, track their travels, and add
//  a map overlay to show their route.
//
//  Optionally want to:
//  Create screen shot of map with overlay when done with walk
//  Plan a walk route given a user set time
//  Drop pins along route, get street address given coordinates
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
    
    var updateLocationTimer = NSTimer()
    
    var isMapZoomed:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        
        // Ask for auth to access user location
        let locationAuthStatus = CLLocationManager.authorizationStatus()
        if locationAuthStatus == .NotDetermined || locationAuthStatus == .Denied || locationAuthStatus == .AuthorizedWhenInUse {
            // display alert indicating authorization required
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
        }
        
        // Get current location
        locationManager.requestLocation()

        // MapView setup to show user location
        self.mapView.delegate = self
        self.mapView.showsUserLocation = true
        self.mapView.mapType = MKMapType.Standard
        self.mapView.userTrackingMode = MKUserTrackingMode.Follow
        
//        self.mapView.frame.standardized
//
//        let noLocation = CLLocationCoordinate2D()
//        let span = MKCoordinateSpanMake(0.005, 0.005)
//        let viewRegion = MKCoordinateRegion(center: noLocation, span: span)
//        self.mapView.setRegion(viewRegion, animated: true)
    }
    
    
    func zoomToUserLocationAnimated(animated: Bool) {
        self.mapView.setRegion(MKCoordinateRegionMakeWithDistance((mapView.userLocation.location?.coordinate)!, 200, 200), animated: animated)
    }
    
    override func viewWillAppear(animated: Bool) {
    }
    
    override func viewWillDisappear(animated: Bool) {
    }
    
    
    //
    // MARK: CLLocationManager Delegates
    //
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        locationManager.stopUpdatingLocation()

    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Someone set up us the bomb! \(error)")
    }
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if !isMapZoomed {
            zoomToUserLocationAnimated(true)
            isMapZoomed = true
        }
        
        self.locations.append(locations[0] as CLLocation)
        
//        let spanX = 0.007
//        let spanY = 0.007
//        var newRegion = MKCoordinateRegion(center: mapView.userLocation.coordinate, span: MKCoordinateSpanMake(spanX, spanY))
        
        if (self.locations.count > 1) {
            let sourceIndex = self.locations.count - 1
            let destinationIndex = self.locations.count - 2
            
            let firstCoordinate = self.locations[sourceIndex].coordinate
            let secondCoordinate = self.locations[destinationIndex].coordinate
            var routeCoordinates = [firstCoordinate, secondCoordinate]
            let walkRoutePolyline = MKPolyline(coordinates: &routeCoordinates, count: routeCoordinates.count)
            
            mapView.addOverlay(walkRoutePolyline)
            
            // Stop updating location, set timer to start updating again in 10 seconds
            locationManager.stopUpdatingLocation()
            updateLocationTimer = NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: #selector(turnOnLocationManager), userInfo: nil, repeats: false)
        }
        }
    
    func turnOnLocationManager() {
        locationManager.startUpdatingLocation()
    }
    
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
    
    
    // TODO: Figure out how to use this to allow user to drop annotation (dog event: poop, peed, behavior like 'sit'
    // MARK: Add annotations to map
    func addAnnotationsOnMap(locationToPoint: CLLocation) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = locationToPoint.coordinate
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(locationToPoint, completionHandler: { (placemarks, error) -> Void in
            if let placemarks = placemarks where placemarks.count > 0 {
                let placemark = placemarks[0]
                var addressDictionary = placemark.addressDictionary
                annotation.title = addressDictionary!["Name"] as? String
                self.mapView.addAnnotation(annotation)
            }
        })
    }

    
    // Start or Stop tracking location
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

