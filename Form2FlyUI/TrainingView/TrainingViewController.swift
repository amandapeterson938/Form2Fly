//
//  TrainingViewController.swift
//  Form2FlyUI
//
//  Created by Amanda Peterson on 2/28/21.
//

import UIKit
import AVKit
import MLKit
import MobileCoreServices


class TrainingViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    //static let shared = TrainingViewController()

  
    @IBOutlet weak var trainingAdviceLabel: UILabel!
    @IBOutlet weak var trainingImageView: UIImageView!
    
    var currentUser = User(dominantHand: "", pickOrMatch: "", throwType: "", proName: "", vidURL: "")
    
    var uservideourl = ""
    
    var testArray = [String]()
    
    var editedImageArray = [UIImage?]()
    
    var timer = Timer()
   
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let url = URL(string: currentUser.vidURL) else { return }
        
        print("trainU", currentUser.vidURL, "done")
       
        analyzeVideoURL(videoURL: url)
        
        self.trainingAdviceLabel.text = "Hello World!"
        
    }
    
    var originalFrames = [CGImage]()
    
    func analyzeVideoURL(videoURL : URL) {
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
                self.originalFrames.append(img!)
                
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
            
            print("Edited Images")
            
            print(self.testArray)
            
            var test = 0.0
            test = 1/30
            
            self.timer = Timer.scheduledTimer(timeInterval: test, target: self, selector: #selector(self.timerAction), userInfo: nil, repeats: true)
            
            semaphore.signal()
        }
    }
    
    // displays the videos from the testVideoArray that holds the edited images
    var timerCount = 0
    var testCount9 = 0.0
    @objc func timerAction() {
        
        print("Frame: ", timerCount)
        if(self.editedImageArray.count > timerCount) {
            print(editedImageArray[timerCount].hashValue)
            self.trainingAdviceLabel.text = String(timerCount)
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
        
        let assetImageGenerate = AVAssetImageGenerator(asset: asset)
        assetImageGenerate.appliesPreferredTrackTransform = true
        assetImageGenerate.requestedTimeToleranceAfter = CMTime.zero;
        assetImageGenerate.requestedTimeToleranceBefore = CMTime.zero;
        
        let time = CMTimeMakeWithSeconds(frameTime, preferredTimescale: 600)
        
        if let img = try? assetImageGenerate.copyCGImage(at:time, actualTime: nil) {
            return img
        } else {
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

                    context?.setStrokeColor(UIColor.green.cgColor)
                    context?.setAlpha(0.5)
                    context?.setLineWidth(10.0)

                    self.checkFrameLike(noseLM, context!)
                    self.checkFrameLike(leftEyeInnerLM, context!)
                    self.checkFrameLike(leftEyeLM, context!)
                    self.checkFrameLike(leftEyeOuterLM, context!)
                    self.checkFrameLike(rightEyeInnerLM, context!)
                    self.checkFrameLike(rightEyeLM, context!)
                    self.checkFrameLike(rightEyeOuterLM, context!)
                    self.checkFrameLike(leftEarLM, context!)
                    self.checkFrameLike(rightEarLM, context!)
                    self.checkFrameLike(mouthLeftLM, context!)
                    self.checkFrameLike(mouthRightLM, context!)
                    self.checkFrameLike(leftShoulderLM, context!)
                    self.checkFrameLike(rightShoulderLM, context!)
                    self.checkFrameLike(leftElbowLM, context!)
                    self.checkFrameLike(rightElbowLM, context!)
                    self.checkFrameLike(leftWristLM, context!)
                    self.checkFrameLike(rightWristLM, context!)
                    self.checkFrameLike(leftPinkyFingerLM, context!)
                    self.checkFrameLike(rightPinkyFingerLM, context!)
                    self.checkFrameLike(leftIndexFingerLM, context!)
                    self.checkFrameLike(rightIndexFingerLM, context!)
                    self.checkFrameLike(leftThumbLM, context!)
                    self.checkFrameLike(rightThumbLM, context!)
                    self.checkFrameLike(leftHipLM, context!)
                    self.checkFrameLike(rightHipLM, context!)
                    self.checkFrameLike(leftKneeLM, context!)
                    self.checkFrameLike(rightKneeLM, context!)
                    self.checkFrameLike(leftAnkleLM, context!)
                    self.checkFrameLike(rightAnkleLM, context!)
                    self.checkFrameLike(leftHeelLM, context!)
                    self.checkFrameLike(rightHeelLM, context!)
                    self.checkFrameLike(leftToeLM, context!)
                    self.checkFrameLike(rightToeLM, context!)

                    context?.drawPath(using: .stroke)

                    let myImage = UIGraphicsGetImageFromCurrentImageContext()
                    UIGraphicsEndImageContext()

                    editedImageArray.append(myImage)

                    //self.myImgView.image = myImage
                }
        }
//
//
    // Check if the landmark.inFrameLikelihood is > 0.5 if it is add the circle
    func checkFrameLike(_ landMark: PoseLandmark, _ lmContext: CGContext) {
        if landMark.inFrameLikelihood > 0.5 {
            let landMarkPos = landMark.position
            lmContext.addEllipse(in: CGRect(x: landMarkPos.x, y: landMarkPos.y, width: 10, height: 10))
            //print("IN FRAME")
        }//end if
        else {
            //print("OUT OF FRAME")
        }
    }//end checkFrameLike
//
//
    
}
 
    
    



    



