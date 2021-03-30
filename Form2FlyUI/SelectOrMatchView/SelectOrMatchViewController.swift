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
    @IBOutlet weak var dominantHandChoice: UISegmentedControl!
    
    var currentUser = User(dominantHand: "", pickOrMatch: "", throwType: "", proName: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Round the edges of the buttons
        matchToProfessionalBtn.layer.cornerRadius = 12
        selectProfessionalBtn.layer.cornerRadius = 12
        
        // set default as right hand
        currentUser.dominantHand = "right"
    }
    
    @IBAction func dominantHandChanged(_ sender: Any) {
        switch dominantHandChoice.selectedSegmentIndex {
        case 0:
            //self.dominantHand = "left"
            currentUser.dominantHand = "left"
        case 1:
            //self.dominantHand = "right"
            currentUser.dominantHand = "right"
        default:
            break
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if(segue.identifier == "pickAProfessionalSegue") {
            let destinationVC = segue.destination as! ProfessionalsViewController
            
            destinationVC.currentUser = currentUser
        }
        else if(segue.identifier == "matchToProfessionalSegue") {
            let destinationVC = segue.destination as! ThrowTypeViewController
            
            destinationVC.currentUser = currentUser
        }
        else {
            return
        }
        
    }
}
