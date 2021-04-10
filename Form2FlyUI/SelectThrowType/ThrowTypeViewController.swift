//
//  ThrowTypeViewController.swift
//  Form2FlyUI
//
//  Created by Amanda Peterson on 2/27/21.
//
// Select Throw Type View Controller, gives user the option to choose to analyze their backhand or forehand throws. This choice will be saved to currentUser.throwType

import UIKit

class ThrowTypeViewController: UIViewController {

    @IBOutlet weak var backhandBtn: UIButton!
    @IBOutlet weak var forehandBtn: UIButton!
    
    var currentUser = User(dominantHand: "", pickOrMatch: "", throwType: "", proName: "", vidURL: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backhandBtn.layer.cornerRadius = 12
        forehandBtn.layer.cornerRadius = 12
        
        currentUser.pickOrMatch = "match"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        currentUser.proName = ""
        
        if(segue.identifier == "forehandToUploadSegue") {
            currentUser.throwType = "Forehand"
            
            let destinationVC = segue.destination as! RecordOrUploadViewController
            
            destinationVC.currentUser = currentUser
        }
        else if (segue.identifier == "backhandToUploadSegue"){
            currentUser.throwType = "Backhand"
            
            let destinationVC = segue.destination as! RecordOrUploadViewController
            
            destinationVC.currentUser = currentUser
        }
        
    }

}
