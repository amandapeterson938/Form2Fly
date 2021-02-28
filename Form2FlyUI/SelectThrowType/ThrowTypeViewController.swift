//
//  ThrowTypeViewController.swift
//  Form2FlyUI
//
//  Created by Amanda Peterson on 2/27/21.
//

import UIKit

class ThrowTypeViewController: UIViewController {

    @IBOutlet weak var backhandBtn: UIButton!
    @IBOutlet weak var forehandBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backhandBtn.layer.cornerRadius = 12
        forehandBtn.layer.cornerRadius = 12
    }

}
