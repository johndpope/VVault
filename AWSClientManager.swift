/*
 * Copyright 2015 Amazon.com, Inc. or its affiliates. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License").
 * You may not use this file except in compliance with the License.
 * A copy of the License is located at
 *
 *  http://aws.amazon.com/apache2.0
 *
 * or in the "license" file accompanying this file. This file is distributed
 * on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
 * express or implied. See the License for the specific language governing
 * permissions and limitations under the License.
 */

/*
 * Copyright 2016 BJSS, Inc. or its affiliates. All Rights Reserved.
 *
 * Created by Andrea Scuderi on 08/09/2016.
 *
 * Licensed under the Apache License, Version 2.0 (the "License").
 * You may not use this file except in compliance with the License.
 * A copy of the License is located at
 *
 *  https://github.com/bjss/aws-sdk-ios-samples/blob/master/LICENSE
 *
 * or in the "license" file accompanying this file. This file is distributed
 * on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
 * express or implied. See the License for the specific language governing
 * permissions and limitations under the License.
 */

import Foundation
import UICKeyChainStore
import AWSCore
import AWSCognito
import AWSCognitoIdentityProvider
import FBSDKCoreKit
import FBSDKLoginKit
import FBSDKShareKit

class AmazonClientManager : NSObject {
    
    static let sharedInstance = AmazonClientManager()
    
    enum Provider: String {
        case COGNITO_USERPOOL, FB, GOOGLE
        
    }
    
    
    //KeyChain Constants
    let COGNITO_USERPOOL_PROVIDER = Provider.COGNITO_USERPOOL.rawValue
    let FB_PROVIDER = Provider.FB.rawValue
    
    typealias AWSContinuationBlock = (AWSTask<AnyObject>)->Any?
    
    //Properties
    var keyChain: UICKeyChainStore
    var completionHandler: AWSContinuationBlock?
    var credentialsProvider: AWSCognitoCredentialsProvider?
    var loginViewController: UIViewController?
    var identityProviderManager: AmazonIdentityProviderManager?
    var fbLoginManager: FBSDKLoginManager?
    
    
    override init() {
        keyChain = UICKeyChainStore(service: "\(Bundle.main.bundleIdentifier!).\(AmazonClientManager.self)")
        print("UICKeyChainStore: \(Bundle.main.bundleIdentifier!).\(AmazonClientManager.self)")
        
        super.init()
        
        self.initializeAWS()
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [AnyHashable: Any]?) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(_: application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    
    // MARK: General Login
    
    func isConfigured() -> Bool {
        return !(Constants.COGNITO_IDENTITY_POOL_ID == "YourCognitoIdentityPoolId" || Constants.COGNITO_REGIONTYPE == AWSRegionType.Unknown)
    }
    
    func resumeSession(_ completionHandler: @escaping AWSContinuationBlock) {
        self.completionHandler = completionHandler
        
        if self.keyChain[FB_PROVIDER] != nil {
            self.reloadFBSession()
        }
        
        if self.credentialsProvider == nil {
            self.completeLogin(NSMutableDictionary())
        }
    }
    
    //Sends the appropriate URL based on login provider
    func application(_ application: UIApplication,
                     openURL url: URL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        if FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation) {
            return true
        }
        return false
    }
    
    func completeLogin(_ logins: NSMutableDictionary) {
        
        var task: AWSTask<NSString>?
        
        if self.credentialsProvider == nil {
            
            task = self.initializeClients(logins)
            self.identityProviderManager?.mergeLogins(logins)
            
        } else {
            
            
            self.identityProviderManager?.mergeLogins(logins)
            
            //Force a refresh of credentials to see if merge is necessary
            credentialsProvider?.invalidateCachedTemporaryCredentials()
            
            
            task = credentialsProvider?.getIdentityId()
        }
        
        task?.continueWith(block: {
            (task: AWSTask!) -> AnyObject! in
            if (task.error != nil) {
                let userDefaults = UserDefaults.standard
                let currentDeviceToken: Data? = userDefaults.object(forKey: Constants.DEVICE_TOKEN_KEY) as? Data
                var currentDeviceTokenString : String
                
                if let currentDeviceToken = currentDeviceToken {
                    currentDeviceTokenString =
                        
                        currentDeviceToken.base64EncodedString(options:  [])
                    
                } else {
                    currentDeviceTokenString = ""
                }
                
                if currentDeviceToken != nil && currentDeviceTokenString != userDefaults.string(forKey: Constants.COGNITO_DEVICE_TOKEN_KEY) {
                    
                    AWSCognito.default().registerDevice(currentDeviceToken as Data!).continueWith(block: { (task) -> Any? in
                        if (task.error == nil) {
                            userDefaults.set(currentDeviceTokenString, forKey: Constants.COGNITO_DEVICE_TOKEN_KEY)
                            userDefaults.synchronize()
                        }
                        return nil
                    })
                }
            }
            return task
        }).continueWith(block: { (task) -> Any? in
            
            if let completionHandler = self.completionHandler {
                return completionHandler(task)
            }
            return nil
        })
    }
    
