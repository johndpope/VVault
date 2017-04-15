//
//  AWSClientManager.swift
//  VVault
//
//  Created by Sean Zhang on 4/14/17.
//  Copyright © 2017 Sean Zhang. All rights reserved.
//

import Foundation
import UICKeyChainStore
import AWSCore
import AWSCognito
import AWSCognitoIdentityProvider
import FBSDKCoreKit
import FBSDKLoginKit
import FBSDKShareKit

class AWSClientManager: NSObject {
    
    static let sharedInstance = AWSClientManager()
    
    enum Provider: String {
        case FB, GOOGLE, AMAZON,TWITTER, DIGITS, BYOI, COGNITO_USERPOOL
    }
    
    //Keychain Constants
    let FB_PROVIDER = Provider.FB.rawValue
    let GOOGLE_PROVIDER = Provider.GOOGLE.rawValue
    let AMAZON_PROVIDER = Provider.AMAZON.rawValue
    let TWITTER_PROVIDER = Provider.TWITTER.rawValue
    let DIGITS_PROVIDER = Provider.DIGITS.rawValue
    let BYOI_PROVIDER = Provider.BYOI.rawValue
    let COGNITO_USERPOOL_PROVIDER = Provider.COGNITO_USERPOOL.rawValue
    
    typealias AWSContinuationBlock =  (AWSTask<AnyObject>) -> Any?
    
    //Properties
    var keyChain: UICKeyChainStore
    var completionHandler: AWSContinuationBlock?
    var fbLoginManager: FBSDKLoginManager?
    var credentialsProvider: AWSCognitoCredentialsProvider?
    var loginViewController: UIViewController?
    var identityProviderManager: AmazonIdentityProviderManager?
   
    
    override init() {
        keyChain = UICKeyChainStore(service: "\(Bundle.main.bundleIdentifier!).\(AWSClientManager.self)")
        
        super.init()
        
        self.initializeAWS()
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [AnyHashable: Any]?) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(_:application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    // MARK: GENERAL LOGIN
    
    func isConfiguired() -> Bool {
        return !(Constants.COGNITO_IDENTITY_USER_POOL_ID == "YourCognitoIdentityPoolId" || Constants.COGNITO_REGIONTYPE == AWSRegionType.Unknown)
    }
    
    func resumeSession(_ completionHandler: @escaping AWSContinuationBlock) {
        self.completionHandler = completionHandler
        
        if self.keyChain[FB_PROVIDER] != nil {
            //self.reloadFBSession()
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
            print("I guess that the credential Provider is nil at this point...................\n")
            task = self.initializeClients(logins)
            self.identityProviderManager?.mergeLogins(logins)
            
        } else {
            
            self.identityProviderManager?.mergeLogins(logins)
            
            //Force a refresh of credentials to see if merge is necessary
            credentialsProvider?.invalidateCachedTemporaryCredentials()
            
            task = credentialsProvider?.getIdentityId()
            print("Sean needs to know the getIdentityID...................\n")
            print(task?.result ?? "I guess there is no value at this point")
        }
        
        task?.continueWith(block: {
            (task: AWSTask!) -> AnyObject! in
            if (task.error != nil) {
                let userDefaults = UserDefaults.standard
                let currentDeviceToken: Data? = userDefaults.object(forKey: DEVICE_TOKEN_KEY) as? Data
                var currentDeviceTokenString : String
                
                if let currentDeviceToken = currentDeviceToken {
                    currentDeviceTokenString =
                        
                        currentDeviceToken.base64EncodedString(options:  [])
                    
                } else {
                    currentDeviceTokenString = ""
                }
                
                if currentDeviceToken != nil && currentDeviceTokenString != userDefaults.string(forKey: COGNITO_DEVICE_TOKEN_KEY) {
                    
                    AWSCognito.default().registerDevice(currentDeviceToken as Data!).continueWith(block: { (task) -> Any? in
                        if (task.error == nil) {
                            userDefaults.set(currentDeviceTokenString, forKey: COGNITO_DEVICE_TOKEN_KEY)
                            userDefaults.synchronize()
                        }
                        return nil
                    })
                }
            }
            return task
        }).continueWith(block: { (task) -> Any? in
            
            if let completionHandler = self.completionHandler {
                print("Returning the completion handler..............")
                print(task.isFaulted)
                return completionHandler(task)
            }
            print("Printing the result right now")
            print(task.result as! String)
            return nil
        })
    }
    
    func initializeAWS() {
        print("Initializing Clients................")
        
        AWSLogger.default().logLevel = .verbose
        
        //Cognito User Pool Configuration
        let serviceConfiguration = AWSServiceConfiguration(region: AWSRegionConstant , credentialsProvider: nil)
        
        let userPoolConfiguration = AWSCognitoIdentityUserPoolConfiguration(clientId: userPoolClientId, clientSecret: userPoolClientSecret, poolId: userPoolId)
        
        AWSCognitoIdentityUserPool.register(with: serviceConfiguration, userPoolConfiguration: userPoolConfiguration, forKey: "UserPool")
        
        self.identityProviderManager = AmazonIdentityProviderManager.sharedInstance
        
        /*
        let identityProvider = DeveloperAuthenticatedIdentityProvider(
            regionType: Constants.COGNITO_REGIONTYPE,
            identityPoolId: Constants.COGNITO_IDENTITY_POOL_ID,
            providerName: Constants.DEVELOPER_AUTH_PROVIDER_NAME,
            authClient: self.devAuthClient,
            identityProviderManager: self.identityProviderManager)
        
        */
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType: Constants.COGNITO_REGIONTYPE, identityPoolId: Constants.COGNITO_IDENTITY_POOL_ID, identityProviderManager: identityProviderManager)
 
        
        
        let defaultServiceConfiguration = AWSServiceConfiguration(region: AWSRegionConstant, credentialsProvider: credentialsProvider)
        
        AWSServiceManager.default().defaultServiceConfiguration = defaultServiceConfiguration
        
        
    }
    
