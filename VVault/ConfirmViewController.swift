//
//  ConfirmViewController.swift
//  VVault
//
//  Created by Sean Zhang on 5/3/17.
//  Copyright © 2017 Sean Zhang. All rights reserved.
//

import UIKit
import Foundation
import AWSCognitoIdentityProvider

class ConfirmViewController: UIViewController {

    lazy var confirmCodeTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = UIColor.white
        textField.layer.cornerRadius = 5
        textField.layer.masksToBounds = true
        textField.placeholder = "  Confirmation Code"
        textField.autocapitalizationType = .none
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    lazy var confirmCodeButton: UIButton = {
        let button = UIButton(type: UIButtonType.system)
        button.setTitle("Confirm", for: UIControlState.normal)
        button.backgroundColor = UIColor(r: 80, g: 101, b: 161)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        
        button.addTarget(self, action: #selector(onConfirm), for: .touchUpInside)
        
        return button
    }()
    
    lazy var cancelCodeButton: UIButton = {
        let button = UIButton(type: UIButtonType.system)
        button.setTitle("Cancel", for: UIControlState.normal)
        button.backgroundColor = UIColor(r: 80, g: 101, b: 161)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        
        button.addTarget(self, action: #selector(onCancel), for: .touchUpInside)
        
        return button
    }()
    
    var sentTo: String?
    var user: AWSCognitoIdentityUser?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let text = self.user?.username;
        print(text ?? "There is no user so no user name")
        
        view.backgroundColor = UIColor(r: 61, g: 91, b: 151)
        
        view.addSubview(confirmCodeTextField)
        view.addSubview(confirmCodeButton)
        view.addSubview(cancelCodeButton)
        
        setupInputContainerView()
    }
    
    
    func setupInputContainerView(){
        
        //need x, y, width, height constraints
        confirmCodeTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        confirmCodeTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        confirmCodeTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        confirmCodeTextField.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -25).isActive = true
        
        //need x, y, width, height constraints
        confirmCodeButton.leftAnchor.constraint(equalTo: confirmCodeTextField.leftAnchor).isActive = true
        confirmCodeButton.topAnchor.constraint(equalTo: confirmCodeTextField.bottomAnchor, constant: 10).isActive = true
        confirmCodeButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        confirmCodeButton.widthAnchor.constraint(equalTo: confirmCodeTextField.widthAnchor, multiplier: 1/2, constant:-5).isActive = true
        
        //need x, y, width, height constraints
        cancelCodeButton.leftAnchor.constraint(equalTo: confirmCodeButton.rightAnchor, constant: 10).isActive = true
        cancelCodeButton.topAnchor.constraint(equalTo: confirmCodeTextField.bottomAnchor, constant: 10).isActive = true
        cancelCodeButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        cancelCodeButton.widthAnchor.constraint(equalTo: confirmCodeTextField.widthAnchor, multiplier: 1/2, constant: -5).isActive = true
    }
    
    

    func onConfirm() {
        print("onConfirm")
        guard let confirmationCodeValue = self.confirmCodeTextField.text, !confirmationCodeValue.isEmpty else {
            print("Confirmation code missing. Please enter the confirmation code")
            return
        }
        print("ConfirmCodeValue = \(confirmationCodeValue)")
        
        self.user?.confirmSignUp(confirmationCodeValue, forceAliasCreation: true).continueWith(block: {[weak self] (task: AWSTask) -> AnyObject? in
            guard let strongSelf = self else { return nil }
            print("Inside theconfirmSignup")
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
    
    func onCancel(){
        self.dismiss(animated: true, completion: nil)
    }
}