    func initializeAWS() {
        
        print("Initializing and Registering Identity User Pool")
        AWSDDLog.sharedInstance.logLevel = .verbose
        let serviceConfiguration = AWSServiceConfiguration(region: Constants.COGNITO_REGIONTYPE, credentialsProvider: nil)
        let userPoolConfiguration = AWSCognitoIdentityUserPoolConfiguration(clientId: Constants.COGNITO_IDENTITY_USER_POOL_APP_CLIENT_ID, clientSecret: Constants.COGNITO_IDENTITY_USER_POOL_APP_CLIENT_SECRET,poolId: Constants.COGNITO_IDENTITY_USER_POOL_ID)
        AWSCognitoIdentityUserPool.register(with: serviceConfiguration,
                                            userPoolConfiguration: userPoolConfiguration,
                                            forKey: "UserPool")
        
        print("Creating credential provider")
        self.identityProviderManager = AmazonIdentityProviderManager.sharedInstance
        let credentialsProvider = AWSCognitoCredentialsProvider(
            regionType: Constants.COGNITO_REGIONTYPE,
            identityPoolId: Constants.COGNITO_IDENTITY_POOL_ID,
            identityProviderManager: identityProviderManager)
        let defaultServiceConfiguration = AWSServiceConfiguration(region: Constants.COGNITO_REGIONTYPE, credentialsProvider: credentialsProvider)
        
        print("Implementing the new AWS service configuration")
        AWSServiceManager.default().defaultServiceConfiguration = defaultServiceConfiguration
        
        
    }
    
    func initializeClients(_ loginAs: NSMutableDictionary) -> AWSTask<NSString>? {
        AWSDDLog.sharedInstance.logLevel = .verbose
        self.credentialsProvider = AWSServiceManager.default().defaultServiceConfiguration.credentialsProvider as? AWSCognitoCredentialsProvider
        return self.credentialsProvider?.getIdentityId()
    }
    

    func loginFromView(_ theViewController: UIViewController, withCompletionHandler completionHandler: @escaping AWSContinuationBlock) {
        self.completionHandler = completionHandler
        self.loginViewController = theViewController
        self.displayLoginSheet()
    }
    
    func logOut(_ completionHandler: @escaping AWSContinuationBlock) {
        
        // Call individual logouts
        if self.isLoggedInWithCognito() {
            self.cognitoLogout()
        } else if self.isLoggedinWithFacebook() {
            self.facebookLogout()
        }
        
        // Wipe credentials
        self.identityProviderManager?.reset()
        AWSCognito.default().wipe()
        self.credentialsProvider?.clearKeychain()
        self.credentialsProvider?.clearCredentials()
        
        // Setup views when user logout
        AWSTask(result: nil).continueWith(block: completionHandler)
    }
    
    func isLoggedIn() -> Bool {
        return isLoggedInWithCognito() || isLoggedinWithFacebook()
    }
    
    // MARK: Cognito Login
    
    func isLoggedInWithCognito() -> Bool {
        let userPool = AWSCognitoIdentityUserPool(forKey: "UserPool")
        let value = self.keyChain[COGNITO_USERPOOL_PROVIDER] != nil &&  userPool.currentUser()?.isSignedIn ?? false
        return value
    }
    
    func cognitoLogin(_ username: String, password: String, delegate: AWSCognitoIdentityInteractiveAuthenticationDelegate?, withCompletionHandler completionHandler: @escaping AWSContinuationBlock) {
        self.completionHandler = completionHandler
        let userPool = AWSCognitoIdentityUserPool(forKey: "UserPool")
        let user = userPool.getUser(username)
        user.getSession(username, password: password, validationData: nil).continueWith(executor: AWSExecutor.mainThread(), block: {
            (task: AWSTask!) -> AnyObject! in
            
            if task.isCancelled {
                self.errorAlert("Login Canceled")
            } else if let error = task.error {
                DispatchQueue.main.async {
                    self.errorAlert("Login failed.\n" + error.localizedDescription)
                }
                AWSTask(error: error).continueWith(block: self.completionHandler!)
                
            } else {
                
                let provider = "cognito-idp.us-east-1.amazonaws.com/\(Constants.COGNITO_IDENTITY_USER_POOL_ID)"
                let userSession = task.result
                let token = userSession?.idToken?.tokenString ?? ""
                self.keyChain[self.COGNITO_USERPOOL_PROVIDER] = provider
                self.completeLogin( [provider as NSString:token as NSString] )
            }
            return nil
        })
        
    }
    
