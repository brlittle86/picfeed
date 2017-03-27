//
//  HomeViewController.swift
//  PicFeed
//
//  Created by Brandon Little on 3/27/17.
//  Copyright © 2017 Brandon Little. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let imagePicker = UIImagePickerController()

    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imageView.image = #imageLiteral(resourceName: "Koenigsegg")
    }
    
    func presentImagePickerWith(sourceType: UIImagePickerControllerSourceType){
        
        self.imagePicker.delegate = self
        self.imagePicker.sourceType = sourceType
        self.present(self.imagePicker, animated: true, completion: nil)
        
    }
    
    func isSourceTypeAvailable() {
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print("Info: \(info)")
    }
    
    func doesHaveCamera() -> Bool {
        return UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)
    }
    
    @IBAction func imageTapped(_ sender: Any) {
        print("User tapped image.")
        presentActionSheet()
    }
    
    func presentActionSheet(){
        
        let actionSheetController = UIAlertController(title: "Source", message: "Please select Source Type", preferredStyle: .actionSheet)
        
        if doesHaveCamera() == true {
            let cameraAction = UIAlertAction(title: "Camera", style: .default) { (action) in
                self.presentImagePickerWith(sourceType: .camera)
            }
            actionSheetController.addAction(cameraAction)
        }
        
        let photoAction = UIAlertAction(title: "Photo Library", style: .default) { (action) in
            self.presentImagePickerWith(sourceType: .photoLibrary)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        
        
        actionSheetController.addAction(photoAction)
        actionSheetController.addAction(cancelAction)
        
        self.present(actionSheetController, animated: true, completion: nil)
        
    }
    
}
