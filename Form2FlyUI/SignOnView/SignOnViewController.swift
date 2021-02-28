//
//  SignOnViewController.swift
//  Form2FlyUI
//
//  Created by Amanda Peterson on 2/27/21.
//

import UIKit

class SignOnViewController: UIViewController {
    
    @IBOutlet weak var signOnBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Round the edges of the buttons
        signOnBtn.layer.cornerRadius = 12
    }

}
