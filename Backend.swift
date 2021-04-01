//
//  Backend.swift
//  Form2FlyUI
//
//  Created by Amanda Peterson on 3/29/21.
//

import UIKit
import Amplify
import AmplifyPlugins

class Backend {
    static let shared = Backend()
    static func initialize() -> Backend {
        return .shared
    }
    private init() {
      // initialize amplify
      do {
        try Amplify.add(plugin: AWSCognitoAuthPlugin())
        try Amplify.configure()
        print("Initialized Amplify");
      } catch {
        print("Could not initialize Amplify: \(error)")
      }
    }
    
    // AWS Documentation for user registration 
    //https://docs.amplify.aws/lib/auth/signin/q/platform/ios#register-a-user
    
    var isComplete = false
    func signUp(username: String, password: String, email: String, viewController: UIViewController) {
        let userAttributes = [AuthUserAttribute(.email, value: email)]
        let options = AuthSignUpRequest.Options(userAttributes: userAttributes)
        Amplify.Auth.signUp(username: username, password: password, options: options) { result in
            switch result {
            case .success(let signUpResult):
                if case let .confirmUser(deliveryDetails, _) = signUpResult.nextStep {
                    print("Delivery details \(String(describing: deliveryDetails))")
                    
                    DispatchQueue.main.async {
                        
                        let getAuthCodeAlert = UIAlertController(title: "Authentication", message: "Please input your authentication code sent to your email.", preferredStyle: .alert)

                        getAuthCodeAlert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: {
                            action in
                            let textField = getAuthCodeAlert.textFields![0] as UITextField
                            textField.keyboardType = .numberPad
                            
                            print("Textfield: ", textField.text)
                            
                            Backend.shared.confirmSignUp(for: username, with: textField.text ?? "", viewController: viewController)
                        }))
                        
                        getAuthCodeAlert.addTextField { (textField: UITextField!) in
                            textField.keyboardType = .decimalPad
                        }
                        
                        viewController.present(getAuthCodeAlert, animated: true)
                    }
                    
                }
                else {
                    print("SignUp Complete")
                    self.isComplete = true
                }
            case .failure(let error):
                print("An error occurred while registering a user \(error)")
                
                if(error.errorDescription == "User already exists") {
                    
                    DispatchQueue.main.async {
                        let inValidSignOnAlert = UIAlertController(title: "Username Already Taken", message: "Please create a unique username.", preferredStyle: .alert)
                        
                        inValidSignOnAlert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: {
                            action in
                                 // Called when user taps outside
                        }))
                        
                        viewController.present(inValidSignOnAlert, animated: true)
                    }
                }
            }
        }
        //return self.isComplete
    }
    
    func confirmSignUp(for username: String, with confirmationCode: String, viewController: UIViewController) {
        Amplify.Auth.confirmSignUp(for: username, confirmationCode: confirmationCode) { result in
            switch result {
            case .success:
                print("Confirm signUp succeeded")
                DispatchQueue.main.async {
                    viewController.performSegue(withIdentifier: "goToSelectionSegue", sender: self)
                }
            case .failure(let error):
                print("An error occurred while confirming sign up \(error)")
                
                DispatchQueue.main.async {
                    let getAuthCodeAlert = UIAlertController(title: "Invalid Code", message: "Please input valid authentication code.", preferredStyle: .alert)

                    getAuthCodeAlert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: {
                        action in
                        let textField = getAuthCodeAlert.textFields![0] as UITextField
                        textField.keyboardType = .numberPad
                        
                        print("Textfield: ", textField.text)
                        
                        Backend.shared.confirmSignUp(for: username, with: textField.text ?? "", viewController: viewController)
                    }))
                    
                    getAuthCodeAlert.addTextField { (textField: UITextField!) in
                        textField.keyboardType = .decimalPad
                    }
                    
                    viewController.present(getAuthCodeAlert, animated: true)
                }
            }
        }
    }
    
    public func signIn(username: String, password: String, viewController: UIViewController) {
        _ = Amplify.Auth.signIn(username: username, password: password) { result in
            switch result {
            case .success(_):
                print("Sign in succeeded")
                
                DispatchQueue.main.async {
                    viewController.performSegue(withIdentifier: "signToSelectionSegue", sender: self)
                }
                
            // nothing else required, the event HUB will trigger the UI refresh
            case .failure(let error):
                print("Sign in failed \(error)")
                
                DispatchQueue.main.async {
                    let inValidSignOnAlert = UIAlertController(title: "Invalid User", message: "Incorrect username or password.", preferredStyle: .alert)
                    
                    inValidSignOnAlert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: {
                        action in
                             // Called when user taps outside
                    }))
                    
                    viewController.present(inValidSignOnAlert, animated: true)
                }
            }
        }
    }
    
    func signOutLocally() {
        Amplify.Auth.signOut() { result in
            switch result {
            case .success:
                print("Successfully signed out")
            case .failure(let error):
                print("Sign out failed with error \(error)")
            }
        }
    }
}
