//
//  CreateAccountViewController.swift
//  Form2FlyUI
//
//  Created by Amanda Peterson on 3/31/21.
//
// View Controller class so the user is able to create an account
// This is done by calling Backend.swift functions to communicate with Amplify to verify submitted information and add an account for the user. Once the user has filled out the form they will be asked for a confirmation code sent to the users email.

import UIKit

class CreateAccountViewController: UIViewController {

    @IBOutlet weak var usernameTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    @IBOutlet weak var emailTxt: UITextField!
    
    @IBOutlet weak var logoImageView: UIImageView!
    
    @IBOutlet weak var createAccountBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.hideKeyboardWhenTappedAround() 
        
        createAccountBtn.layer.cornerRadius = 12
        
        if self.traitCollection.userInterfaceStyle == .dark {
            self.logoImageView.image = UIImage(named: "form2fly_logo_glow (2).png")
        } else {
            self.logoImageView.image = UIImage(named: "image2.png")
        }
    }
    
    @IBAction func createAccountSubmit(_ sender: Any) {
        let username = usernameTxt.text ?? ""
        let password = passwordTxt.text ?? ""
        let email = emailTxt.text ?? ""
        
        // Check if submitted form is empty, if it is empty it will update the user to complete the form.
        if(username == "" || password == "" || email == "") {
            let incompleteAlert = UIAlertController(title: "Incomplete Form", message: "Please fill in all text fields.", preferredStyle: .alert)
            incompleteAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {
                action in
                //code
            }))
            self.present(incompleteAlert, animated: true, completion: nil)
        }
        // Check if password is less than 7 characters, update user they need to create a longer password
        else if(password.count < 7) {
            let incompleteAlert = UIAlertController(title: "Weak Password", message: "Please make your password greater than 8 characters.", preferredStyle: .alert)
            incompleteAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {
                action in
                //code
            }))
            self.present(incompleteAlert, animated: true, completion: nil)
        }
        else {
            Backend.shared.signUp(username: username, password: password, email: email, viewController: self)
        }
    }
}
