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
    
    var platypus = 0.2
    
    var usersProName = ""
    var usersOverallSim = ""
    var usersProbAreas = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
