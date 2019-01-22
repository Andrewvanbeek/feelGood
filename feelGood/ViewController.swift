//
//  ViewController.swift
//  feelGood
//
//  Created by Andrew Van Beek on 12/28/18.
//  Copyright © 2018 Andrew Van Beek. All rights reserved.
//

import UIKit
import OktaAuth
import AppAuth
import KeychainSwift

class ViewController: UIViewController {

    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var label: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        var bgUIImage = UIImage.init(named: "Maldives.jpg")
        let myInsets : UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        bgUIImage = bgUIImage?.resizableImage(withCapInsets: myInsets)
        self.view.backgroundColor = UIColor.init(patternImage:bgUIImage!)
        self.logo.center.x = self.view.center.x
        self.label.center.x = self.view.center.x
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        
        if(OktaAuth.tokens?.get(forKey: "accessToken") != nil){
            
            self.toMenu()
        }
        
    }
    
    @IBAction func signIn(_ sender: Any) {
        self.authenticate()
    }
 
    
    func authenticate() {
        OktaAuth
            .login()
            .start(self) {
                response, error in
                
                if error != nil { print(error!) }
                
                // Success
                if let tokenResponse = response {
                    //UserDefaults.standard.set(tokenResponse.accessToken! as String, forKey: "accessToken")
                    //UserDefaults.standard.set(tokenResponse.accessToken! as String, forKey: "accessToken")
                    print(tokenResponse)
                    
                    OktaAuth.tokens?.set(value: tokenResponse.accessToken!, forKey: "accessToken")
                    OktaAuth.tokens?.set(value: tokenResponse.idToken!, forKey: "idToken")
                    UserDefaults.standard.setValue(tokenResponse.accessToken!, forKey: "user_auth_token")
                    let keychain = KeychainSwift()
                    keychain.set(tokenResponse.accessToken!, forKey: "atoken")
                    DispatchQueue.main.async() {
                        
                        self.performSegue(withIdentifier: "toMenu", sender: nil)
                        
                        
                    }
                }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func toMenu() {
        DispatchQueue.main.async() {
            self.performSegue(withIdentifier: "toMenu", sender: nil)
        }
    }


}

