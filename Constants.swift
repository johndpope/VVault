//
//  Constants.swift
//  VVault
//
//  Created by Sean Zhang on 4/14/17.
//  Copyright © 2017 Sean Zhang. All rights reserved.
//

import Foundation
import AWSCore

class Constants: NSObject {
    
    // MARK: Required: Amazon Cognito Configuration
    
    static let COGNITO_REGIONTYPE = AWSRegionType.USEast1 // e.g. AWSRegionType.USEast1
    static let COGNITO_IDENTITY_POOL_ID = "us-east-1:fffd28eb-44c0-4f36-9432-065844b36dcb"
    
    
    // MARK: Required: Amazon Cognito User Pool Configuration
    
    static let COGNITO_IDENTITY_USER_POOL_ID = "us-east-1_21ZR1CedL"
    static let COGNITO_IDENTITY_USER_POOL_APP_CLIENT_ID = "35i1vjkf8g75e64j2ev21hg1u4"
    static let COGNITO_IDENTITY_USER_POOL_APP_CLIENT_SECRET = "30dhgou7e1tm1to9n0rln7ardiak29jrp90336ss7hm4kj2g040"
    
    
    
    // MARK: Optional: Enabl
    
    
    // MARK: Optional: Enable Facebook Login
    
    /**
     * OPTIONAL: Enable FB Login
     *
     * To enable FB Login
     * 1. Add FacebookAppID in App plist file
     * 2. Add the appropriate URL handler in project (should match FacebookAppID)
     */
    
    
    /*******************************************
     * DO NOT CHANGE THE VALUES BELOW HERE
     */
    
    static let BYOIProvider = "BYOI"
    static let DEVICE_TOKEN_KEY = "DeviceToken"
    static let COGNITO_DEVICE_TOKEN_KEY = "CognitoDeviceToken"
    static let COGNITO_PUSH_NOTIF = "CognitoPushNotification"
    static let GOOGLE_CLIENT_SCOPE = "https://www.googleapis.com/auth/userinfo.profile"
    static let GOOGLE_OIDC_SCOPE = "openid"
}
