//
//  InsightsViewController.swift
//  Form2FlyUI
//
//  Created by Amanda Peterson on 4/5/21.
//

import UIKit

class InsightsViewController: UIViewController {
    static let shared = InsightsViewController()
    
    
    @IBOutlet weak var usersProfessionalName: UILabel!
    @IBOutlet weak var usersOverallSimilarity: UILabel!
    @IBOutlet weak var usersOverallProb: UILabel!
    
    
    @IBOutlet weak var insightsScrollView: UIScrollView!
    
    var currentUser = User(dominantHand: "", pickOrMatch: "", throwType: "", proName: "", vidURL: "")
    
    var usersProName = ""
    var usersOverallSim = ""
    var usersProbAreas = ""
    
    @IBOutlet weak var viewTrainingButton: UIButton!
    

    @IBAction func trainingAction(_ sender: Any) {
        //code
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "goToTrainingSegue") {
            let destinationVC = segue.destination as! TrainingViewController
            
            destinationVC.currentUser = currentUser
        }
        else {
            return
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewTrainingButton.layer.cornerRadius = 12
        
        usersOverallProb.numberOfLines = 0
        
        usersProfessionalName.text = InsightsViewController.shared.usersProName
        usersOverallSimilarity.text = InsightsViewController.shared.usersOverallSim
        usersOverallProb.text = InsightsViewController.shared.usersProbAreas
        
        
    }
}
