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

    static let share = TrainingViewController()
    
    @IBOutlet weak var myImgView: UIImageView!
    
    var currentUser = User(dominantHand: "", pickOrMatch: "", throwType: "", proName: "", vidURL: "")
    
    var uservideourl = ""
    
    var testArray = [String]()
    
    var editedImageArray = [UIImage?]()
    var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    var originalFrames = [CGImage]()
    
    var timerCount = 0
    @objc func timerAction() {
        
        print("Frame: ", timerCount)
        if(self.editedImageArray.count > timerCount) {
            self.myImgView.image = self.editedImageArray[timerCount]
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
    
    // allows user to pick the video they want, once the user picks it will be handled by the imagePickerController
    @IBAction func watchVidButton(_ sender: Any) {
        let videoPicker = UIImagePickerController()
        videoPicker.modalPresentationStyle = .currentContext
        videoPicker.videoQuality = .typeHigh
        videoPicker.delegate = self
        videoPicker.sourceType = .photoLibrary
        videoPicker.mediaTypes = [kUTTypeMovie as String]
        videoPicker.allowsEditing = true
        
        // If we want to avoid compression
        //if #available(iOS 11.0, *) {
          //  videoPicker.videoExportPreset = AVAssetExportPresetPassthrough
        //}
        
        self.present(videoPicker, animated: true, completion: nil)
    } //end watchVidBtn
    
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

//                context?.setStrokeColor(UIColor.green.cgColor)
//                context?.setAlpha(0.5)
//                context?.setLineWidth(10.0)
               
          
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
                
                
                // Angle Calculations
                let leftWristVertexAngle = self.calculateAngle(vertex: leftWristLM.position, p2: leftElbowLM.position, p3: leftIndexFingerLM.position)
                let leftElbowVertexAngle = self.calculateAngle(vertex: leftElbowLM.position, p2: leftShoulderLM.position, p3: leftWristLM.position)
                let leftShoulderVertexAngle = self.calculateAngle(vertex: leftShoulderLM.position, p2: leftElbowLM.position, p3: leftHipLM.position)
                let leftHipVertexAngle = self.calculateAngle(vertex: leftHipLM.position, p2: leftShoulderLM.position, p3: leftKneeLM.position)
                let leftKneeVertexAngle = self.calculateAngle(vertex: leftKneeLM.position, p2: leftHipLM.position, p3: leftAnkleLM.position)
                let leftAnkleVertexAngle = self.calculateAngle(vertex: leftAnkleLM.position, p2: leftKneeLM.position, p3: leftToeLM.position)
                // Experimental Calculation this semi tells us rotation
                let leftWristRotAngle = self.calculateWristRotation(vertex: leftPinkyFingerLM.position, p2X: leftPinkyFingerLM.position.x, p2Y: leftThumbLM.position.y, p3: leftThumbLM.position)
                
                let leftHalfData = leftWristVertexAngle + " " + leftElbowVertexAngle + " " + leftShoulderVertexAngle + " " + leftHipVertexAngle + " " + leftKneeVertexAngle + " " + leftAnkleVertexAngle + " " + leftWristRotAngle
                
                let rightWristVertexAngle = self.calculateAngle(vertex: rightWristLM.position, p2: rightElbowLM.position, p3: rightIndexFingerLM.position)
                let rightElbowVertexAngle = self.calculateAngle(vertex: rightElbowLM.position, p2: rightShoulderLM.position, p3: rightWristLM.position)
                let rightShoulderVertexAngle = self.calculateAngle(vertex: rightShoulderLM.position, p2: rightElbowLM.position, p3: rightHipLM.position)
                let rightHipVertexAngle = self.calculateAngle(vertex: rightHipLM.position, p2: rightShoulderLM.position, p3: rightKneeLM.position)
                let rightKneeVertexAngle = self.calculateAngle(vertex: rightKneeLM.position, p2: rightHipLM.position, p3: rightAnkleLM.position)
                let rightAnkleVertexAngle = self.calculateAngle(vertex: rightAnkleLM.position, p2: rightKneeLM.position, p3: rightToeLM.position)
                // Experimental Calculation this semi tells us rotation
                let rightWristRotAngle = self.calculateWristRotation(vertex: leftPinkyFingerLM.position, p2X: leftPinkyFingerLM.position.x, p2Y: leftThumbLM.position.y, p3: leftThumbLM.position)
                
                let rightHalfData = rightWristVertexAngle + " " + rightElbowVertexAngle + " " + rightShoulderVertexAngle + " " + rightHipVertexAngle + " " + rightKneeVertexAngle + " " + rightAnkleVertexAngle + " " +  rightWristRotAngle
                
                let outputData = leftHalfData + " " + rightHalfData //+ "\n"
                
                testArray.append(outputData)

//                print("data in the test array")
//                for element in testArray {
//                  print (element)
//                }
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
//
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
