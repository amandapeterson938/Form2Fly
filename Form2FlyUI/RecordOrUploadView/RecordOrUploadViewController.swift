//
//  RecordOrUploadViewController.swift
//  Form2FlyUI
//
//  Created by Amanda Peterson on 2/28/21.
//

import UIKit
import AVKit
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
}
