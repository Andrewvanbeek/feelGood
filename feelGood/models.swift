//
//  models.swift
//  sdkTest
//
//  Created by Andrew Vanbeek on 1/21/18.
//  Copyright © 2018 Andrew Vanbeek. All rights reserved.
//

import Foundation


class OktaConfiguration {
    let kIssuer: String!
    let kClientID: String!
    let kRedirectURI: String!
    let kAppAuthExampleAuthStateKey: String!
    let apiEndpoint: URL!
    let token: String!
    let gmapsKey: String!
    
    
    init(){
        kIssuer = "https://vanbeektech.okta.com"                        // Base url of Okta Developer domain
        kClientID = " replace with client id from Okta open id app"                                  // Client ID of Application
        apiEndpoint = URL(string: "https://vanbeektech.okta.com")         // Resource Server URL
        kRedirectURI = " replace with redirect uri" //redirect URI fro
        kAppAuthExampleAuthStateKey = "com.okta.openid.authState"
        token = "" //Keep the SWSS before the API key like SWSS XXXXXXXXXXXXXXX
        gmapsKey = "AIzaSyBy1wmf9ySN9NZuukP5nPAVJvFbxya0LTs"
        
    }
    
    
}
