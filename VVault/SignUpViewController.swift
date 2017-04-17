//
//  SignUpViewController.swift
//  VVault
//
//  Created by Sean Zhang on 4/6/17.
//  Copyright © 2017 Sean Zhang. All rights reserved.
//

import Foundation
import UIKit
import AWSCognitoIdentityProvider


class SignUpViewController: UIViewController {
    
    @IBOutlet weak var userName: UITextField?
    @IBOutlet weak var email: UITextField?
    @IBOutlet weak var password: UITextField?
    @IBOutlet weak var cancel: UIButton?
    
    var pool: AWSCognitoIdentityUserPool?
    var userPool: AWSCognitoIdentityUserPool?
    var sentTo: String?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.pool = AWSCognitoIdentityUserPool.init(forKey: "UserPool")
        self.userPool = AWSCognitoIdentityUserPool(forKey: "UserPool")
        //Do something
        cancel?.addTarget(self, action: #selector(cancelToSignUp), for: .touchUpInside)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let signUpConfirmationViewController = segue.destination as? SignUpConfirmationViewController {
            signUpConfirmationViewController.sentTo = self.sentTo
            signUpConfirmationViewController.user = self.pool?.getUser((self.userName?.text)!)
        }
    }
    
    
    
    @IBAction func onSignUp(_ sender: AnyObject) {
        
        
        guard let userNameValue = self.userName?.text, let passwordValue = self.password?.text else {
            
            print("Not able to get username or password, check if it is empty")
            
            return
        }
        
        
        var attributes = [AWSCognitoIdentityUserAttributeType]()
        
        if let emailValue = self.email?.text, !emailValue.isEmpty {
            let email = AWSCognitoIdentityUserAttributeType()
            email?.name = "email"
            email?.value = emailValue
            attributes.append(email!)
        }
        

        
        //sign up the user
        self.userPool?.signUp(userNameValue, password: passwordValue, userAttributes: attributes, validationData: nil).continueWith {[weak self] (task: AWSTask<AWSCognitoIdentityUserPoolSignUpResponse>) -> AnyObject? in
            guard let strongSelf = self else { return nil }
            DispatchQueue.main.async(execute: {
                if let error = task.error as NSError? {
                    print(error)
                    return
                }
                
                if let result = task.result as AWSCognitoIdentityUserPoolSignUpResponse! {
                    // handle the case where user has to confirm his identity via email / SMS
                    if (result.user.confirmedStatus != AWSCognitoIdentityUserStatus.confirmed) {
                        strongSelf.sentTo = result.codeDeliveryDetails?.destination
                        strongSelf.performSegue(withIdentifier: "SignUpConfirmSegue", sender: sender)
                    } else {
                        print("Registration was sucessful")
                        strongSelf.presentingViewController?.dismiss(animated: true, completion: nil)
                    }
                }
                
            })
            return nil
        }
    }
    
    func cancelToSignUp(){
        self.dismiss(animated: true, completion: nil)
    }
    
}
