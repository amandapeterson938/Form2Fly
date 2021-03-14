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
    
    var blackSquare = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 0, height: 0))
    var spinner = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
    
    let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask) [0]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Round edges of the buttons
        recordVideoBtn.layer.cornerRadius = 12
        uploadVideoBtn.layer.cornerRadius = 12
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
                
                let fileURL = URL(fileURLWithPath: "poseData", relativeTo: directoryURL).appendingPathExtension("txt")
                
                
                // Analyze the video
                analyzeVideo(video: video, fileURL: fileURL)
                
                
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
            
            let fileURL = URL(fileURLWithPath: "poseData", relativeTo: directoryURL).appendingPathExtension("txt")
            analyzeVideo(video: video, fileURL: fileURL)
            
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
    
    // Clears file with given fileURL then precedes to analyze the video by calling generateTimeForFrames, generates the frame by using generateCGIImagesAsynchronously then calls analyzeFrame to get the pose data and writes to the file.
    func analyzeVideo(video: AVURLAsset, fileURL: URL) {
        
        overwriteFile(dataString: "", fileURL: fileURL)
        
        let frameForTimes = generateTimeForFrames(video: video, numberOfFramesPerSec: 30)
        let numFrames = frameForTimes.count
        
        // Set up pose detector with .stream
        let options = AccuratePoseDetectorOptions()
        options.detectorMode = .stream
        let poseDetector = PoseDetector.poseDetector(options: options)
        
        startLoadingObjects()
        
        // set up semaphore to manage thread
        let semaphore = DispatchSemaphore(value: 1)
    
        
        // generate frames from the frame times generated from generateTimeForFrames function
        // analyze each frame using mlkit pose detector (calls analyzeFrame function) results are saved in file with fileURL
        DispatchQueue.global().async {
            
            semaphore.wait()
            
            let generator = AVAssetImageGenerator(asset: video)
            var curFrameNum = 0
            generator.generateCGImagesAsynchronously(forTimes: frameForTimes, completionHandler:{_, image, _,_,error in
                if let image = image {
                    let visionImg = VisionImage(image: UIImage(cgImage: image))
                    
                    self.analyzeFrame(poseDetector: poseDetector, fileURL: fileURL, frame: visionImg)
                    
                    print(curFrameNum)
                    
                }                
                curFrameNum += 1
                
                if(curFrameNum >= numFrames) {
                    semaphore.signal()
                }
            })
        }
        // should have all data saved to file so we can print the file and open the training activity
        DispatchQueue.main.async {
            semaphore.wait()
            
            self.endLoadingObjects()
            
            print(self.readFile(fileURL: fileURL))
            
            // Opening new view (Training)
            if let newViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TrainingViewController") as? TrainingViewController {
                    newViewController.modalPresentationStyle = .currentContext
                    self.navigationController?.pushViewController(newViewController, animated: true)
            }
            
            semaphore.signal()
        }
    }
    
    func testPrint(number: Float) {
        DispatchQueue.main.async {
            print(number)
        }
        
    }

// analyze visionimage for poses and save angle results to file with fileURL
func analyzeFrame(poseDetector: PoseDetector, fileURL: URL, frame: VisionImage) {
    
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
            
            let outputData = leftHalfData + " " + rightHalfData + "\n"
            self.writeToFile(dataString: outputData, fileURL: fileURL)
            //print(outputData)
        }
    }
    
    // Overwrites file with fileURL with given string
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
    
    // Appends string to file with fileURL
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
    
    // Returns string of data from the given fileURL
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
    
    func endLoadingObjects() {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        blackSquare.removeFromSuperview()
        spinner.stopAnimating()
    }
}
