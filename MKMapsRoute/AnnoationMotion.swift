//
//  AnnoationMotion.swift
//  MKMapsRoute
//
//  Created by Mansi Mahajan on 7/16/18.
//  Copyright © 2018 Mansi Mahajan. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

class AnnotationMotion: NSObject, CLLocationManagerDelegate {
    
    var oldLat: Double!
    var newLat: Double!
    var oldLong: Double!
    var newLong: Double!
    var pointAnnotation   : CarCustomAnnotation!
    var vc: ViewController = ViewController()
    var sourceCoordinate: CLLocationCoordinate2D!
    
    func degreesToRadians(degrees: Double) -> Double { return degrees * .pi / 180.0 }
    
    func radiansToDegrees(radians: Double) -> Double { return radians * 180.0 / .pi }
    
    func getHeadingForDirectionFromCoordinate (_ fromLoc : CLLocationCoordinate2D , toLoc : CLLocationCoordinate2D) -> Double {
        
        let  fLat = degreesToRadians(degrees: fromLoc.latitude)
        let  fLng = degreesToRadians(degrees: fromLoc.longitude)
        let  tLat = degreesToRadians(degrees: toLoc.latitude)
        let  tLng = degreesToRadians(degrees: toLoc.latitude)
        
        let degree = radiansToDegrees(radians: atan2(sin(tLng-fLng) * cos(tLat), cos(fLat)*sin(tLat)-sin(fLat)*cos(tLat)*cos(tLng-fLng)))
        
        if (degree >= 0) {
            return degree
        } else {
            return 360.0 + degree
        }
    }

    
    
    //Inert Animation Duration and Destination Coordinate which you are getting from server.
    func  moveCar(_ destinationCoordinate : CLLocationCoordinate2D) {
        UIView.animate(withDuration: 20, animations: {
            self.pointAnnotation.coordinate = destinationCoordinate
        }, completion:  { success in
            if success {
                // handle a successfully ended animation
                self.resetCarPosition()
            } else {
                // handle a canceled animation, i.e move to destination immediately
                self.pointAnnotation.coordinate = destinationCoordinate
            }
        })
    }
    
    func resetCarPosition() {
        self.pointAnnotation.courseDegrees = 0.0
        self.vc.mapKit.remove(self.vc.mapKit.overlays[0])
        self.vc.annotationView.transform = CGAffineTransform(rotationAngle:CGFloat(pointAnnotation.courseDegrees))
        self.pointAnnotation.coordinate = self.sourceCoordinate!
    }
}

class CarCustomAnnotation: MKPointAnnotation {
    var pinCustomImageName:String!
    var courseDegrees : Double! // Change The Value for Rotating Car Image Position
}
