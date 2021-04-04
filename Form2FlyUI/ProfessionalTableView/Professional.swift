//
//  Professional.swift
//  Form2FlyUI
//
//  Created by Amanda Peterson on 2/27/21.
//

import Foundation

class Professional {
    var proName: String
    var proThrowType: String
    var proDominantHand: String
    var proData: [String]
    var proWeightedScore: Double
    var videoURL: URL
    
    init(proName: String, proThrowType: String, proDominantHand: String, proData: [String], proWeightedScore: Double, fileURLPath: String) {
        self.proName = proName
        self.proThrowType = proThrowType
        self.proDominantHand = proDominantHand
        self.proData = proData
        self.proWeightedScore = proWeightedScore
        self.videoURL = URL(fileURLWithPath: fileURLPath)
    }
}
