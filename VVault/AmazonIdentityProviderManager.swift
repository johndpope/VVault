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
    
    fileprivate var loginCashe = NSMutableDictionary()
    
    /**
     Each entry in logins represents a single login with an identity provider. The key is the domain of the login provider (e.g. 'graph.facebook.com') and the value is the OAuth/OpenId Connect token that results from an authentication with that login provider.
     */
    func logins() -> AWSTask<NSDictionary> {
        
        
        return AWSTask(result: loginCashe)
        
    }
    
    func reset () {
        loginCashe = NSMutableDictionary()
    }
    
    func mergeLogins(_ logins: NSDictionary?) {
        
        var merge = NSMutableDictionary()
        merge = loginCashe
        
        //Add new logins
        if let unwrappedLogins = logins {
            for (key, value) in unwrappedLogins {
                merge[key] = value
            }
            //add to the loginCashe now for the new login
            self.loginCashe = merge
        }
        
    }
}
