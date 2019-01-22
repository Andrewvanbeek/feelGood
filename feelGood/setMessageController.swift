//
//  setMessageController.swift
//  feelGood
//
//  Created by Andrew Van Beek on 1/18/19.
//  Copyright © 2019 Andrew Van Beek. All rights reserved.
//

import Foundation
import UIKit
import OktaAuth
import SCLAlertView
import Alamofire
import SwiftyJSON

class setMessageController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var bgUIImage = UIImage.init(named: "Maldives.jpg")
        let myInsets : UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        bgUIImage = bgUIImage?.resizableImage(withCapInsets: myInsets)
        self.view.backgroundColor = UIColor.init(patternImage:bgUIImage!)
        getUserInfo()
    }
    
    
    
}

extension UIViewController {
    func getUserInfo() {
        OktaAuth
            .userinfo() { response, error in
                if error != nil {
                    print("Error: \(error!)")
                }
                
                if let userinfo = response {
                    var array = [""]
                    userinfo.forEach {
                        //print("\($0): \($1)")
                        array.append("\($0): \($1) \n" )
                    }
                    var userInfo = array.joined()
                    print(userInfo)
                    DispatchQueue.main.async() {
                        SCLAlertView().showInfo("User info", subTitle: userInfo)
                    }
                    
                    
                }
        }
    }
    
    func sendHappyPlace(place: String) {
        OktaAuth
            .userinfo() { response, error in
                if error != nil {
                    print("Error: \(error!)")
                }
            
                if var userinfo = response {
                print(userinfo)
                    var info = JSON(userinfo)
                    var userInformation = info.dictionaryValue
                    var userId = userInformation["sub"]!.stringValue
               
                    var accessToken = OktaAuth.tokens?.get(forKey: "accessToken")
                    var header = ["Authorization" : "Bearer " + accessToken!]
                    var url = "https://us-central1-okta-example-playground.cloudfunctions.net/sendHappyPlace"
                    Alamofire.request(url, method: .get, parameters: ["userId": userId, "placesToAdd": place], headers: header).responseJSON{ response in
                        
                        print(response)
                        
                    }
                }
        }
    }
    
    func sendHealthData(healthValue: Double, healthType: String) {
        OktaAuth
            .userinfo() { response, error in
                if error != nil {
                    print("Error: \(error!)")
                }
                
                if var userinfo = response {
                    print(userinfo)
                    var info = JSON(userinfo)
                    var userInformation = info.dictionaryValue
                    var userId = userInformation["sub"]!.stringValue
                    
                    var accessToken = OktaAuth.tokens?.get(forKey: "accessToken")
                    var header = ["Authorization" : "Bearer " + accessToken!]
                    var url = "https://us-central1-okta-example-playground.cloudfunctions.net/sendHealthData"
                    Alamofire.request(url, method: .get, parameters: ["userId": userId, "type": healthType, "hValue": healthValue], headers: header).responseJSON{ response in
                        
                        print(response)
                        
                    }
                }
        }
    }
   
}
