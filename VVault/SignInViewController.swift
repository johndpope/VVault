//
//  SignInViewController.swift
//  VVault
//
//  Created by Sean Zhang on 4/6/17.
//  Copyright © 2017 Sean Zhang. All rights reserved.
//

import Foundation
import UIKit
import AWSCore

class SignInViewController: UIViewController
    
{
    @IBOutlet weak var userName: UITextField?
    @IBOutlet weak var password: UITextField?
    @IBOutlet weak var signInButton: UIButton?
    @IBOutlet weak var signUpButton: UIButton?
    @IBOutlet weak var signOutButton: UIButton?
    @IBOutlet weak var forgetPasswordButton: UIButton?
    
    override func viewDidLoad() {
        
        self.disableUI()
        
        if AmazonClientManager.sharedInstance.isConfigured() {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            
            AmazonClientManager.sharedInstance.resumeSession {
                (task) -> Any? in
                
                DispatchQueue.main.async {
                    self.refreshUI()
                }
                return nil
            }
        } else {
            let missingConfigAlert = UIAlertController(title: "Missing Configuration", message: "Please check Constants.swift and set appropriate values", preferredStyle: .alert)
            missingConfigAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(missingConfigAlert, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func handleSignIn(_ sender: AnyObject)  {
        //Sign in code right in here
        print("handle userPool sign in")
        self.disableUI()
        
        AmazonClientManager.sharedInstance.loginFromView(self, withCompletionHandler:  {
            (task: AWSTask!) -> AnyObject! in
            DispatchQueue.main.async {
                self.refreshUI()
            }
            return nil
        })
        
    }
    
    @IBAction func handleSignOut(_ sender: AnyObject) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        self.disableUI()
        
        AmazonClientManager.sharedInstance.logOut {
            (task) -> AnyObject! in
            DispatchQueue.main.async {
                self.refreshUI()
            }
            return nil
        }
        
    }
    
    func disableUI() {
        self.signInButton?.isEnabled = false
        
        self.signOutButton?.isEnabled = false
        
    }
    
    func refreshUI() {
        print("refreshingUI.......")
   
        let loggedIn = AmazonClientManager.sharedInstance.isLoggedIn()
        print("Is the user has already login ? ----> \(loggedIn)")
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        self.signInButton?.isEnabled = true

        
        if loggedIn {
            self.signInButton?.setTitle("Link", for: UIControlState())
            self.signInButton?.isEnabled = false
        } else {
            self.signInButton?.setTitle("Login", for: UIControlState())
        }
        self.signOutButton?.isEnabled = loggedIn
        
    }
    
    
    @IBAction func handleSignUp()  {
        //Sign up code right in here
        print("handle userPool sign up")
        self.disableUI()
        let storyBoard = UIStoryboard.init(name: "SignUp", bundle: nil)
        let viewController = storyBoard.instantiateViewController(withIdentifier: "SignUp")
        self.present(viewController, animated: true, completion: nil)
    }
    
    @IBAction func handleForgetPassword()  {
        //Forget password code in here
        print("handle userPool forget password")

    }
    

    
}
