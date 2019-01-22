//
//  AugmentedViewController.swift
//  feelGood
//
//  Created by Andrew Van Beek on 1/21/19.
//  Copyright © 2019 Andrew Van Beek. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps
import GooglePlaces
import ARCL
import CoreLocation
import SceneKit
import SCLAlertView
import OktaAuth
import SCLAlertView
import Alamofire



class AugmentedViewController: UIViewController, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private let dataProvider = GoogleDataProvider()
    private let searchRadius: Double = 1000
    private var searchedTypes = ["bakery", "bar", "cafe", "grocery_or_supermarket", "restaurant"]
    var sceneLocationView = SceneLocationView()

    override func viewDidLoad() {
        super.viewDidLoad()
        var bgUIImage = UIImage.init(named: "Maldives.jpg")
        let myInsets : UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        bgUIImage = bgUIImage?.resizableImage(withCapInsets: myInsets)
        self.view.backgroundColor = UIColor.init(patternImage:bgUIImage!)
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        sceneLocationView.run()
        view.addSubview(sceneLocationView)
    }
    
    func fetchNearbyPlaces(coordinate: CLLocationCoordinate2D, altitude: Double) {
        
        
        dataProvider.fetchPlacesNearCoordinate(coordinate, radius:searchRadius, types: searchedTypes) { places in
            places.forEach {
              print($0.name)
               let location = CLLocation(coordinate: $0.coordinate, altitude: altitude)
                
                let image = UIImage(named: "placepin.png")!
                var imageWithLabel = self.textToImage(drawText: $0.name, inImage: image, atPoint: CGPoint(x: image.topCapHeight, y: image.leftCapWidth))
                let annotationNode = LocationAnnotationNode(location: location, image: imageWithLabel)
                let scene = SCNScene()
                let cubeGeometry = SCNBox(width: 10, height: 10, length: 10,
                                          chamferRadius: 0)
                cubeGeometry.firstMaterial?.diffuse.contents = UIColor.yellow
                let cubeNode = SCNNode(geometry: cubeGeometry)
//                scene.rootNode.addChildNode(cubeNode)
//                annotationNode.addChildNode(cubeNode)
                annotationNode.tag = $0.name
                annotationNode.name = $0.name
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(sender:)))
                self.sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: annotationNode)
                var node = self.sceneLocationView.findNodes(tagged: $0.name)[0]
                node.name = $0.name
                print(node.name)
            }
        }
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        print("tap")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        sceneLocationView.frame = view.bounds
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard status == .authorizedWhenInUse else {
            return
        }
        
        locationManager.startUpdatingLocation()
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        guard let touch = touches.first
            else { return }
        
        guard let hitResults = sceneLocationView.hitTest(touch.location(in: sceneLocationView), options: nil).first
            else {return}
        print("TEST")
        print(hitResults)
        var trueNode = hitResults.node.parent as! LocationAnnotationNode
        print(trueNode.name)
         print(trueNode.tag)
         print(trueNode.location)
        DispatchQueue.main.async() {
            let alertView = SCLAlertView()
            alertView.addButton("Second Button") {
                self.sendHappyPlace(place: trueNode.name!)
            }
            alertView.showSuccess("Add Happy Place?", subTitle: trueNode.name!)
        }
        
    }
    
    func textToImage(drawText text: String, inImage image: UIImage, atPoint point: CGPoint) -> UIImage {
        let textColor = UIColor.white
        let textFont = UIFont(name: "Montserrat-Light", size: 12)!
        
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(image.size, false, scale)
        
        let textFontAttributes = [
            NSAttributedString.Key.font: textFont,
            NSAttributedString.Key.foregroundColor: textColor,
            ] as [NSAttributedString.Key : Any]
        image.draw(in: CGRect(origin: CGPoint.zero, size: image.size))
        
        let rect = CGRect(origin: point, size: image.size)
        text.draw(in: rect, withAttributes: textFontAttributes)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }
        
        locationManager.stopUpdatingLocation()
    
        fetchNearbyPlaces(coordinate: location.coordinate, altitude: location.altitude)
    }
    

    
    
}

extension LocationAnnotationNode {
    
    func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touch")
    }

}
