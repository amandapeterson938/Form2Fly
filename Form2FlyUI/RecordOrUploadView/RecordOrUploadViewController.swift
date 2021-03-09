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
                
                //analyzeVideo(video: video)
                print("Perry")
                let testVar = generateCGI(video: video)
                print(testVar.count)
                analyzePoses(imageFrames: testVar)
                
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
            
            //analyzeVideo(video: video)
            
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
    
    func generateCGI(video: AVURLAsset) -> [VisionImage] {
        var generatedImages = [VisionImage]()
        
        let reader = try! AVAssetReader(asset: video)

        let videoTrack = video.tracks(withMediaType: AVMediaType.video)[0]

        // read video frames as BGRA
        let trackReaderOutput = AVAssetReaderTrackOutput(track: videoTrack, outputSettings:[String(kCVPixelBufferPixelFormatTypeKey): NSNumber(value: kCVPixelFormatType_32BGRA)])

        reader.add(trackReaderOutput)
        reader.startReading()

        while let sampleBuffer = trackReaderOutput.copyNextSampleBuffer() {
            if let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
                let ciImage = CIImage(cvImageBuffer: imageBuffer)
                let cgImage = convertCIImageToCGImage(inputImage: ciImage) as CGImage?
                
                generatedImages.append(VisionImage(image: UIImage(cgImage: cgImage!)))
            }
        }
        return generatedImages
    }//end generateCGI
    
    
    func analyzePoses(imageFrames: [VisionImage]) {
        // Set up pose detector with .stream
        let options = AccuratePoseDetectorOptions()
        options.detectorMode = .stream
        let poseDetector = PoseDetector.poseDetector(options: options)
        
        DispatchQueue.main.async {
            DispatchQueue.global(qos: .background).async {
                for frame in imageFrames {
                    
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
                        let noseLM = (pose.landmark(ofType: .nose)).position
                        let leftEyeInnerLM = (pose.landmark(ofType: .leftEyeInner)).position
                        let leftEyeLM = (pose.landmark(ofType: .leftEye)).position
                        let leftEyeOuterLM = (pose.landmark(ofType: .leftEyeOuter)).position
                        let rightEyeInnerLM = (pose.landmark(ofType: .rightEyeInner)).position
                        let rightEyeLM = (pose.landmark(ofType: .rightEye)).position
                        let rightEyeOuterLM = (pose.landmark(ofType: .rightEyeOuter)).position
                        let leftEarLM = (pose.landmark(ofType: .leftEar)).position
                        let rightEarLM = (pose.landmark(ofType: .rightEar)).position
                        let mouthLeftLM = (pose.landmark(ofType: .mouthLeft)).position
                        let mouthRightLM = (pose.landmark(ofType: .mouthRight)).position
                        let leftShoulderLM = (pose.landmark(ofType: .leftShoulder)).position
                        let rightShoulderLM = (pose.landmark(ofType: .rightShoulder)).position
                        let leftElbowLM = (pose.landmark(ofType: .leftElbow)).position
                        let rightElbowLM = (pose.landmark(ofType: .rightElbow)).position
                        let leftWristLM = (pose.landmark(ofType: .leftWrist)).position
                        let rightWristLM = (pose.landmark(ofType: .rightWrist)).position
                        let leftPinkyFingerLM = (pose.landmark(ofType: .leftPinkyFinger)).position
                        let rightPinkyFingerLM = (pose.landmark(ofType: .rightPinkyFinger)).position
                        let leftIndexFingerLM = (pose.landmark(ofType: .leftIndexFinger)).position
                        let rightIndexFingerLM = (pose.landmark(ofType: .rightIndexFinger)).position
                        let leftThumbLM = (pose.landmark(ofType: .leftThumb)).position
                        let rightThumbLM = (pose.landmark(ofType: .rightThumb)).position
                        let leftHipLM = (pose.landmark(ofType: .leftHip)).position
                        let rightHipLM = (pose.landmark(ofType: .rightHip)).position
                        let leftKneeLM = (pose.landmark(ofType: .leftKnee)).position
                        let rightKneeLM = (pose.landmark(ofType: .rightKnee)).position
                        let leftAnkleLM = (pose.landmark(ofType: .leftAnkle)).position
                        let rightAnkleLM = (pose.landmark(ofType: .rightAnkle)).position
                        let leftHeelLM = (pose.landmark(ofType: .leftHeel)).position
                        let rightHeelLM = (pose.landmark(ofType: .rightHeel)).position
                        let leftToeLM = (pose.landmark(ofType: .leftToe)).position
                        let rightToeLM = (pose.landmark(ofType: .rightToe)).position
                        
                        
                        self.calculateAngle(vertex: leftElbowLM, p2: leftShoulderLM, p3: leftWristLM)
                    }
                    
                    
                }
            }
        }
    }
    
    func convertCIImageToCGImage(inputImage: CIImage) -> CGImage? {
        let context = CIContext(options: nil)
        if let cgImage = context.createCGImage(inputImage, from: inputImage.extent) {
            return cgImage
        }
        return nil
    }
    
    
    func analyzeVideo(video: AVURLAsset) {
        let videoSec = Float(video.duration.seconds)
        
        let generator = AVAssetImageGenerator(asset: video)
        
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
        
        // Set up pose detector with .stream
        let options = AccuratePoseDetectorOptions()
        options.detectorMode = .stream
        let poseDetector = PoseDetector.poseDetector(options: options)
        
        var elbowAngles = [Double]()
        
        generator.generateCGImagesAsynchronously(forTimes: frameForTimes, completionHandler: {requestedTime,image,actualTime,result,error in
            DispatchQueue.main.async {
                if let image = image {
                    let visionImg = VisionImage(image: UIImage(cgImage: image))
                    
                    DispatchQueue.global(qos: .background).async {
                        var results: [Pose]?
                        do {
                            results = try poseDetector.results(in: visionImg)
                        }
                        catch let error {
                            print("Failed to detect pose with error: \(error.localizedDescription)")
                            return
                        }
                        guard let detectedPoses = results, !detectedPoses.isEmpty else {
                            return
                        }
                        
                        DispatchQueue.main.async {
                            for pose in detectedPoses {
                                let noseLM = (pose.landmark(ofType: .nose)).position
                                let leftEyeInnerLM = (pose.landmark(ofType: .leftEyeInner)).position
                                let leftEyeLM = (pose.landmark(ofType: .leftEye)).position
                                let leftEyeOuterLM = (pose.landmark(ofType: .leftEyeOuter)).position
                                let rightEyeInnerLM = (pose.landmark(ofType: .rightEyeInner)).position
                                let rightEyeLM = (pose.landmark(ofType: .rightEye)).position
                                let rightEyeOuterLM = (pose.landmark(ofType: .rightEyeOuter)).position
                                let leftEarLM = (pose.landmark(ofType: .leftEar)).position
                                let rightEarLM = (pose.landmark(ofType: .rightEar)).position
                                let mouthLeftLM = (pose.landmark(ofType: .mouthLeft)).position
                                let mouthRightLM = (pose.landmark(ofType: .mouthRight)).position
                                let leftShoulderLM = (pose.landmark(ofType: .leftShoulder)).position
                                let rightShoulderLM = (pose.landmark(ofType: .rightShoulder)).position
                                let leftElbowLM = (pose.landmark(ofType: .leftElbow)).position
                                let rightElbowLM = (pose.landmark(ofType: .rightElbow)).position
                                let leftWristLM = (pose.landmark(ofType: .leftWrist)).position
                                let rightWristLM = (pose.landmark(ofType: .rightWrist)).position
                                let leftPinkyFingerLM = (pose.landmark(ofType: .leftPinkyFinger)).position
                                let rightPinkyFingerLM = (pose.landmark(ofType: .rightPinkyFinger)).position
                                let leftIndexFingerLM = (pose.landmark(ofType: .leftIndexFinger)).position
                                let rightIndexFingerLM = (pose.landmark(ofType: .rightIndexFinger)).position
                                let leftThumbLM = (pose.landmark(ofType: .leftThumb)).position
                                let rightThumbLM = (pose.landmark(ofType: .rightThumb)).position
                                let leftHipLM = (pose.landmark(ofType: .leftHip)).position
                                let rightHipLM = (pose.landmark(ofType: .rightHip)).position
                                let leftKneeLM = (pose.landmark(ofType: .leftKnee)).position
                                let rightKneeLM = (pose.landmark(ofType: .rightKnee)).position
                                let leftAnkleLM = (pose.landmark(ofType: .leftAnkle)).position
                                let rightAnkleLM = (pose.landmark(ofType: .rightAnkle)).position
                                let leftHeelLM = (pose.landmark(ofType: .leftHeel)).position
                                let rightHeelLM = (pose.landmark(ofType: .rightHeel)).position
                                let leftToeLM = (pose.landmark(ofType: .leftToe)).position
                                let rightToeLM = (pose.landmark(ofType: .rightToe)).position
                                
                                
                                let p1x = leftElbowLM.x
                                let p1y = leftElbowLM.y

                                let p2x = leftShoulderLM.x
                                let p2y = leftShoulderLM.y

                                let p3x = leftWristLM.x
                                let p3y = leftWristLM.y

                                let p12 = ((pow((Double(p1x) - Double(p2x)), 2)) + (pow((Double(p1y) - Double(p2y)), 2))).squareRoot()
                                let p13 = ((pow((Double(p1x) - Double(p3x)), 2)) + (pow((Double(p1y) - Double(p3y)), 2))).squareRoot()
                                let p23 = ((pow((Double(p2x) - Double(p3x)), 2)) + (pow((Double(p2y) - Double(p3y)), 2))).squareRoot()

                                let div1 = Double(pow(p12,2) + pow(p13, 2) - pow(p23,2))

                                let ang = acos(div1 / Double(2 * p12 * p13)) * (Double(180) / Double(CGFloat.pi))
                                
                                elbowAngles.append(ang)
                                print(elbowAngles.count)

                                //print(String(ang) + "\t\t" + String(requestedTime.seconds))
                                
                                //self.calculateAngle(vertex: leftElbowLM, p2: leftShoulderLM, p3: leftWristLM)
                            } // end for pose in detectedPoses
                        }
                        
                    }//end
                    
                    DispatchQueue.global(qos: .background).async {
                        
                    }
                    
                } //end if let image //image is the image of the current frame from the time specified in frameForTimes
            }
            usleep(30000)
        })
        generator.cancelAllCGImageGeneration()
        print("Im done.")
    }
    
    
    func calculateAngle(vertex: Vision3DPoint, p2: Vision3DPoint, p3: Vision3DPoint ) {
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
        
        print(angleDegrees)
    }
 
}