    func initializeClients(_ loginAs: NSMutableDictionary) -> AWSTask<NSString>? {
        print("Initializing Clients...")
        
        AWSLogger.default().logLevel = AWSLogLevel.verbose
        self.credentialsProvider = AWSServiceManager.default().defaultServiceConfiguration.credentialsProvider as? AWSCognitoCredentialsProvider
        return self.credentialsProvider?.getIdentityId()
    }
    

    
    // MARK: COGNITO LOGIN
    
    func isLoggedInWithCognito() -> Bool {
        let userPool = AWSCognitoIdentityUserPool(forKey: "UserPool")
        let value = self.keyChain[COGNITO_USERPOOL_PROVIDER] != nil &&  userPool.currentUser()?.isSignedIn ?? false
        return value
    }
    
    /*
     * This function receives the password and username from the UI and then call the
     * userSession to see if the actual token can be retrieved or not
     */
    func cognitoLogin(_ username: String,
                      password: String,
                      delegate: AWSCognitoIdentityInteractiveAuthenticationDelegate?,
                      withCompletionHandler completionHandler: @escaping AWSContinuationBlock) {
        
        self.completionHandler = completionHandler
        let userPool = AWSCognitoIdentityUserPool(forKey: "UserPool")
        let user = userPool.getUser(username)
        user.getSession(username, password: password, validationData: nil).continueWith(executor: AWSExecutor.mainThread(), block: { (task: AWSTask<AWSCognitoIdentityUserSession>) -> Any? in
            if task.isCancelled {
                print("Task is cancelled for login")
                self.errorAlert("Task is cancelled")
            } else if let error = task.error {
                print("Task has error and failed to login")
                self.errorAlert(error.localizedDescription)
            } else {
                print("Login was not cancelled and without an error")
                let provider = "cognito-idp.us-east-1.amazonaws.com/\(identityPoolId)"
                let userSession = task.result
                let token = userSession?.idToken?.tokenString ?? ""
                self.keyChain[self.COGNITO_USERPOOL_PROVIDER] = provider
                self.completeLogin([provider as NSString: token as NSString])
                print("I need to know the identity ID.............>Thi si si Sean")
                print(self.credentialsProvider?.identityId ?? "I guess there is no identity ID")
            }
            if task.isCompleted {
                print("Task is completed")
            }
            print("getSession right now")
            return nil
        })
        
    }
    
