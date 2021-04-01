//
//  SignOnViewController.swift
//  Form2FlyUI
//
//  Created by Amanda Peterson on 2/27/21.
//

import UIKit

class SignOnViewController: UIViewController {
    
    @IBOutlet weak var signOnBtn: UIButton!

    @IBOutlet weak var usernameTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Round the edges of the buttons
        signOnBtn.layer.cornerRadius = 12
        
        self.hideKeyboardWhenTappedAround() 
        
        Backend.shared.signOutLocally()
        
        usernameTxt.delegate = self
        passwordTxt.delegate = self
        
        signOnBtn.isEnabled = false
    }
    
    var signInResult = false
    
    @IBAction func submitSignOn(_ sender: Any) {
        let username = usernameTxt.text ?? ""
        let password = passwordTxt.text ?? ""
        
        Backend.shared.signIn(username: username, password: password, viewController: self)
        print("SignOnViewController: ", signInResult)
    }
}


extension SignOnViewController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let text = textField.text ?? ""
        
        if (text == ""){
            signOnBtn.isUserInteractionEnabled = false
            signOnBtn.isEnabled = false
        }
        else {
            signOnBtn.isUserInteractionEnabled = true
            signOnBtn.isEnabled = true
        }
    }
}

// Put this piece of code anywhere you like
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
