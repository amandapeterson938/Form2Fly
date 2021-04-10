//
//  SelectOrMatchViewController.swift
//  Form2FlyUI
//
//  Created by Amanda Peterson on 2/27/21.
//
// Gives user an option to select the professional they want or be matched to one. This will be logged in currentUser.pickOrMatch

import UIKit

class SelectOrMatchViewController: UIViewController {

    @IBOutlet weak var matchToProfessionalBtn: UIButton!
    @IBOutlet weak var selectProfessionalBtn: UIButton!
    @IBOutlet weak var dominantHandChoice: UISegmentedControl!
    @IBOutlet weak var logoImageView: UIImageView!
    
    
    
    var currentUser = User(dominantHand: "", pickOrMatch: "", throwType: "", proName: "", vidURL: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Round the edges of the buttons
        matchToProfessionalBtn.layer.cornerRadius = 12
        selectProfessionalBtn.layer.cornerRadius = 12
        
        if self.traitCollection.userInterfaceStyle == .dark {
            self.logoImageView.image = UIImage(named: "form2fly_logo_glow (2).png")
        } else {
            self.logoImageView.image = UIImage(named: "image2.png")
        }
        
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
