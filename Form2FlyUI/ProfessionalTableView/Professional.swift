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
    var proData: [String]
    var proWeightedScore: String
    var videoURL: URL
    
    
    //let videoURL = URL(fileURLWithPath: "")
    //let video = AVURLAsset(url: videoURL, options: nil)
    
    init(proName: String, proThrowType: String, proData: [String], proWeightedScore: String, fileURLPath: String) {
        self.proName = proName
        self.proThrowType = proThrowType
        self.proData = proData
        self.proWeightedScore = proWeightedScore
        self.videoURL = URL(fileURLWithPath: fileURLPath)
    }
}
