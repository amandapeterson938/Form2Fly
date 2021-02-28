//
//  SelectOrMatchViewController.swift
//  Form2FlyUI
//
//  Created by Amanda Peterson on 2/27/21.
//

import UIKit

class SelectOrMatchViewController: UIViewController {

    @IBOutlet weak var matchToProfessionalBtn: UIButton!
    @IBOutlet weak var selectProfessionalBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Round the edges of the buttons
        matchToProfessionalBtn.layer.cornerRadius = 12
        selectProfessionalBtn.layer.cornerRadius = 12
    }
}
