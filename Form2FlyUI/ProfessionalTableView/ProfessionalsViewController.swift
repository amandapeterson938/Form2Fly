//
//  ProfessionalsViewController.swift
//  Form2FlyUI
//
//  Created by Amanda Peterson on 2/27/21.
//

import UIKit

class ProfessionalsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var professionals: [Professional] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        professionals = createProArray()
        
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    func createProArray() -> [Professional] {
        var tempProfessionals: [Professional] = []
        
        let pro1 = Professional(proName: "Perry", proThrowType: "Fedora")
        let pro2 = Professional(proName: "Ferb", proThrowType: "Silence")
        let pro3 = Professional(proName: "Kyoya", proThrowType: "Glasses")
        
        tempProfessionals.append(pro1)
        tempProfessionals.append(pro2)
        tempProfessionals.append(pro3)
        
        return tempProfessionals
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
}
