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
    @IBOutlet weak var forgetPasswordButton: UIButton?
    
    override func viewDidLoad() {
        //Do something
        //ustomProviderButton.addTarget(self, action: #selector(self.handleCustomSignIn), for: .touchUpInside)
        
        signInButton?.addTarget(self, action: #selector(self.handleSignIn), for: .touchUpInside)
        signUpButton?.addTarget(self, action: #selector(self.handleSignUp), for: .touchUpInside)
        forgetPasswordButton?.addTarget(self, action: #selector(self.handleForgetPassword), for: .touchUpInside)
    }
    
    func handleSignIn()  {
        //Sign in code right in here
        print("handle userPool sign in")
        
        AWSClientManager.sharedInstance.loginFromView(self, withCompletionHandler:  {
            (task: AWSTask!) -> AnyObject! in
            DispatchQueue.main.async {
                self.refreshUI()
            }
            return nil
        })
        
    }
    
    func refreshUI() {
        print("refreshingUI.......")
    }
    
    func handleSignUp()  {
        //Sign up code right in here
        print("handle userPool sign up")
        let storyBoard = UIStoryboard.init(name: "SignUp", bundle: nil)
        let viewController = storyBoard.instantiateViewController(withIdentifier: "SignUp")
        self.present(viewController, animated: true, completion: nil)
    }
    
    func handleForgetPassword()  {
        //Forget password code in here
        print("handle userPool forget password")

        
    }
    
}
