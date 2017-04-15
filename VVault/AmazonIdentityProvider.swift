//
//  AmazonIdentityProvider.swift
//  VVault
//
//  Created by Sean Zhang on 4/15/17.
//  Copyright © 2017 Sean Zhang. All rights reserved.
//

import Foundation

import AWSCore
import AWSCognitoIdentityProvider

class AmazonIdentityProvider: AWSCognitoCredentialsProviderHelper {
    
    
    open var useEnhancedFlow: Bool
    
    
    public init(regionType: AWSRegionType, identityPoolId: String, useEnhancedFlow: Bool, identityProviderManager: AWSIdentityProviderManager?){
        
        self.useEnhancedFlow = useEnhancedFlow
        
        
    }
    
}
