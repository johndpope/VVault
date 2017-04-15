//
//  MFAViewController.swift
//  VVault
//
//  Created by Sean Zhang on 4/6/17.
//  Copyright © 2017 Sean Zhang. All rights reserved.
//

import Foundation
import UIKit

class MFAViewController: UIViewController {
    
    
    @IBOutlet weak var confirmationCode: UITextField?
    @IBOutlet weak var submitButton: UIButton?
    @IBOutlet weak var cancelButton: UIButton?
    @IBOutlet weak var resendConfirmCode: UIButton?
    
    
    override func viewDidLoad() {
        //Something happens here
        
        submitButton?.addTarget(self, action: #selector(handleSubmitButton), for: .touchUpInside)
        cancelButton?.addTarget(self, action: #selector(handleCancelButton), for: .touchUpInside)
        resendConfirmCode?.addTarget(self, action: #selector(handleResendButton), for: .touchUpInside)
    }
    
    func handleSubmitButton() -> Void {
        //something
    }
    
    func handleCancelButton() -> Void {
        //something
        self.dismiss(animated: true, completion: nil)
    }
    
    func handleResendButton(){
        //something
    }
}
