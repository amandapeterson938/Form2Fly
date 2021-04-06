//
//  ProfessionalsViewController.swift
//  Form2FlyUI
//
//  Created by Amanda Peterson on 2/27/21.
//

import UIKit

class ProfessionalsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var currentUser = User(dominantHand: "", pickOrMatch: "", throwType: "", proName: "", vidURL: "")
    
    var professionals: [Professional] = []
    
    //professionalPlayers.init()
    //let professionalArray = professionalPlayers.shared.returnProfessionals()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentUser.pickOrMatch = "pick"
        
        professionalPlayers.init()
        self.professionals = professionalPlayers.shared.returnProfessionals()
        print("PROFESSIONALS.COUNT", professionals.count)
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func createProArray() -> [Professional] {
        var tempProfessionals: [Professional] = []
        
        // only for table view so it does not have full information full information is in professionalPlayers.swift
        let pro1 = Professional(proName: "P. McBeth", proThrowType: "backhand", proDominantHand: "right", proData: [], proWeightedScore: 9588.502678121475, fileURLPath: "")
        let pro2 = Professional(proName: "S. Withers", proThrowType: "backhand", proDominantHand: "right", proData: [], proWeightedScore: 8514.528468886949, fileURLPath: "")
        let pro3 = Professional(proName: "A. Hammers", proThrowType: "backhand", proDominantHand: "right", proData: [], proWeightedScore: 0.0, fileURLPath: "")
        
        tempProfessionals.append(pro1)
        tempProfessionals.append(pro2)
        tempProfessionals.append(pro3)
        
        return tempProfessionals
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if(segue.identifier == "professionalPickedToUpload") {
            let destinationVC = segue.destination as! RecordOrUploadViewController
            
            destinationVC.currentUser = currentUser
        }
        else {
            return
        }
    }
}



extension ProfessionalsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return professionals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let name = professionals[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProTableCell") as! ProTableCell
        
        cell.setProfesionalName(professional: name)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selected: ", indexPath.row)
        currentUser.proName = professionals[indexPath.row].proName
        currentUser.throwType = professionals[indexPath.row].proThrowType
        print("ProName: ", professionals[indexPath.row].proName)
    }
}
