//
//  TrainingViewController.swift
//  Form2FlyUI
//
//  Created by Amanda Peterson on 2/28/21.
//
// Displays Training View which highlights the users video with red nodes on the users problem areas. Offers the user an option of seeing the professional's video as well.

import UIKit
import AVKit
import MLKit
import MobileCoreServices


class TrainingViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    static let share = TrainingViewController()

    @IBOutlet weak var trainingImageView: UIImageView!
    
    @IBAction func goToHome(_ sender: Any) {
        editedImageArray = []
    }
    
    @IBOutlet weak var vidSelElm: UISegmentedControl!
    @IBAction func videoSelectionSegment(_ sender: Any) {
        editedImageArray = []
        originalFrames = []
        timerCount = 0
        
        if vidSelElm.titleForSegment(at: vidSelElm.selectedSegmentIndex) == "User" {
            guard var url = URL(string: currentUser.vidURL) else { return }
            analyzeVideoURL(videoURL: url)
        }
        else {
            var professionalsFileName = InsightsViewController.shared.usersProName
            print(InsightsViewController.shared.usersProName +  "|" + professionalsFileName + "|")
            
            if let audioFileURL = Bundle.main.url(forResource: professionalsFileName, withExtension: "mp4") {
                analyzeVideoURL(videoURL: audioFileURL)
            }
            else if let audioFileURL = Bundle.main.url(forResource: professionalsFileName, withExtension: "MOV") {
                analyzeVideoURL(videoURL: audioFileURL)
            }
        }
        
    }
    
    let abrvArr:[String] = ["lwr", "lel", "lsh", "lhi", "lkn", "lan", "lro", "rwr", "rel", "rsh", "rhi", "rkn", "ran", "rro"]
    
    var currentUser = User(dominantHand: "", pickOrMatch: "", throwType: "", proName: "", vidURL: "")
    
    var userProblemAreas = [String]()
    
    var problemJoints = [String]()
    
    var editedImageArray = [UIImage?]()

    var timer = Timer()
    
    // Loading objects
    var loadingScreen = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 0, height: 0))
    var spinner = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
     
   
    override func viewDidLoad() {
        super.viewDidLoad()
        guard var url = URL(string: currentUser.vidURL) else { return }
        analyzeVideoURL(videoURL: url)
        
        problemJoints.append(contentsOf: TrainingViewController.share.userProblemAreas)
    }
    
    @IBAction func replayVideo(_ sender: Any) {
        timerCount = 0
        var test = 0.0
        test = 1/30
        
        self.timer = Timer.scheduledTimer(timeInterval: test, target: self, selector: #selector(self.timerAction), userInfo: nil, repeats: true)
    }
    
    var originalFrames = [CGImage]()
    
    func analyzeVideoURL(videoURL : URL) {
        self.startLoadingObjects()
        
        let semaphore = DispatchSemaphore(value: 1)
        
        DispatchQueue.main.async {
            semaphore.wait()
            print("Generating Frames")
            
            
            let video = AVURLAsset(url: videoURL, options: nil)
            
            let videoDuration = video.duration.seconds
            var time = 0.0
            while(time < videoDuration) {
                print("Processing: ", time)
                
                let img = self.generateFrame(videoURL: videoURL, frameTime: time)
                
                if (img != nil) {
                    self.originalFrames.append(img!)
                }
                
                time = time + (1/30)
            }
            
            semaphore.signal()
        }
        DispatchQueue.main.async {
            semaphore.wait()
            
            print("Pose Detection in Progress")
            
            let options = AccuratePoseDetectorOptions()
            options.detectorMode = .stream
            let poseDetector = PoseDetector.poseDetector(options: options)
            
            var frameCount = 0
            
            DispatchQueue.global(qos: .default).async {
                for image in self.originalFrames {
                    self.analyzeFrame(poseDetector: poseDetector, frame: VisionImage(image: UIImage(cgImage: image)), currentTime: 0.0, cgimage: image)
                    frameCount += 1
                    
                    if(frameCount >= self.originalFrames.count) {
                        semaphore.signal()
                    }
                }
            }
        }
        DispatchQueue.main.async {
            semaphore.wait()
            
            self.endLoadingObjects()
            
            var test = 0.0
            test = 1/30
            
            self.timer = Timer.scheduledTimer(timeInterval: test, target: self, selector: #selector(self.timerAction), userInfo: nil, repeats: true)
            
            semaphore.signal()
        }
    }
    
    // displays the videos from the editedImageArray that holds the edited images
    var timerCount = 0
    @objc func timerAction() {
        
        //print("Frame: ", timerCount)
        if(self.editedImageArray.count > timerCount) {
            //print(editedImageArray[timerCount].hashValue)
    
            self.trainingImageView.image = self.editedImageArray[timerCount]
        }
        else {
            timer.invalidate()
        }
        timerCount = timerCount + 1
    }
    
    // Generates a frame (CGImage) from a video at a certain time
    func generateFrame(videoURL : URL, frameTime:Float64) -> CGImage? {
        let asset = AVAsset(url: videoURL)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        generator.requestedTimeToleranceBefore = CMTime.zero;
        generator.requestedTimeToleranceAfter = CMTime.zero;
        
        let time = CMTimeMakeWithSeconds(frameTime, preferredTimescale: 600)
        
        if let image = try? generator.copyCGImage(at: time, actualTime: nil) {
            return image
        }
        else {
            return nil
        }
    }
    

    // analyze visionimage for poses and save angle result to dictionary
    func analyzeFrame(poseDetector: PoseDetector, frame: VisionImage, currentTime: Double, cgimage: CGImage) {

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
                    let noseLM = (pose.landmark(ofType: .nose))
                    let leftEyeInnerLM = (pose.landmark(ofType: .leftEyeInner))
                    let leftEyeLM = (pose.landmark(ofType: .leftEye))
                    let leftEyeOuterLM = (pose.landmark(ofType: .leftEyeOuter))
                    let rightEyeInnerLM = (pose.landmark(ofType: .rightEyeInner))
                    let rightEyeLM = (pose.landmark(ofType: .rightEye))
                    let rightEyeOuterLM = (pose.landmark(ofType: .rightEyeOuter))
                    let leftEarLM = (pose.landmark(ofType: .leftEar))
                    let rightEarLM = (pose.landmark(ofType: .rightEar))
                    let mouthLeftLM = (pose.landmark(ofType: .mouthLeft))
                    let mouthRightLM = (pose.landmark(ofType: .mouthRight))
                    let leftShoulderLM = (pose.landmark(ofType: .leftShoulder))
                    let rightShoulderLM = (pose.landmark(ofType: .rightShoulder))
                    let leftElbowLM = (pose.landmark(ofType: .leftElbow))
                    let rightElbowLM = (pose.landmark(ofType: .rightElbow))
                    let leftWristLM = (pose.landmark(ofType: .leftWrist))
                    let rightWristLM = (pose.landmark(ofType: .rightWrist))
                    let leftPinkyFingerLM = (pose.landmark(ofType: .leftPinkyFinger))
                    let rightPinkyFingerLM = (pose.landmark(ofType: .rightPinkyFinger))
                    let leftIndexFingerLM = (pose.landmark(ofType: .leftIndexFinger))
                    let rightIndexFingerLM = (pose.landmark(ofType: .rightIndexFinger))
                    let leftThumbLM = (pose.landmark(ofType: .leftThumb))
                    let rightThumbLM = (pose.landmark(ofType: .rightThumb))
                    let leftHipLM = (pose.landmark(ofType: .leftHip))
                    let rightHipLM = (pose.landmark(ofType: .rightHip))
                    let leftKneeLM = (pose.landmark(ofType: .leftKnee))
                    let rightKneeLM = (pose.landmark(ofType: .rightKnee))
                    let leftAnkleLM = (pose.landmark(ofType: .leftAnkle))
                    let rightAnkleLM = (pose.landmark(ofType: .rightAnkle))
                    let leftHeelLM = (pose.landmark(ofType: .leftHeel))
                    let rightHeelLM = (pose.landmark(ofType: .rightHeel))
                    let leftToeLM = (pose.landmark(ofType: .leftToe))
                    let rightToeLM = (pose.landmark(ofType: .rightToe))


                    let imgDr = UIImage(cgImage: cgimage)

                    UIGraphicsBeginImageContext(imgDr.size)
                    imgDr.draw(at: CGPoint.zero)

                    let context = UIGraphicsGetCurrentContext()
                    
                    self.checkFrameLike(noseLM, context!, abrev: "")
                    self.checkFrameLike(leftEyeInnerLM, context!, abrev: "")
                    self.checkFrameLike(leftEyeLM, context!, abrev: "")
                    self.checkFrameLike(leftEyeOuterLM, context!, abrev: "")
                    self.checkFrameLike(rightEyeInnerLM, context!, abrev: "")
                    self.checkFrameLike(rightEyeLM, context!, abrev: "")
                    self.checkFrameLike(rightEyeOuterLM, context!, abrev: "")
                    self.checkFrameLike(leftEarLM, context!, abrev: "")
                    self.checkFrameLike(rightEarLM, context!, abrev: "")
                    self.checkFrameLike(mouthLeftLM, context!, abrev: "")
                    self.checkFrameLike(mouthRightLM, context!, abrev: "")
                    self.checkFrameLike(leftShoulderLM, context!, abrev: "lsh")
                    self.checkFrameLike(rightShoulderLM, context!, abrev: "rsh")
                    self.checkFrameLike(leftElbowLM, context!, abrev: "lel")
                    self.checkFrameLike(rightElbowLM, context!, abrev: "rel")
                    self.checkFrameLike(leftWristLM, context!, abrev: "lro")
                    self.checkFrameLike(rightWristLM, context!, abrev: "rwr")
                    self.checkFrameLike(leftPinkyFingerLM, context!, abrev: "")
                    self.checkFrameLike(rightPinkyFingerLM, context!, abrev: "")
                    self.checkFrameLike(leftIndexFingerLM, context!, abrev: "")
                    self.checkFrameLike(rightIndexFingerLM, context!, abrev: "")
                    self.checkFrameLike(leftThumbLM, context!, abrev: "")
                    self.checkFrameLike(rightThumbLM, context!, abrev: "")
                    self.checkFrameLike(leftHipLM, context!, abrev: "lhi")
                    self.checkFrameLike(rightHipLM, context!, abrev: "rhi")
                    self.checkFrameLike(leftKneeLM, context!, abrev: "lkn")
                    self.checkFrameLike(rightKneeLM, context!, abrev: "rkn")
                    self.checkFrameLike(leftAnkleLM, context!, abrev: "lan")
                    self.checkFrameLike(rightAnkleLM, context!, abrev: "ran")
                    self.checkFrameLike(leftHeelLM, context!, abrev: "")
                    self.checkFrameLike(rightHeelLM, context!, abrev: "")
                    self.checkFrameLike(leftToeLM, context!, abrev: "")
                    self.checkFrameLike(rightToeLM, context!, abrev: "")

                    context?.drawPath(using: .stroke)

                    let myImage = UIGraphicsGetImageFromCurrentImageContext()
                    UIGraphicsEndImageContext()

                    editedImageArray.append(myImage)
                }
        }
    
    
    // Check if the landmark.inFrameLikelihood is > 0.5 if it is add the circle
    func checkFrameLike(_ landMark: PoseLandmark, _ lmContext: CGContext, abrev: String) {
        if landMark.inFrameLikelihood > 0.5 {
            
            let landMarkPos = landMark.position
               
            if(problemJoints.contains(abrev)) {
                let bounds = CGRect(x: landMarkPos.x, y: landMarkPos.y, width: 10, height: 10)
                lmContext.saveGState()
                lmContext.setFillColor(UIColor.red.cgColor)
                lmContext.addEllipse(in: bounds)
                lmContext.drawPath(using: .fill)
                lmContext.restoreGState()
            }
            else {
                let bounds = CGRect(x: landMarkPos.x, y: landMarkPos.y, width: 10, height: 10)
                lmContext.saveGState()
                lmContext.setFillColor(UIColor.green.cgColor)
                lmContext.addEllipse(in: bounds)
                lmContext.drawPath(using: .fill)
                lmContext.restoreGState()
            }
        }//end if
        
    }//end checkFrameLike
    
    // Start loading objects including the loading screen which is the system background and the animated spinner
    func startLoadingObjects() {
        let width = self.view.bounds.width;
        let height = self.view.bounds.height;
        loadingScreen = UIView(frame: CGRect(x: 0.0, y: 0.0, width: width, height: height))
        loadingScreen.backgroundColor = UIColor.systemBackground
        view.addSubview(loadingScreen)
        
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.color = UIColor.init(named: "Form2FlyBlue")
        spinner.startAnimating()
        view.addSubview(spinner)
        spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    // This will dismiss the loading objects before the training window opens
    func endLoadingObjects() {
        //self.navigationController?.setNavigationBarHidden(false, animated: true)
        loadingScreen.removeFromSuperview()
        spinner.stopAnimating()
    }
    
}

    
    



    



