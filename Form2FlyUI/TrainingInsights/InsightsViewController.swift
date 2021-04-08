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
        // Opening new view (Training)
//        if let newViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TrainingViewController") as? TrainingViewController {
//
//            newViewController.currentUser = self.currentUser
//
//                newViewController.modalPresentationStyle = .currentContext
//                self.navigationController?.pushViewController(newViewController, animated: true)
//
//                self.navigationController?.popViewController(animated: false)
//
//        }
        //TrainingViewController.shared.currentUser = self.currentUser
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
        
        print("userIns: ", currentUser.vidURL, "done")
        
        usersOverallProb.numberOfLines = 0

        // Do any additional setup after loading the view.
        
        usersProfessionalName.text = InsightsViewController.shared.usersProName
        usersOverallSimilarity.text = InsightsViewController.shared.usersOverallSim
        usersOverallProb.text = InsightsViewController.shared.usersProbAreas
        
//        let storageOperation = Amplify.Storage.downloadData(key: "myKey")
//        let progressSink = storageOperation.progressPublisher.sink { progress in print("Progress: \(progress)") }
//        let resultSink = storageOperation.resultPublisher.sink {
//            if case let .failure(storageError) = $0 {
//                print("Failed: \(storageError.errorDescription). \(storageError.recoverySuggestion)")
//            }
//        }
//        receiveValue: { data in
//            print("Completed: \(data)")
//        }
        
    }
}
