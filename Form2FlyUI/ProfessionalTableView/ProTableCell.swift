//
//  ProTableCell.swift
//  Form2FlyUI
//
//  Created by Amanda Peterson on 2/27/21.
//

import UIKit

class ProTableCell: UITableViewCell {
    @IBOutlet weak var proNameLbl: UILabel!
    @IBOutlet weak var proThrowTypeLbl: UILabel!
    
    func setProfesionalName(professional: Professional) {
        proNameLbl.text = professional.proName
        proThrowTypeLbl.text = professional.proThrowType
        
    }

}
