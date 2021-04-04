//
//  User.swift
//  Form2FlyUI
//
//  Created by Amanda Peterson on 3/28/21.
//

import Foundation

class User {
    var dominantHand: String
    var pickOrMatch: String
    var throwType: String
    var proName: String
    
    init(dominantHand: String, pickOrMatch: String, throwType: String, proName: String) {
        self.dominantHand = dominantHand
        self.pickOrMatch = pickOrMatch
        self.throwType = throwType // if user is being matched this will be their throwtype, else the user has picked a profesional this will be the professional's throw type
        self.proName = proName //will be declared if user choses to be matched.
    }
}
