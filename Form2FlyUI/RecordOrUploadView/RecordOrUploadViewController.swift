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

class RecordOrUploadViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIVideoEditorControllerDelegate{

    @IBOutlet weak var recordVideoBtn: UIButton!
    @IBOutlet weak var uploadVideoBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Round edges of the buttons
        recordVideoBtn.layer.cornerRadius = 12
        uploadVideoBtn.layer.cornerRadius = 12
    }
    
    @IBAction func recordVideo(_ sender: Any) {
        let recordPicker = UIImagePickerController()
        recordPicker.modalPresentationStyle = .currentContext
        recordPicker.videoQuality = .typeHigh
        recordPicker.delegate = self
        recordPicker.sourceType = .camera
        recordPicker.mediaTypes = [kUTTypeMovie as String]
        recordPicker.allowsEditing = false
        
        self.present(recordPicker, animated: true, completion: nil)
        
    }
    
    @IBAction func uploadVideo(_ sender: Any) {
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
                
                analyzeVideo(video: video)
                
                // Opening new view (Training)
                if let newViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TrainingViewController") as? TrainingViewController {
                        newViewController.modalPresentationStyle = .currentContext
                        self.navigationController?.pushViewController(newViewController, animated: true)
                }
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
            
            analyzeVideo(video: video)
            
            // Opening new view (Training)
            if let newViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TrainingViewController") as? TrainingViewController {
                    newViewController.modalPresentationStyle = .currentContext
                    self.navigationController?.pushViewController(newViewController, animated: true)
            }
            isNext = false
        }
        else {
            isNext = true
        }
    }
    
    func generateTimeForFrames(video: AVURLAsset) -> [NSValue] {
        let videoSec = Float(video.duration.seconds)
        
        var frameForTimes = [NSValue]()
        
        // fill frameForTimes with increments of 1/numOfFrames
        var curSec = Float(0.0)
        var cnt = Float(0.0)
        let numOfFrames = Float(30)
        let secInc = Float(1 / numOfFrames)
        while((curSec + secInc) < videoSec) {
            frameForTimes.append(curSec as NSValue)
            curSec = Float(secInc * cnt)
            cnt = cnt + 1
        }
        print("COUNT: " + String(frameForTimes.count))
        
        return frameForTimes
    }
    
    func analyzeVideo(video: AVURLAsset) {
        
        let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask) [0]
        let fileURL = URL(fileURLWithPath: "poseData", relativeTo: directoryURL).appendingPathExtension("txt")
        overwriteFile(dataString: "", fileURL: fileURL)
        
        let frameForTimes = generateTimeForFrames(video: video)
        let numFrames = frameForTimes.count
        var outputFrames = [VisionImage]()
        
        // Set up pose detector with .stream
        let options = AccuratePoseDetectorOptions()
        options.detectorMode = .stream
        let poseDetector = PoseDetector.poseDetector(options: options)
        
        let semaphore = DispatchSemaphore(value: 1)
        DispatchQueue.global().async {
            semaphore.wait()
            
            let generator = AVAssetImageGenerator(asset: video)
            var curFrameNum = 0
            generator.generateCGImagesAsynchronously(forTimes: frameForTimes, completionHandler:{_, image, _,_,error in
                if let image = image {
                    outputFrames.append(VisionImage(image: UIImage(cgImage: image)))
                }
                
                curFrameNum += 1
                if(curFrameNum >= numFrames) {
                    print("Finished Frames")
                    semaphore.signal()
                }
            })
        }
        DispatchQueue.global().async {
            semaphore.wait()
            
            for frame in outputFrames {
                var results: [Pose]?
                do {
                    results = try poseDetector.results(in: frame)
                }
                catch let error {
                    print("Failed to detect pose with error: \(error.localizedDescription)")
                    return
                }
                guard let detectedPoses = results, !detectedPoses.isEmpty else {
                    return
                }
                
                
                
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
                    

                    let leftWristVertexAngle = self.calculateAngle(vertex: leftWristLM, p2: leftElbowLM, p3: leftIndexFingerLM)
                    let leftElbowVertexAngle = self.calculateAngle(vertex: leftElbowLM, p2: leftShoulderLM, p3: leftWristLM)
                    let leftShoulderVertexAngle = self.calculateAngle(vertex: leftShoulderLM, p2: leftElbowLM, p3: leftHipLM)
                    let leftHipVertexAngle = self.calculateAngle(vertex: leftHipLM, p2: leftShoulderLM, p3: leftKneeLM)
                    let leftKneeVertexAngle = self.calculateAngle(vertex: leftKneeLM, p2: leftHipLM, p3: leftAnkleLM)
                    let leftAnkleVertexAngle = self.calculateAngle(vertex: leftAnkleLM, p2: leftKneeLM, p3: leftToeLM)
                    // Experimental Calculation this semi tells us rotation
                    let leftWristRotAngle = self.calculateWristRotation(vertex: leftPinkyFingerLM, p2X: leftPinkyFingerLM.x, p2Y: leftThumbLM.x, p3: leftThumbLM)
                    
                    let leftHalfData = leftWristVertexAngle + " " + leftElbowVertexAngle + " " + leftShoulderVertexAngle + " " + leftHipVertexAngle + " " + leftKneeVertexAngle + " " + leftAnkleVertexAngle + " " + leftWristRotAngle
                    
                    
                    let rightWristVertexAngle = self.calculateAngle(vertex: rightWristLM, p2: rightElbowLM, p3: rightIndexFingerLM)
                    let rightElbowVertexAngle = self.calculateAngle(vertex: rightElbowLM, p2: rightShoulderLM, p3: rightWristLM)
                    let rightShoulderVertexAngle = self.calculateAngle(vertex: rightShoulderLM, p2: rightElbowLM, p3: rightHipLM)
                    let rightHipVertexAngle = self.calculateAngle(vertex: rightHipLM, p2: rightShoulderLM, p3: rightKneeLM)
                    let rightKneeVertexAngle = self.calculateAngle(vertex: rightKneeLM, p2: rightHipLM, p3: rightAnkleLM)
                    let rightAnkleVertexAngle = self.calculateAngle(vertex: rightAnkleLM, p2: rightKneeLM, p3: rightToeLM)
                    let rightWristRotAngle = self.calculateWristRotation(vertex: leftPinkyFingerLM, p2X: leftPinkyFingerLM.x, p2Y: leftThumbLM.x, p3: leftThumbLM)
                    
                    
                    let rightHalfData = rightWristVertexAngle + " " + rightElbowVertexAngle + " " + rightShoulderVertexAngle + " " + rightHipVertexAngle + " " + rightKneeVertexAngle + " " + rightAnkleVertexAngle + " " +  rightWristRotAngle
                    
                    let outputData = leftHalfData + " " + rightHalfData + "\n"
                    self.writeToFile(dataString: outputData, fileURL: fileURL)
                    //print(outputData)
                } // end for pose in detectedPoses
                
                
                
            }
            
            print("Background...")
            semaphore.signal()
        }
        DispatchQueue.global().async {
            semaphore.wait()
            print(self.readFile(fileURL: fileURL))
            print("FINISHED NOW")
            semaphore.signal()
        }
    }
    
    func overwriteFile(dataString : String, fileURL: URL ) {
        guard let data = dataString.data(using: .utf8) else {
            print("Unable to convert string to data.")
            return
        }
        do {
            try data.write(to: fileURL)
            print("File saved: \(fileURL.absoluteURL)")
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    func writeToFile(dataString : String, fileURL: URL ) {
        let newString = readFile(fileURL: fileURL) + dataString
        
        guard let data = newString.data(using: .utf8) else {
            print("Unable to convert string to data.")
            return
        }
        do {
            try data.write(to: fileURL)
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    func readFile(fileURL : URL) -> String {
        do {
            let savedData =  try Data(contentsOf: fileURL)
            if let savedString = String(data: savedData, encoding: .utf8) {
                return savedString
            }
        }
        catch {
            print("Unable to read file.")
        }
        return ""
    }
    
    
    func calculateAngle(vertex: Vision3DPoint, p2: Vision3DPoint, p3: Vision3DPoint ) -> String {
        let vertexX = vertex.x
        let vertexY = vertex.y
        let p2X = p2.x
        let p2Y = p2.y
        let p3X = p3.x
        let p3Y = p3.y
        
        let p12 = ((pow((Double(vertexX) - Double(p2X)), 2)) + (pow((Double(vertexY) - Double(p2Y)), 2))).squareRoot()
        let p13 = ((pow((Double(vertexX) - Double(p3X)), 2)) + (pow((Double(vertexY) - Double(p3Y)), 2))).squareRoot()
        let p23 = ((pow((Double(p2X) - Double(p3X)), 2)) + (pow((Double(p2Y) - Double(p3Y)), 2))).squareRoot()
        
        let dividend = Double(pow(p12,2) + pow(p13, 2) - pow(p23,2))
        let divisor = Double(2 * p12 * p13)
        
        let angleRadians = acos(dividend / divisor)
        let angleDegrees = angleRadians * (Double(180) / Double(CGFloat.pi))
        
        return String(angleDegrees)
    }
    
    func calculateWristRotation(vertex: Vision3DPoint, p2X: CGFloat, p2Y: CGFloat, p3: Vision3DPoint ) -> String {
        let vertexX = vertex.x
        let vertexY = vertex.y
        let p3X = p3.x
        let p3Y = p3.y
        
        let p12 = ((pow((Double(vertexX) - Double(p2X)), 2)) + (pow((Double(vertexY) - Double(p2Y)), 2))).squareRoot()
        let p13 = ((pow((Double(vertexX) - Double(p3X)), 2)) + (pow((Double(vertexY) - Double(p3Y)), 2))).squareRoot()
        let p23 = ((pow((Double(p2X) - Double(p3X)), 2)) + (pow((Double(p2Y) - Double(p3Y)), 2))).squareRoot()
        
        let dividend = Double(pow(p12,2) + pow(p13, 2) - pow(p23,2))
        let divisor = Double(2 * p12 * p13)
        
        let angleRadians = acos(dividend / divisor)
        let angleDegrees = angleRadians * (Double(180) / Double(CGFloat.pi))
        
        return String(angleDegrees)
    }
 
}
