//
//  SignUpConfirmationViewController.swift
//  VVault
//
//  Created by Sean Zhang on 4/7/17.
//  Copyright © 2017 Sean Zhang. All rights reserved.
//

import Foundation
import UIKit
import AWSCognitoIdentityProvider

class SignUpConfirmationViewController: UIViewController {
    
    @IBOutlet weak var confirmationCode: UITextField!
    
    var sentTo: String?
    var user: AWSCognitoIdentityUser?
    
    @IBOutlet weak var codeSentTo: UILabel!
    @IBOutlet weak var userName: UITextField!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.userName.text = self.user!.username;
    }
    
    
    @IBAction func onConfirm(_ sender: AnyObject) {
        guard let confirmationCodeValue = self.confirmationCode?.text, !confirmationCodeValue.isEmpty else {
            print("Confirmation code missing. Please enter the confirmation code")
            return
        }
        
        self.user?.confirmSignUp(self.confirmationCode.text!, forceAliasCreation: true).continueWith(block: {[weak self] (task: AWSTask) -> AnyObject? in
            guard let strongSelf = self else { return nil }
            DispatchQueue.main.async(execute: {
                if let error = task.error as NSError? {
                   print("-----------------Error----------------")
                    print(error)
                } else {
                    print("Registration complete and successful")
                    strongSelf.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                }
            })
            return nil
        })
    }
}
