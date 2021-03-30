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
    
    var currentUser = User(dominantHand: "", pickOrMatch: "", throwType: "", proName: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backhandBtn.layer.cornerRadius = 12
        forehandBtn.layer.cornerRadius = 12
        
        currentUser.pickOrMatch = "match"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if(segue.identifier == "forehandToUploadSegue") {
            currentUser.throwType = "forehand"
        }
        else {
            currentUser.throwType = "backhand"
        }
        
        currentUser.proName = ""
        
        let destinationVC = segue.destination as! RecordOrUploadViewController
        
        destinationVC.currentUser = currentUser
    }

}
