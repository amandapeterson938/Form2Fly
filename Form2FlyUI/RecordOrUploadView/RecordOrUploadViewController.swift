//
//  RecordOrUploadViewController.swift
//  Form2FlyUI
//
//  Created by Amanda Peterson on 2/28/21.
//

import UIKit
import MobileCoreServices

class RecordOrUploadViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    @IBOutlet weak var recordVideoBtn: UIButton!
    @IBOutlet weak var uploadVideoBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Round edges of the buttons
        recordVideoBtn.layer.cornerRadius = 12
        uploadVideoBtn.layer.cornerRadius = 12
    }
    
    @IBAction func recordVideo(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            let recordPicker = UIImagePickerController()
            recordPicker.delegate = self
            recordPicker.sourceType = .camera
            recordPicker.mediaTypes = [kUTTypeMovie as String]
            recordPicker.allowsEditing = true
            self.present(recordPicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func uploadVideo(_ sender: Any) {
        let videoPicker = UIImagePickerController()
        videoPicker.modalPresentationStyle = .currentContext
        videoPicker.delegate = self
        videoPicker.sourceType = .photoLibrary
        videoPicker.mediaTypes = [kUTTypeMovie as String]
        videoPicker.allowsEditing = true
        
        self.present(videoPicker, animated: true, completion: nil)
        
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.dismiss(animated: true, completion: nil)
        
        if let newViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TrainingViewController") as? TrainingViewController {
            newViewController.modalPresentationStyle = .currentContext
            self.navigationController?.pushViewController(newViewController, animated: true)
        }
        
    }
    
    
}
