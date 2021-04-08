//
//  RecordOrUploadViewController.swift
//  Form2FlyUI
//
//  Created by Amanda Peterson on 2/28/21.
//

import UIKit
import AVKit
import MLKit
import MobileCoreServices

class RecordOrUploadViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIVideoEditorControllerDelegate {
    
    @IBOutlet weak var recordVideoBtn: UIButton!
    @IBOutlet weak var uploadVideoBtn: UIButton!
    
    var currentUser = User(dominantHand: "", pickOrMatch: "", throwType: "", proName: "", vidURL: "")
    
    // Loading objects
    var blackSquare = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 0, height: 0))
    var spinner = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
    
    // pose dictionary with key being the frame number and the value being the angles that need to change that frame
    // Example: key: 0 val: "|abreviation-angle-time duration..."
    var poseDictionary: [Int: String] = [:]
    
    // array of abrieviations for the angles being analyzed used to fill in keys for dictionaries lastSubPointsDict and pointsDict
    var abrvArr:[String] = ["lwr", "lel", "lsh", "lhi", "lkn", "lan", "lro", "rwr", "rel", "rsh", "rhi", "rkn", "ran", "rro"]
    var abrvDictionary: [String: String] = ["lwr":"Left Wrist", "lel" : "Left Elbow", "lsh" : "Left Shoulder" , "lhi" : "Left Hip", "lkn" : "Left Knee", "lan": "Left Ankle", "lro": "Left Wrist Rotation", "rwr": "Right Wrist", "rel": "Right Elbow", "rsh": "Right Shoulder", "rhi": "Right Hip", "rkn": "Right Knee", "ran": "Right Ankle", "rro": "Right Wrist Rotation"]
    var lastSubPointsDict: [String: String] = [:]
    var pointsDict: [String: String] = [:]
    
    var testArray = [String]()
    
    var userVideoURL = ""
    
    //let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask) [0]
    
    var poseChangesFileURL = URL(fileURLWithPath: "poseChanges")
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //InsightsViewController.init()
        
        // Initialize values in dictionary
        for abrv in abrvArr {
            lastSubPointsDict[abrv] = ""
            pointsDict[abrv] = ""
        }
        
        // Round edges of the buttons
        recordVideoBtn.layer.cornerRadius = 12
        uploadVideoBtn.layer.cornerRadius = 12
        
        print("Record or Upload Information: ")
        print(currentUser.dominantHand)
        print(currentUser.pickOrMatch)
        print(currentUser.proName)
        print(currentUser.throwType)
    }
    
    
    // Runs when user presses record a video button
    @IBAction func recordVideo(_ sender: Any) {
        // runs imagePickerController this opens camera so the user can record their video then calls function to analyze the video for poses then opens training activity
        let recordPicker = UIImagePickerController()
        recordPicker.modalPresentationStyle = .automatic
        recordPicker.videoQuality = .typeHigh
        recordPicker.delegate = self
        recordPicker.sourceType = .camera
        recordPicker.mediaTypes = [kUTTypeMovie as String]
        recordPicker.allowsEditing = false
        
        self.present(recordPicker, animated: true, completion: nil)
        
    }
    
    // Runs when user presses upload a video button
    @IBAction func uploadVideo(_ sender: Any) {
        
        // runs imagePickerController this opens photo library so the user can choose their video then calls function to analyze the video for poses then opens training activity
        let videoPicker = UIImagePickerController()
        videoPicker.modalPresentationStyle = .currentContext
        videoPicker.videoQuality = .typeHigh
        videoPicker.delegate = self
        videoPicker.sourceType = .photoLibrary
        videoPicker.mediaTypes = [kUTTypeMovie as String]
        videoPicker.allowsEditing = true
        
        self.present(videoPicker, animated: true, completion: nil)
        
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //let selVid = info[UIImagePickerController.InfoKey.editedImage]
        self.dismiss(animated: true, completion: nil)
        
        if picker.allowsEditing {
            // Save video
            if let videoURL = (info[UIImagePickerController.InfoKey.mediaURL] as? URL) {
                let video = AVURLAsset(url: videoURL, options: nil)
                
                print(videoURL)
                print(String(Float(video.duration.seconds)))
                
                self.userVideoURL = videoURL.absoluteString
                
                // Analyze the video
                analyzeVideo(video: video, videoURL: videoURL)
          
            }
        }
        else {
            print("!RECORDED VIDEO!")
            let videoEdit = UIVideoEditorController()
            videoEdit.modalPresentationStyle = .currentContext
            videoEdit.delegate = self
            if let videoURL = (info[UIImagePickerController.InfoKey.mediaURL] as? URL) {
                videoEdit.videoPath = videoURL.path
            }
            
            self.present(videoEdit, animated: true, completion: nil)
        }
            
    } // end imagePickerController didFinishPickingMediaWithInfo
    

    
    func videoEditorControllerDidCancel(_ editor: UIVideoEditorController) {
        editor.dismiss(animated: true, completion: nil)
    }
    func videoEditorController(_ editor: UIVideoEditorController, didFailWithError error: Error) {
        print("UIVideoEditorController Error: " + error.localizedDescription)
        editor.dismiss(animated: true, completion: nil)
    }
    
    var isNext = false //didSaveEditedVideoToPath was running twice so added boolean to only go once
    
    func videoEditorController(_ editor: UIVideoEditorController, didSaveEditedVideoToPath editedVideoPath: String) {
        
        editor.dismiss(animated: true, completion: nil)
        
        if(isNext) {
            let videoURL = URL(fileURLWithPath: editedVideoPath)
            let video = AVURLAsset(url: videoURL, options: nil)
            
            print(String(Float(video.duration.seconds)))
            
            analyzeVideo(video: video, videoURL: videoURL)
            
            isNext = false
        }
        else {
            isNext = true
        }
    }
    
    // Generates an array of NSValues that represent timestamps of the frames.
    // Takes in video and the number of frames a second you want to generate
    func generateTimeForFrames(video: AVURLAsset, numberOfFramesPerSec: Float) -> [NSValue] {
        let videoSec = Float(video.duration.seconds)
        
        var frameForTimes = [NSValue]()
        
        // fill frameForTimes with increments of 1/numOfFrames
        var curSec = Float(0.0)
        var cnt = Float(0.0)
        let secInc = Float(1 / numberOfFramesPerSec)
        while((curSec + secInc) < videoSec) {
            
            frameForTimes.append(curSec as NSValue)
            
            curSec = Float(secInc * cnt)
            cnt = cnt + 1
        }
        print("Number of Frames: " + String(frameForTimes.count))
        return frameForTimes
    }
    
    // Analyze the video by calling generateTimeForFrames, generates the frame by using generateCGIImagesAsynchronously then calls analyzeFrame to get the pose data and writes to the dictionary
    func analyzeVideo(video: AVURLAsset, videoURL: URL) {
        
        let frameForTimes = generateTimeForFrames(video: video, numberOfFramesPerSec: 30)
        let numFrames = frameForTimes.count
        
        for num in 0 ... numFrames {
            poseDictionary[num] = ""
        }
        
        // Set up pose detector with .stream
        let options = AccuratePoseDetectorOptions()
        options.detectorMode = .stream
        let poseDetector = PoseDetector.poseDetector(options: options)
        
        startLoadingObjects()
        
        // set up semaphore to manage thread
        let semaphore = DispatchSemaphore(value: 1)
    
        
        // generate frames from the frame times generated from generateTimeForFrames function
        // analyze each frame using mlkit pose detector (calls analyzeFrame function) results are saved in a dictionary
        DispatchQueue.global().async {
            
            semaphore.wait()
            
            let videoDuration = video.duration.seconds
            
            let asset = AVAsset(url: videoURL)
            let generator = AVAssetImageGenerator(asset: asset)
            generator.appliesPreferredTrackTransform = true
            generator.requestedTimeToleranceBefore = CMTime.zero;
            generator.requestedTimeToleranceAfter = CMTime.zero;
            
            
            var time = 0.0
            
            while(time < videoDuration) {
                print("Processing:", time)
                
                let cmTime = CMTimeMakeWithSeconds(time, preferredTimescale: 600)
                if let image = try? generator.copyCGImage(at: cmTime, actualTime: nil) {
                    self.analyzeFrame(poseDetector: poseDetector, frame: VisionImage(image: UIImage(cgImage: image)), currentTime: 0.0)
                }
                
                print("update time")
                time =  time + (1/30)
            }
            
            
            
            semaphore.signal()
        }
        // should have all data saved to file so we can print the file and open the training activity
        DispatchQueue.main.async {
            semaphore.wait()
            
            self.endLoadingObjects()
            
            
            DispatchQueue.global(qos: .default).sync {
                print("*******************************")
                self.analyzeDictionary()
            }
            
            
            // Opening new view (Training)
            if let newViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "InsightsViewController") as? InsightsViewController {
                
                self.currentUser.vidURL = self.userVideoURL
                newViewController.currentUser = self.currentUser
                
                    newViewController.modalPresentationStyle = .currentContext
                    self.navigationController?.pushViewController(newViewController, animated: true)
                
                    self.navigationController?.popViewController(animated: false)
                
            }
            
            semaphore.signal()
        }
    }
    
    
