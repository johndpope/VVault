//
//  AmazonIdentityProviderManager.swift
//  VVault
//
//  Created by Sean Zhang on 4/14/17.
//  Copyright © 2017 Sean Zhang. All rights reserved.
//


import Foundation
import AWSCognitoIdentityProvider

class AmazonIdentityProviderManager: NSObject, AWSIdentityProviderManager {
    
    static let sharedInstance = AmazonIdentityProviderManager()
    fileprivate var loginCache = NSMutableDictionary()
    
    func logins() -> AWSTask<NSDictionary> {
        return AWSTask(result: loginCache)
    }
    
    func reset() {
        self.loginCache = NSMutableDictionary()
    }
    
    func mergeLogins(_ logins: NSDictionary?) {
        var merge = NSMutableDictionary()
        merge = loginCache
        //Add new logins
        if let unwrappedLogins = logins {
            for (key, value) in unwrappedLogins {
                merge[key] = value
            }
            self.loginCache = merge
        }
    }
}
