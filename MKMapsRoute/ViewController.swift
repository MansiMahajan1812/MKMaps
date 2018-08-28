//
//  ViewController.swift
//  MKMapsRoute
//
//  Created by Mansi Mahajan on 7/12/18.
//  Copyright © 2018 Mansi Mahajan. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import GooglePlaces

class CustomPolyline : MKPolyline {
    var color: UIColor?
    var distance: String?
}


class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    let OVERLAYMETERS = 600
    
    @IBOutlet weak var startOutlet: UIButton!
    @IBOutlet weak var mapKit: MKMapView!
    var searchController: UISearchController!
    var locationManager : CLLocationManager!
    var currentLocation: CLLocation?
    var location1: CLLocationCoordinate2D!
    var location2: CLLocationCoordinate2D!
    var resultsViewController: GMSAutocompleteResultsViewController?
    var points: [String]!
    var distance: [Double] = []
    let vc: DecodePolyline! = DecodePolyline()
    var annotation: MKPointAnnotation!
    var annotationView: MKAnnotationView!
    var pinAnnotationView = MKPinAnnotationView()
    var pointAnnotation : Bike = Bike()
    let initialId = "initialID"
    let reuseId = "reuseID"
    var polyline: [[CLLocationCoordinate2D]] = []
    var i = 0
    var radius = 1000
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingHeading()
        locationManager.startUpdatingLocation()
        
        
        mapKit.delegate = self
        mapKit.mapType = MKMapType.standard
        mapKit.showsUserLocation = true
        mapKit.showsScale = true
        mapKit.showsCompass = true
        
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self
        
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
        
        // Put the search bar in the navigation bar.
        searchController?.searchBar.sizeToFit()
        navigationItem.titleView = searchController?.searchBar
        
        // When UISearchController presents the results view, present it in
        // this view controller, not one further up the chain.
        definesPresentationContext = true
        
        // Prevent the navigation bar from being hidden when searching.
        searchController?.hidesNavigationBarDuringPresentation = false
        
        let mapTap = UITapGestureRecognizer(target: self, action: #selector(mapTapped(_:)))
        mapKit.addGestureRecognizer(mapTap)
        
    }
    
    @IBAction func createCircle(_ sender: UIButton) {
        for overlay in mapKit.overlays {
            if overlay is MKCircle {
                    mapKit.remove(overlay)
            }
        }
    
        let circle = MKCircle(center: self.location1, radius: CLLocationDistance(self.radius))
        let rect = self.mapKit.overlays.reduce(circle.boundingMapRect, {MKMapRectUnion($0, $1.boundingMapRect)})
        self.mapKit.setVisibleMapRect(rect, edgePadding: UIEdgeInsets(top: 50.0, left: 50.0, bottom: 50.0, right: 50.0), animated: true)
        self.mapKit.add(circle)

    }
    
    @IBAction func countAnnotations(_ sender: UIButton) {
        var counter = 0
        for annotation in self.mapKit.annotations {
            let getLat: CLLocationDegrees = location1.latitude
            let getLon: CLLocationDegrees = location1.longitude
            let d = CLLocation(latitude: getLat, longitude: getLon)
            let d2 = CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
            let distance = d.distance(from: d2)
            if(distance < CLLocationDistance(radius))
            {
               counter += 1
            }
 
        }
        let alert = UIAlertController(title: "Alert", message: "counter \(counter)", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
            print(counter)
    }
    

    //On tap dismiss customView of annotation
    @objc func mapTapped(_ tap: UITapGestureRecognizer) {
        if tap.state == .recognized && tap.state == .recognized {
            // Get map coordinate from touch point
            let touchPt: CGPoint = tap.location(in: mapKit)
            let coord: CLLocationCoordinate2D = mapKit.convert(touchPt, toCoordinateFrom: mapKit)
            let getLat: CLLocationDegrees = location1.latitude
            let getLon: CLLocationDegrees = location1.longitude
            let d = CLLocation(latitude: getLat, longitude: getLon)
            let d2 = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
            let distance = d.distance(from: d2)
            print(distance)
            if(distance < CLLocationDistance(radius))
            {
                print("Yeah, this place is inside my circle")
                for overlay: MKOverlay in mapKit.overlays {
                    // .. if MKPolyline ...
                    if (overlay is MKCircle) {
                        
                        if radius == 100 {
                            radius = 500
                        }else{
                            radius = 100
                        }
                        mapKit.remove(overlay)
                        let circle = MKCircle(center: self.location1, radius: CLLocationDistance(self.radius))
                        self.mapKit.add(circle)
                    }
                }
            }
            else
            {
                print("Oops!! its too far")
            }
    }
    }
    
    
    

    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if(!locations.isEmpty)
        {
            let myLocation = locations[0] as CLLocation
            location1 = myLocation.coordinate
            mapKit.setRegion(MKCoordinateRegionMake(myLocation.coordinate, MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)), animated: true)
            //Configure Custom Annotation and Add to CustomAnnotation View
            pointAnnotation = Bike()
            pointAnnotation.pinCustomImageName = "pin"
            pointAnnotation = Bike.bikes(latitude: myLocation.coordinate.latitude, longitude: myLocation.coordinate.longitude)
            pinAnnotationView = MKPinAnnotationView(annotation: pointAnnotation, reuseIdentifier: "pin")
            //makeAnnotation(lattitude: location1.latitude, longitude: location1.longitude)
        
        }
    }


    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
       
        let reuseIdentifier = "pin"
        annotationView = mapKit.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
        if annotationView == nil {
            annotationView = ClusterView(annotation: annotation, reuseIdentifier: reuseIdentifier)
            annotationView.canShowCallout = true
    
        } else {
            annotationView?.annotation = annotation
        }
        annotationView?.image = UIImage(named: pointAnnotation.pinCustomImageName)
        annotationView.annotation = annotation
        annotationView.leftCalloutAccessoryView = nil
        annotationView.rightCalloutAccessoryView = nil
        //set Xib as a custom annotation view
        let topLevelObjs = Bundle.main.loadNibNamed("AnnotationPopUpViewController", owner: self, options: nil)
            if let annotationViewController = topLevelObjs![0] as? AnnotationPopUpViewController{
                if let annotationView1 = annotationViewController.view as? AnnotationPOPUpView {
                let viewSize = annotationView1.preferredContentSize
                    print(viewSize.width)
                let widthConstraint = NSLayoutConstraint(item: annotationView1,
                                                         attribute: .width, relatedBy: .equal, toItem: nil,
                                                         attribute: .notAnAttribute, multiplier: 1,
                                                         constant: viewSize.width)
                print(widthConstraint)
                annotationView1.addConstraint(widthConstraint)

                let heightConstraint = NSLayoutConstraint(item: annotationView1,
                                                          attribute: .height, relatedBy: .equal, toItem: nil,
                                                          attribute: .notAnAttribute, multiplier: 1,
                                                          constant: viewSize.height)
                annotationView1.addConstraint(heightConstraint)
                    annotationView?.detailCalloutAccessoryView = annotationView1

                }
            }
        return annotationView

    }
 
    
    
 
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        if newState == MKAnnotationViewDragState.ending {
            let droppedAt = view.annotation?.coordinate
            location1 = droppedAt
            location2 = annotationView.annotation?.coordinate
            getPolylineRoute()
        }
        else{
            print("not end")
        }
    }
    
    //makeAnnotation
    func makeAnnotation(lattitude: Double, longitude: Double) {
        for overlay in mapKit.overlays {
            if overlay is MKPolyline {
                mapKit.remove(overlay)
            }
        }
        pointAnnotation = Bike()
        pointAnnotation = Bike.bikes(latitude: lattitude, longitude: longitude)
        pointAnnotation.pinCustomImageName = "taxi"
        mapKit.addAnnotation(pointAnnotation)

    }
   
    
    @objc func getPolylineRoute(){
        locationManager.startUpdatingLocation()
        print(location2, "\n \(location1)")
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let url = URL(string: "http://maps.googleapis.com/maps/api/directions/json?origin=\(location1.latitude),\(location1.longitude)&destination=\(location2.latitude),\(location2.longitude)&units=imperial&alternatives=true&sensor=false")!
        let task = session.dataTask(with: url, completionHandler: {
            (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            }else{
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as! [String : AnyObject]
                    let routes = json["routes"] as! NSArray
                    print(routes.count)
                    OperationQueue.main.addOperation({
                        self.distance = []
                        self.polyline = []
                        print(self.polyline)
                        print(self.distance)

                        //get distance and all three routes
                        for route in routes
                        {
                            let temp = (route as! NSDictionary).value(forKey: "legs") as! NSArray
                            let temp1 = (temp[0] as! NSDictionary).value(forKey: "distance")
                            let temp2 = (temp1 as! NSDictionary).value(forKey: "text") as! String
                            print(temp2)
                            let index1 = temp2.index(temp2.endIndex, offsetBy: -3)
                            let temp3 = Double(temp2[..<index1])
                            print(temp3)
                            
                            self.distance.append(temp3!)
                            print(self.distance)
                            let routeOverviewPolyline:NSDictionary = (route as! NSDictionary).value(forKey: "overview_polyline") as! NSDictionary
                            let points = routeOverviewPolyline.object(forKey: "points") as! String
                            print(points)
                            self.polyline.append(self.vc.decodePolyline(points, precision: 1e5)!)
                        }
                      
                        //sort distance and polyline array
                      if self.distance.count>1{
                        for i in 0...self.distance.count-2{
                            print(self.distance[i], self.distance[i+1])
                                if self.distance[i]<self.distance[i+1] {
                                    let t = self.distance[i]
                                    self.distance[i] = self.distance[i+1]
                                    self.distance[i+1] = t
                                    let t1 = self.polyline[i]
                                    self.polyline[i] = self.polyline[i+1]
                                    self.polyline[i+1] = t1
                                }
                            print(self.distance)
                        }
                        print(self.distance)
                        }
                        
                        //different color of shortest path
                        for i in 0...self.polyline.count-1{
                            let polyLine1 = CustomPolyline(coordinates: self.polyline[i], count: (self.polyline[i].count))
                            if i == self.polyline.count-1 {
                                polyLine1.color = UIColor.red

                            }else{
                                polyLine1.color = UIColor.black

                            }
                            self.mapKit?.add(polyLine1)
                            let rect = self.mapKit.overlays.reduce(polyLine1.boundingMapRect, {MKMapRectUnion($0, $1.boundingMapRect)})
                            self.mapKit.setVisibleMapRect(rect, edgePadding: UIEdgeInsets(top: 50.0, left: 50.0, bottom: 50.0, right: 50.0), animated: true)
                            self.startOutlet.isHidden = false
                        }
                    })
                }catch{
                    print("error in JSONSerialization")
                }
        
                
            }
                
        })
        task.resume()

    }

    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle {
            let circle = MKCircleRenderer(overlay: overlay)
            circle.strokeColor = UIColor.red
            circle.fillColor = UIColor(red: 255, green: 0, blue: 0, alpha: 0.1)
            circle.lineWidth = 1
            return circle
        }else {
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.strokeColor = (overlay as! CustomPolyline).color
            polylineRenderer.lineWidth = 5
            return polylineRenderer
        }
    }
    
    
    // ============not used================
    // draw route using CAShape
    func layer(from path: [CLLocationCoordinate2D]?) -> CAShapeLayer? {
        let breizerPath = UIBezierPath()
        let firstCoordinate: CLLocationCoordinate2D? = path?[0]
        if let aCoordinate = firstCoordinate {
            breizerPath.move(to: mapKit.convert(firstCoordinate!, toPointTo: mapKit))
        }
        for i in 1..<path!.count  {
            let coordinate: CLLocationCoordinate2D? = path?[i]
            if let aCoordinate = coordinate {
                breizerPath.addLine(to: mapKit.convert(aCoordinate, toPointTo: mapKit))
            }
        }
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = breizerPath.reversing().cgPath
        shapeLayer.strokeColor = UIColor.black.cgColor
        shapeLayer.lineWidth = 4.0
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineJoin = kCALineJoinRound
        shapeLayer.lineCap = kCALineCapRound
        shapeLayer.cornerRadius = 5
    
        return shapeLayer
    }

    //Animate CAShape route
    func animatePath(_ layer: CAShapeLayer) {
        let pathAnimation = CABasicAnimation(keyPath: "strokeEnd")
        pathAnimation.duration = 6
        pathAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        pathAnimation.fromValue = Int(0.0)
        pathAnimation.toValue = Int(1.0)
        pathAnimation.repeatCount = 100
        layer.add(pathAnimation, forKey: "strokeEnd")
    }
    
    //change alpha value of polyline
    func changeAlphaValue(alpha: Double) {
       
        let overlays = self.mapKit.overlays
        for overlay in overlays {
            let renderer = mapKit.renderer(for: overlay)
            UIView.animate(withDuration: 20, delay: 0.1, options: [.repeat, .autoreverse], animations: {
                 renderer?.alpha = CGFloat(alpha)
            }, completion: { (success) in
                if success {
                if alpha == 0.5 {
                    self.changeAlphaValue(alpha: 1)
                    }else{
                    self.changeAlphaValue(alpha: 0.5)
                }
                }
            })
            }
        }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //calculate angle for turns
    func getAngle(fromLoc: CLLocationCoordinate2D, toLoc: CLLocationCoordinate2D)-> Double {
        let deltaLongitude = fromLoc.longitude - toLoc.longitude
        print(deltaLongitude)
        let deltaLatitude = fromLoc.latitude - toLoc.latitude
        print(deltaLatitude)
        let angle = (.pi * 0.5) - atan(deltaLatitude / deltaLongitude)
        print(angle)
        
        if deltaLongitude > 0
        {
            return angle + .pi
            
        }
        else if deltaLongitude < 0
        {
            return angle
        }
        else if deltaLatitude < 0
        {
            return .pi;
        }
        else{
        return 0.0
        }
    }

    var degree: Double = 0
    //Inert Animation Duration and Destination Coordinate which you are getting from server.
    func  moveCar(_ destinationCoordinate : CLLocationCoordinate2D) {
        let tempDic = polyline[0]
        if tempDic != nil && i<tempDic.count{
            degree = getAngle(fromLoc: tempDic[i+1], toLoc: destinationCoordinate)
        }
        if degree != 0{
            UIView.animate(withDuration: 5, animations: {
                self.annotationView.transform = CGAffineTransform(rotationAngle: CGFloat(self.degree))
                
            }, completion:  { success in
                if success {
                     self.move(destinationCoordinate: destinationCoordinate)
                }
            })
        }
        else{
             move(destinationCoordinate: destinationCoordinate)
        }
       
        
       
    }
    
    
    func move(destinationCoordinate: CLLocationCoordinate2D){

        UIView.animate(withDuration: 10, animations: {
            self.pointAnnotation.coordinate = destinationCoordinate
            
        }, completion:  { success in
            if success {
                if self.i > 0{
                    self.i = self.i-1
                    let tempDic = self.polyline[0]
                    self.moveCar(tempDic[self.i])
                }
                else{
                    // handle a successfully ended animation
                    print("Success")
                }
            } else {
                // handle a canceled animation, i.e move to destination immediately
                self.pointAnnotation.coordinate = destinationCoordinate
            }
        })
    }
    
    //start moving car
    @IBAction func startAction(_ sender: UIButton) {
         let tempDic = polyline[0]
         i = (tempDic.count)-2
        self.moveCar(tempDic[i])
    }
    
}



//Handle Autocomplete and search new location
extension ViewController: UISearchBarDelegate,  GMSAutocompleteResultsViewControllerDelegate {
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController, didAutocompleteWith place: GMSPlace) {
        searchController?.isActive = false
        // Do something with the selected place.
        print("Place name: \(place.name)")
        print("Place address: \(String(describing: place.formattedAddress))")
        print("Place attributions: \(place.attributions)")
        makeAnnotation(lattitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        location2 = CLLocationCoordinate2DMake(place.coordinate.latitude, place.coordinate.longitude)
        getPolylineRoute()
    }
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController, didFailAutocompleteWithError error: Error) {
         print("Error: ", error.localizedDescription)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}


