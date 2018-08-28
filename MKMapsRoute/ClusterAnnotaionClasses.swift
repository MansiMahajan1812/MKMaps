//
//  ClusterAnnotaionClasses.swift
//  MKMapsRoute
//
//  Created by Mansi Mahajan on 7/18/18.
//  Copyright © 2018 Mansi Mahajan. All rights reserved.
//

import Foundation
import MapKit

class CarCustomAnnotation: MKPointAnnotation {
    var pinCustomImageName:String!
    var courseDegrees : Double!
    
}
class Bike: MKPointAnnotation {
    
    enum BikeType: Int {
        case unicycle
        case tricycle
    }
    
    var pinCustomImageName = "taxi"
    var type: BikeType = .tricycle
    
    class func bikes(latitude: Double, longitude: Double) -> Bike {
            let bike = Bike()
            bike.coordinate = CLLocationCoordinate2DMake(latitude, longitude)
            return bike
    }
    
}


@available(iOS 11.0, *)
class BikeView: MKPinAnnotationView {
    override var annotation: MKAnnotation? {
        willSet {
            if let bike = newValue as? Bike {
                clusteringIdentifier = "bike"
                
        }
    }
    
  }
}

class ClusterView: MKAnnotationView {
 //    weak var customCalloutView: AnnotationPOPUp!
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        if #available(iOS 11.0, *) {
            displayPriority = .defaultHigh
        } else {
            // Fallback on earlier versions
        }
        if #available(iOS 11.0, *) {
            collisionMode = .circle
        } else {
            // Fallback on earlier versions
        }
        centerOffset = CGPoint(x: 0, y: -10) // Offset center point to animate better with marker annotations
         //self.canShowCallout = false // 1
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
      //  self.canShowCallout = false // 1
    }
    
    override var annotation: MKAnnotation? {
        willSet {
            if #available(iOS 11.0, *) {
                if let cluster = newValue as? MKClusterAnnotation {
                    image = #imageLiteral(resourceName: "taxi")
            }
        }
        }
    }
}
