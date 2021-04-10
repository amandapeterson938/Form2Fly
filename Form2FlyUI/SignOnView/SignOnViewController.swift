//
//  SignOnViewController.swift
//  Form2FlyUI
//
//  Created by Amanda Peterson on 2/27/21.
//
// Gives the user the ability to sign in

import UIKit

class SignOnViewController: UIViewController {
    
    @IBOutlet weak var signOnBtn: UIButton!

    @IBOutlet weak var usernameTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    @IBOutlet weak var logoImageView: UIImageView!
    
    let defaults = UserDefaults.standard
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Round the edges of the buttons
        signOnBtn.layer.cornerRadius = 12
        
        if self.traitCollection.userInterfaceStyle == .dark {
            self.logoImageView.image = UIImage(named: "form2fly_logo_glow (2).png")
        } else {
            self.logoImageView.image = UIImage(named: "image2.png")
        }
        
        self.hideKeyboardWhenTappedAround() 
        
        Backend.shared.signOutLocally()
        
        usernameTxt.delegate = self
        passwordTxt.delegate = self
        
        signOnBtn.isEnabled = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let isSignedIn = defaults.bool(forKey: "isSignedIn")
        
        if(isSignedIn) {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "signToSelectionSegue", sender: self)
            }
            return
        }
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
