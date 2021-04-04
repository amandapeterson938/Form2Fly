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
    
    let defaults = UserDefaults.standard
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Round the edges of the buttons
        signOnBtn.layer.cornerRadius = 12
        
//        let isSignedIn = defaults.bool(forKey: "isSignedIn")
//        print(isSignedIn)
//
//
//        if(isSignedIn) {
////            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
////            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "nextView") as! NextViewController
////            self.present(nextViewController, animated:true, completion:nil)
//
//
//            print("Going to my spot")
//            // performSegue(withIdentifier: "signToSelectionSegue", sender: self)
//            //self.present(SelectOrMatchViewController(), animated: true, completion: nil)
//
//            //getTopMostViewController()?.present(SelectOrMatchViewController(), animated: true, completion: nil)
//            DispatchQueue.main.async {
//                self.performSegue(withIdentifier: "signToSelectionSegue", sender: self)
//            }
//
//            return
//        }
        
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
