//
//  SettingsViewController.swift
//  Form2FlyUI
//
//  Created by Amanda Peterson on 2/27/21.
//

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
