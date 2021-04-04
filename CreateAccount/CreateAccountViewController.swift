//
//  CreateAccountViewController.swift
//  Form2FlyUI
//
//  Created by Amanda Peterson on 3/31/21.
//

import UIKit

class CreateAccountViewController: UIViewController {

    @IBOutlet weak var usernameTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    @IBOutlet weak var emailTxt: UITextField!
    
    @IBOutlet weak var createAccountBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.hideKeyboardWhenTappedAround() 
        
        createAccountBtn.layer.cornerRadius = 12
    }
    
    @IBAction func createAccountSubmit(_ sender: Any) {
        let username = usernameTxt.text ?? ""
        let password = passwordTxt.text ?? ""
        let email = emailTxt.text ?? ""
        
    
        //print("Username:", username, "Password:", password, "Email:", email)
        
        if(username == "" || password == "" || email == "") {
            let incompleteAlert = UIAlertController(title: "Incomplete Form", message: "Please fill in all text fields.", preferredStyle: .alert)
            incompleteAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {
                action in
                //code
            }))
            self.present(incompleteAlert, animated: true, completion: nil)
        }
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