// analyze visionimage for poses and save angle result to dictionary
    func analyzeFrame(poseDetector: PoseDetector, frame: VisionImage, currentTime: Double) {
    
        var results: [Pose]?
        do {
            results = try poseDetector.results(in: frame)
        }
        catch let error {
            print("Failed to detect pose with error: \(error.localizedDescription)")
            return
        }
        guard let detectedPoses = results, !detectedPoses.isEmpty else {
            print("No poses detected...")
            return
        }
        // iterate through poses found in the frame
        for pose in detectedPoses {
//                                let noseLM = (pose.landmark(ofType: .nose)).position
//                                let leftEyeInnerLM = (pose.landmark(ofType: .leftEyeInner)).position
//                                let leftEyeLM = (pose.landmark(ofType: .leftEye)).position
//                                let leftEyeOuterLM = (pose.landmark(ofType: .leftEyeOuter)).position
//                                let rightEyeInnerLM = (pose.landmark(ofType: .rightEyeInner)).position
//                                let rightEyeLM = (pose.landmark(ofType: .rightEye)).position
//                                let rightEyeOuterLM = (pose.landmark(ofType: .rightEyeOuter)).position
//                                let leftEarLM = (pose.landmark(ofType: .leftEar)).position
//                                let rightEarLM = (pose.landmark(ofType: .rightEar)).position
//                                let mouthLeftLM = (pose.landmark(ofType: .mouthLeft)).position
//                                let mouthRightLM = (pose.landmark(ofType: .mouthRight)).position
            let leftShoulderLM = (pose.landmark(ofType: .leftShoulder)).position
            let rightShoulderLM = (pose.landmark(ofType: .rightShoulder)).position
            let leftElbowLM = (pose.landmark(ofType: .leftElbow)).position
            let rightElbowLM = (pose.landmark(ofType: .rightElbow)).position
            let leftWristLM = (pose.landmark(ofType: .leftWrist)).position
            let rightWristLM = (pose.landmark(ofType: .rightWrist)).position
            let leftPinkyFingerLM = (pose.landmark(ofType: .leftPinkyFinger)).position
//                                let rightPinkyFingerLM = (pose.landmark(ofType: .rightPinkyFinger)).position
            let leftIndexFingerLM = (pose.landmark(ofType: .leftIndexFinger)).position
            let rightIndexFingerLM = (pose.landmark(ofType: .rightIndexFinger)).position
            let leftThumbLM = (pose.landmark(ofType: .leftThumb)).position
//                                let rightThumbLM = (pose.landmark(ofType: .rightThumb)).position
            let leftHipLM = (pose.landmark(ofType: .leftHip)).position
            let rightHipLM = (pose.landmark(ofType: .rightHip)).position
            let leftKneeLM = (pose.landmark(ofType: .leftKnee)).position
            let rightKneeLM = (pose.landmark(ofType: .rightKnee)).position
            let leftAnkleLM = (pose.landmark(ofType: .leftAnkle)).position
            let rightAnkleLM = (pose.landmark(ofType: .rightAnkle)).position
//                                let leftHeelLM = (pose.landmark(ofType: .leftHeel)).position
//                                let rightHeelLM = (pose.landmark(ofType: .rightHeel)).position
            let leftToeLM = (pose.landmark(ofType: .leftToe)).position
            let rightToeLM = (pose.landmark(ofType: .rightToe)).position
            

            // Angle Calculations
            let leftWristVertexAngle = self.calculateAngle(vertex: leftWristLM, p2: leftElbowLM, p3: leftIndexFingerLM)
            let leftElbowVertexAngle = self.calculateAngle(vertex: leftElbowLM, p2: leftShoulderLM, p3: leftWristLM)
            let leftShoulderVertexAngle = self.calculateAngle(vertex: leftShoulderLM, p2: leftElbowLM, p3: leftHipLM)
            let leftHipVertexAngle = self.calculateAngle(vertex: leftHipLM, p2: leftShoulderLM, p3: leftKneeLM)
            let leftKneeVertexAngle = self.calculateAngle(vertex: leftKneeLM, p2: leftHipLM, p3: leftAnkleLM)
            let leftAnkleVertexAngle = self.calculateAngle(vertex: leftAnkleLM, p2: leftKneeLM, p3: leftToeLM)
            // Experimental Calculation this semi tells us rotation
            let leftWristRotAngle = self.calculateWristRotation(vertex: leftPinkyFingerLM, p2X: leftPinkyFingerLM.x, p2Y: leftThumbLM.y, p3: leftThumbLM)
            
            let leftHalfData = leftWristVertexAngle + " " + leftElbowVertexAngle + " " + leftShoulderVertexAngle + " " + leftHipVertexAngle + " " + leftKneeVertexAngle + " " + leftAnkleVertexAngle + " " + leftWristRotAngle
            
            let rightWristVertexAngle = self.calculateAngle(vertex: rightWristLM, p2: rightElbowLM, p3: rightIndexFingerLM)
            let rightElbowVertexAngle = self.calculateAngle(vertex: rightElbowLM, p2: rightShoulderLM, p3: rightWristLM)
            let rightShoulderVertexAngle = self.calculateAngle(vertex: rightShoulderLM, p2: rightElbowLM, p3: rightHipLM)
            let rightHipVertexAngle = self.calculateAngle(vertex: rightHipLM, p2: rightShoulderLM, p3: rightKneeLM)
            let rightKneeVertexAngle = self.calculateAngle(vertex: rightKneeLM, p2: rightHipLM, p3: rightAnkleLM)
            let rightAnkleVertexAngle = self.calculateAngle(vertex: rightAnkleLM, p2: rightKneeLM, p3: rightToeLM)
            // Experimental Calculation this semi tells us rotation
            let rightWristRotAngle = self.calculateWristRotation(vertex: leftPinkyFingerLM, p2X: leftPinkyFingerLM.x, p2Y: leftThumbLM.y, p3: leftThumbLM)
            
            let rightHalfData = rightWristVertexAngle + " " + rightElbowVertexAngle + " " + rightShoulderVertexAngle + " " + rightHipVertexAngle + " " + rightKneeVertexAngle + " " + rightAnkleVertexAngle + " " +  rightWristRotAngle
            
            let outputData = leftHalfData + " " + rightHalfData //+ "\n"
            
            testArray.append(outputData)
            
            pointsDict["lwr"]! += leftWristVertexAngle + " "
            pointsDict["lel"]! += leftElbowVertexAngle + " "
            pointsDict["lsh"]! += leftShoulderVertexAngle + " "
            pointsDict["lhi"]! += leftHipVertexAngle + " "
            pointsDict["lkn"]! += leftKneeVertexAngle + " "
            pointsDict["lan"]! += leftAnkleVertexAngle + " "
            pointsDict["lro"]! += leftWristRotAngle + " "
            
            pointsDict["rwr"]! += rightWristVertexAngle + " "
            pointsDict["rel"]! += rightElbowVertexAngle + " "
            pointsDict["rsh"]! += rightShoulderVertexAngle + " "
            pointsDict["rhi"]! += rightHipVertexAngle + " "
            pointsDict["rkn"]! += rightKneeVertexAngle + " "
            pointsDict["ran"]! += rightAnkleVertexAngle + " "
            pointsDict["rro"]! += rightWristRotAngle + " "
            
        }
    }
    
    // Analyzes the pointsDict Dictionary to fill in the dictionary that is named poseDictionary with values of the form
    // |abreviation-angle-duration till next change|abreviation-angle-durration till next change...
    // Some might not have a time value in that case there is not a change for the remaining of the video
    func analyzeDictionary() {
        for (key, val) in pointsDict {
            let val_array = val.components(separatedBy: " ")
            
            var i = 0
            for angle in val_array {
                if (angle.isEmpty) {
                    continue
                }
                
                if (lastSubPointsDict[key] == "") {
                    lastSubPointsDict[key] = angle + " " + String(i)
                    
                    poseDictionary[i]! += "|" + key + "-" + String(angle)
                }
                else {
                    let lastSubPointsDictInfo = lastSubPointsDict[key]!.components(separatedBy: " ")
                    
                    if(lastSubPointsDictInfo.count == 2) {
                        let lastSubAngle = Float(lastSubPointsDictInfo[0]) ?? 0.0
                        let lastFrame = Int(lastSubPointsDictInfo[1]) ?? 0
                        
                        if(fabsf(lastSubAngle - Float(angle)!) >= 3) {
                            let frameDiff = i - lastFrame
                            let timeSince = Double(frameDiff) / 30.0
                            
                            poseDictionary[lastFrame]! += "-" + String(timeSince)
                            
                            poseDictionary[i]! += "|" + key + "-" + String(angle)
                            
                            lastSubPointsDict[key] = angle + " " + String(i)
                        }
                    }
                }
                
                i += 1
            }
        }
        
        //print(lastSubPointsDict)
        print("~~~~~~~~~~~~~~~~~~~~~~~~~~")
        print(poseDictionary.sorted(by: <))
        print("******************************")
        print(testArray)
        print("-------------------------------")
        print(analyzeArray(poseData: testArray))
    }
    
    var weights = [Double]()
    var weighted_scores = [Double]()
    
    func analyzeArray(poseData: [String]) {
        
        weighted_scores = createWeights(angleData: poseData)
        
        print(weighted_scores)
        let weighted_sum = weighted_scores.reduce(0, +)
        print(weighted_sum)
        
        //var professionalsVC: ProfessionalsViewController = ProfessionalsViewController(nibName: nil, bundle: nil)
        //var professionalArray = professionalsVC.proPlayers
        
        professionalPlayers.init()
        let professionalArray = professionalPlayers.shared.returnProfessionals()
        
        var usersProfessional: Professional = Professional(proName: "", proThrowType: "", proDominantHand: "", proData: [], proWeightedScore: 0.0, fileURLPath: "")
        
        if(currentUser.pickOrMatch == "pick") {
            //getProInformation
            for professional in professionalArray {
                if(currentUser.proName == professional.proName) {
                    usersProfessional = professional
                    break
                }
            }
        }
        else{
            var closestProIndex: Int? = nil
            var closestDifference = 0.0
            var i = 0
            for professional in professionalArray {
                
                if(professional.proThrowType == currentUser.throwType) {
                    var difference = fabs(professional.proWeightedScore - weighted_sum)
                    
                    if(i == 0 || difference < closestDifference) {
                        closestProIndex = i
                        closestDifference = difference
                    }
                }
                
                i += 1
            }
            
            if(closestProIndex == nil) {
                print("No professionals with", currentUser.throwType, "throw type")
                return
            }
            else {
                usersProfessional = professionalArray[closestProIndex!]
            }
            
        }
        
        print("Selection: ", currentUser.pickOrMatch)
        print("Professional: ", usersProfessional.proName)
        InsightsViewController.shared.usersProName = usersProfessional.proName
        
        var overallSimilarity = (min(usersProfessional.proWeightedScore, weighted_sum) / max(usersProfessional.proWeightedScore, weighted_sum)) * 100
        print("Overall Similarity: ", overallSimilarity)
        InsightsViewController.shared.usersOverallSim = String(format: "%.2f", overallSimilarity) + " %"
        
        InsightsViewController.shared.usersProbAreas = "Perry the Platypus!!!"
        
        //analyzeMilestones(userData: poseData, proData: usersProfessional.proData)
        splitVideoAnalyze(userData: poseData, proData: usersProfessional.proData)
    }
    
    func createWeights(angleData: [String]) -> [Double] {
        var pro_weighted: [Double] = []
        
        if(currentUser.dominantHand == "right") {
            weights = [0.04, 0.1, 0.07, 0.05, 0.05, 0.02, 0.01, 0.08, 0.2, 0.15, 0.1, 0.1, 0.02, 0.01]
        }
        else {
            weights = [0.08, 0.2, 0.15, 0.1, 0.1, 0.02, 0.01, 0.04, 0.1, 0.07, 0.05, 0.05, 0.02, 0.01]
        }
        
        for frame in angleData {
            let landmarkArray = frame.components(separatedBy: " ")
            
            //print(landmarkArray)
            var temp = [Double]()
            var i = 0
            for landmark in landmarkArray {
                let adjusted = Double(landmark)! * weights[i]
                temp.append(adjusted)
                
                i += 1
            }
            
            pro_weighted.append( temp.reduce(0, +) )
        }
        
        return pro_weighted
    }
    
    func createWeightArray(angleData: [String]) -> [String] {
        var pro_weighted: [String] = []
        
        if(currentUser.dominantHand == "right") {
            weights = [0.04, 0.1, 0.07, 0.05, 0.05, 0.02, 0.01, 0.08, 0.2, 0.15, 0.1, 0.1, 0.02, 0.01]
        }
        else {
            weights = [0.08, 0.2, 0.15, 0.1, 0.1, 0.02, 0.01, 0.04, 0.1, 0.07, 0.05, 0.05, 0.02, 0.01]
        }
        
        for frame in angleData {
            let landmarkArray = frame.components(separatedBy: " ")
            
            //print(landmarkArray)
            var temp = ""
            var i = 0
            for landmark in landmarkArray {
                let adjusted = Double(landmark)! * weights[i]
                temp = temp + String(adjusted) + " "
                
                i += 1
            }
            
            pro_weighted.append(temp)
        }
        
        return pro_weighted
    }
    
    //func analyzeAngles(userData: [String], proData: [String])
    func splitVideoAnalyze(userData: [String], proData: [String]) {
        
        let userWeightedArray = createWeightArray(angleData: userData)
        let proWeightedArray = createWeightArray(angleData: proData)
        
        let userAngleDict = overallAngleDict(angleData: userWeightedArray)
        let proAngleDict = overallAngleDict(angleData: proWeightedArray)
        
        var angleSimilarity: [String: Double] = [:]
        
        for abrv in abrvArr {
            angleSimilarity[abrv] = 0.0
        }
        
        //Push similarity scores in dictionary
        for (key, val) in userAngleDict {
            angleSimilarity[key] = (min(userAngleDict[key]!, proAngleDict[key]!) / max(userAngleDict[key]!, proAngleDict[key]!)) * 100
        }
        
        var worstAngleString = ""
        //Go through dictionary and find the worst
        for (key, val) in angleSimilarity {
            //ignoring rro and lro because they are experimental values that doesn't give enough information to user
            if(key == "rro") {
                print("Oh no!")
            }
            else if(key == "lro") {
                print("Double oh no!")
            }
            else {
                if(val < 76.0) {
                    worstAngleString += abrvDictionary[key]! + ": " + String(format: "%.2f", val) + " %\n"
                    TrainingViewController.share.userProblemAreas += [key]
                    
                }
            }
        }
        
        InsightsViewController.shared.usersProbAreas = worstAngleString
        
        
        
        print(angleSimilarity)
    }
    
    func overallAngleDict(angleData: [String]) -> [String: Double] {
        let abrvArr:[String] = ["lwr", "lel", "lsh", "lhi", "lkn", "lan", "lro", "rwr", "rel", "rsh", "rhi", "rkn", "ran", "rro"]

        
        var angleDictionary : [String: Double] = [:]
        
        for abrv in abrvArr {
            angleDictionary[abrv] = 0.0
        }
        
        
        for frame in angleData {
            let frameArray = frame.split(separator: " ")
            var i = 0
            for angle in frameArray {
                if(!angle.isEmpty) {
                    angleDictionary[abrvArr[i]] = (angleDictionary[abrvArr[i]] ?? 0.0) + (Double(angle) ?? 0.0) ?? 0.0
                    //angleArray[i] = angleArray[i] + Double(angle)!
                    i += 1
                }
            }
        }
        
        return angleDictionary
    }
    
    func analyzeMilestones(userData: [String], proData: [String]) {
        let userLen = userData.count
        let proLen = proData.count
        
        let numberOfSplits = Int(min(userLen, proLen) / 5)
        
        let userWeights = createWeights(angleData: userData)
        let proWeights = createWeights(angleData: proData)
        
        for num in 0...numberOfSplits {
            let percentOfVideo = Double(num) / Double(numberOfSplits)
            
            var currentFramePercentUser = doubleToInteger(data: (Double(userLen) * percentOfVideo))
            var currentFramePercentPro = doubleToInteger(data: (Double(proLen) * percentOfVideo))
            
            if(percentOfVideo == 1.0) {
                currentFramePercentUser -= 1
                currentFramePercentPro -= 1
            }
            
            let proW = proWeights[currentFramePercentPro]
            let userW = userWeights[currentFramePercentUser]
            
            let frame_sim = (min(proW, userW) / max(proW, userW)) * 100
            
            print("Video Percent:", percentOfVideo, "Frame Sim: ", frame_sim)
        }
        
    }
    
    // Calculates angle with the given vertex, point2, and point3 returns string value of angle in degrees
    func calculateAngle(vertex: Vision3DPoint, p2: Vision3DPoint, p3: Vision3DPoint ) -> String {
        let vertexX = vertex.x
        let vertexY = vertex.y
        let p2X = p2.x
        let p2Y = p2.y
        let p3X = p3.x
        let p3Y = p3.y
        
        // p12 = sqrt((p1x - p2x)^2 + (p1y - p2y)^2)
        // arccos(( p12^2 + p13^2 - p23^2) / (2 * p12 * p13))
        let p12 = ((pow((Double(vertexX) - Double(p2X)), 2)) + (pow((Double(vertexY) - Double(p2Y)), 2))).squareRoot()
        let p13 = ((pow((Double(vertexX) - Double(p3X)), 2)) + (pow((Double(vertexY) - Double(p3Y)), 2))).squareRoot()
        let p23 = ((pow((Double(p2X) - Double(p3X)), 2)) + (pow((Double(p2Y) - Double(p3Y)), 2))).squareRoot()
        
        let dividend = Double(pow(p12,2) + pow(p13, 2) - pow(p23,2))
        let divisor = Double(2 * p12 * p13)
        
        let angleRadians = acos(dividend / divisor)
        let angleDegrees = angleRadians * (Double(180) / Double(CGFloat.pi))
        
        return String(angleDegrees)
    }
    
    // Calculates angle with the given vertex, point2 x value and point2 y value, and  point 3
    // This allows you to establish a new point and calculate the angle
    func calculateWristRotation(vertex: Vision3DPoint, p2X: CGFloat, p2Y: CGFloat, p3: Vision3DPoint ) -> String {
        let vertexX = vertex.x
        let vertexY = vertex.y
        let p3X = p3.x
        let p3Y = p3.y
        
        // p12 = sqrt((p1x - p2x)^2 + (p1y - p2y)^2)
        // arccos(( p12^2 + p13^2 - p23^2) / (2 * p12 * p13))
        let p12 = ((pow((Double(vertexX) - Double(p2X)), 2)) + (pow((Double(vertexY) - Double(p2Y)), 2))).squareRoot()
        let p13 = ((pow((Double(vertexX) - Double(p3X)), 2)) + (pow((Double(vertexY) - Double(p3Y)), 2))).squareRoot()
        let p23 = ((pow((Double(p2X) - Double(p3X)), 2)) + (pow((Double(p2Y) - Double(p3Y)), 2))).squareRoot()
        
        let dividend = Double(pow(p12,2) + pow(p13, 2) - pow(p23,2))
        let divisor = Double(2 * p12 * p13)
        
        let angleRadians = acos(dividend / divisor)
        let angleDegrees = angleRadians * (Double(180) / Double(CGFloat.pi))
        
        return String(angleDegrees)
    }
    
    // Once user has finished picking their video / recording this function will be called to show that it is loading
    func startLoadingObjects() {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        let width = self.view.bounds.width;
        let height = self.view.bounds.height;
        blackSquare = UIView(frame: CGRect(x: 0.0, y: 0.0, width: width, height: height))
        blackSquare.backgroundColor = UIColor.systemBackground
        view.addSubview(blackSquare)
        
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.color = UIColor.init(named: "Form2FlyBlue")
        spinner.startAnimating()
        view.addSubview(spinner)
        spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    // This will dismiss the loading objects before the training window opens 
    func endLoadingObjects() {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        blackSquare.removeFromSuperview()
        spinner.stopAnimating()
    }
    
    func doubleToInteger(data:Double)-> Int {
        let doubleToString = "\(data)"
        let stringToInteger = (doubleToString as NSString).integerValue
        
        return stringToInteger
    }
    
}
