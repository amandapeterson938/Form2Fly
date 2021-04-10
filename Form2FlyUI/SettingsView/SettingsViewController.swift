//
//  SettingsViewController.swift
//  Form2FlyUI
//
//  Created by Amanda Peterson on 2/27/21.
//
// Settings View Controller, if the user clicks sign out it will set the user defaults key "isSignedIn" to false. 

import UIKit

class SettingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func signOut(_ sender: Any) {
        let userDefault = UserDefaults.standard
        userDefault.set(false, forKey: "isSignedIn")
        userDefault.synchronize()
    }
}