    func cognitoLogout() {
        let userPool = AWSCognitoIdentityUserPool(forKey: "UserPool")
        userPool.currentUser()?.signOutAndClearLastKnownUser()
        self.keyChain[COGNITO_USERPOOL_PROVIDER] = nil
    }
    
    func COGNITOLogin() {
        var username: UITextField!
        var password: UITextField!
        let COGNITOLoginAlert = UIAlertController(title: "Login", message: "Enter Cognito User Pool Account Credentials", preferredStyle: UIAlertControllerStyle.alert)
        
        COGNITOLoginAlert.addTextField { (textField) -> Void in
            textField.placeholder = "Username"
            username = textField
        }
        COGNITOLoginAlert.addTextField { (textField) -> Void in
            textField.placeholder = "Password"
            textField.isSecureTextEntry = true
            password = textField
        }
        
        let loginAction = UIAlertAction(title: "Login", style: .default) { (action) -> Void in
            self.cognitoLogin(username.text!, password: password.text!, delegate: nil, withCompletionHandler: self.completionHandler!)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        COGNITOLoginAlert.addAction(loginAction)
        COGNITOLoginAlert.addAction(cancelAction)
        
        self.loginViewController?.present(COGNITOLoginAlert, animated: true, completion: nil)
    }
    
    // MARK: Facebook Login
    
    func isLoggedinWithFacebook() -> Bool {
        let loggedIn = FBSDKAccessToken.current() != nil
        return self.keyChain[FB_PROVIDER] != nil && loggedIn
    }
    
    func reloadFBSession() {
        if FBSDKAccessToken.current() != nil {
            print("Reloading Facebook Session")
            self.completeFacebookLogin()
        }
    }
    
    func facebookLogin() {
        
        let facebookHandler: FBSDKLoginManagerRequestTokenHandler? = {
            (result: FBSDKLoginManagerLoginResult?, error: Error?) in
            if (error != nil) {
                DispatchQueue.main.async() {
                    print("Error whiel logging in Facebook: \(String(describing: error))")
                }
            } else if (result?.isCancelled)! {
                // do nothing
            } else {
                self.completeFacebookLogin()
            }
        }
        
        if FBSDKAccessToken.current() != nil {
            self.completeFacebookLogin()
        } else {
            if self.fbLoginManager == nil {
                self.fbLoginManager = FBSDKLoginManager()
                self.fbLoginManager?.logIn(
                    withReadPermissions: nil,
                    from: nil,
                    handler: facebookHandler)
            }
        }
    }
    
    func facebookLogout() {
        if self.fbLoginManager == nil {
            self.fbLoginManager = FBSDKLoginManager()
        }
        self.fbLoginManager?.logOut()
        self.keyChain[FB_PROVIDER] = nil
    }
    
    func completeFacebookLogin() {
        self.keyChain[FB_PROVIDER] = "YES"
        self.completeLogin(["graph.facebook.com": FBSDKAccessToken.current().tokenString])
    }
    
    // MARK: UI Helpers
    
    func displayLoginSheet() {
        let loginProviders = UIAlertController(title: nil, message: "Login With:", preferredStyle: .actionSheet)
        
        let cognitoLoginAction = UIAlertAction(title: "Cognito User Pool", style: .default) {
            (alert: UIAlertAction) -> Void in
            self.COGNITOLogin()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) {
            (alert: UIAlertAction!) -> Void in
            AWSTask(result: nil).continueWith(block: self.completionHandler!)
        }
        
        loginProviders.addAction(cognitoLoginAction)
        loginProviders.addAction(cancelAction)
        
        self.loginViewController?.present(loginProviders, animated: true, completion: nil)
    }
    
    func errorAlert(_ message: String) {
        let errorAlert = UIAlertController(title: "Error", message: "\(message)", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default) { (alert: UIAlertAction) -> Void in }
        
        errorAlert.addAction(okAction)
        
        self.loginViewController?.present(errorAlert, animated: true, completion: nil)
    }
}