    func cognitoLogout() {
        //Cognito User Pool
        let userPool = AWSCognitoIdentityUserPool(forKey: "UserPool")
        userPool.currentUser()?.signOutAndClearLastKnownUser()
        self.keyChain[COGNITO_USERPOOL_PROVIDER] = nil
    }
    
    // MARK: FACEBOOK LOGIN
    
    func isLoggedInWithFacebook() -> Bool {
        let loggedIn = FBSDKAccessToken.current() != nil
        
        return self.keyChain[FB_PROVIDER] != nil && loggedIn
    }
    
    func reloadFBSession() {
        if FBSDKAccessToken.current() != nil {
            print("Reloading Facebook Session")
            self.completeFBLogin()
        }
    }
    
    func fbLogin() {
        if FBSDKAccessToken.current() != nil {
            self.completeFBLogin()
        } else {
            if self.fbLoginManager == nil {
                self.fbLoginManager = FBSDKLoginManager()
                self.fbLoginManager?.logIn(withReadPermissions: ["public_profile"], from: self.loginViewController) {
                    (result, error) -> Void in
                    
                    if (error != nil) {
                        DispatchQueue.main.async {
                            self.errorAlert("Error logging in with FB: " + (error?.localizedDescription)!)
                        }
                    } else if (result?.isCancelled)! {
                        //Do nothing
                    } else {
                        self.completeFBLogin()
                    }
                }
            }
        }
        
    }
    
    func fbLogout() {
        if self.fbLoginManager == nil {
            self.fbLoginManager = FBSDKLoginManager()
        }
        self.fbLoginManager?.logOut()
        self.keyChain[FB_PROVIDER] = nil
    }
    
    func completeFBLogin() {
        self.keyChain[FB_PROVIDER] = "YES"
        self.completeLogin(["graph.facebook.com" : FBSDKAccessToken.current().tokenString as NSString])
    }
    
    // MARK: UI HELPER
    
    func loginFromView(_ theViewController: UIViewController, withCompletionHandler completionHandler: @escaping AWSContinuationBlock) {
        self.completionHandler = completionHandler
        self.loginViewController = theViewController
        self.displayLoginSheet()
    }
    
    
    func displayLoginSheet()  {
        
        //Display the login sheet when click the login button
        let loginProviders = UIAlertController(title: nil, message: "Login with:", preferredStyle: .actionSheet)
        
        //Define Actions
        let cognitoLoginAction = UIAlertAction(title: "Cognito Login", style: .default) {
            (alert: UIAlertAction) -> Void in
            self.COGNITOLogin()
        }
        
        let fbLoginAction = UIAlertAction(title: "Facebook", style: .default) {
            (alert: UIAlertAction) -> Void in
            //self.fbLogin()
        }
        let googleLoginAction = UIAlertAction(title: "Google", style: .default) {
            (alert: UIAlertAction) -> Void in
            //self.googleLogin()
        }
        
        loginProviders.addAction(cognitoLoginAction)
        loginProviders.addAction(fbLoginAction)
        loginProviders.addAction(googleLoginAction)
        
        self.loginViewController?.present(loginProviders, animated: true, completion: nil)
        
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
    
    func errorAlert(_ message: String) {
        let errorAlert = UIAlertController(title: "Error", message: "\(message)", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default) { (alert: UIAlertAction) -> Void in }
        
        errorAlert.addAction(okAction)
        
        self.loginViewController?.present(errorAlert, animated: true, completion: nil)
    }
}
