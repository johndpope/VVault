//
//  DeveloperAuthenticatedIdentityProvider.swift
//  VVault
//
//  Created by Sean Zhang on 5/27/17.
//  Copyright © 2017 Sean Zhang. All rights reserved.
//

import Foundation
import AWSCore
import AWSCognito
import AWSCognitoIdentityProvider

class DeveloperAuthenticatedIdentityProvider: AWSAbstractCognitoCredentialsProviderHelper {
    

    
    override init() {
        super.init()
    }
    
    init(with regionType:AWSRegionType, id identityIdd: String, identityPoolId: String, logins: NSDictionary, providerName: String) {
        
    }
}
