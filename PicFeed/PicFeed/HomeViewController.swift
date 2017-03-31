//
//  HomeViewController.swift
//  PicFeed
//
//  Created by Brandon Little on 3/27/17.
//  Copyright © 2017 Brandon Little. All rights reserved.
//

import UIKit
import Social

let buttonAnimationDuration = 1.0
let heightConstant : CGFloat = 130

class HomeViewController: UIViewController, UINavigationControllerDelegate {
    
    let filterNames = [FilterName.blackAndWhite, FilterName.comicEffect, FilterName.distorted, FilterName.lineOverlay, FilterName.vintage]
    
    let imagePicker = UIImagePickerController()

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var filterButtonTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var postButtonBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        setupGalleryDelegate()
        
        Filters.originalImage = imageView.image
    }
    
    func setupGalleryDelegate(){
        if let tabBarController = self.tabBarController {
            guard let viewControllers = tabBarController.viewControllers else {return}
            
            guard let galleryController = viewControllers[1] as? GalleryViewController else {return}
            
            galleryController.delegate = self
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        postButtonBottomConstraint.constant = 8
        filterButtonTopConstraint.constant = 8
        UIView.animate(withDuration: buttonAnimationDuration) {
            self.view.layoutIfNeeded()
        }
        
    }
    
    func presentImagePickerWith(sourceType: UIImagePickerControllerSourceType){
        
        self.imagePicker.delegate = self
        self.imagePicker.sourceType = sourceType
        imagePicker.allowsEditing = true
        self.present(self.imagePicker, animated: true, completion: nil)
        
    }
    
    func doesHaveCamera() -> Bool {
        return UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)
    }
    
    @IBAction func imageTapped(_ sender: Any) {
        print("User tapped image.")
        presentActionSheet()
    }
    
    @IBAction func postButtonPressed(_ sender: Any) {
        if let image = self.imageView.image {
            let newPost = Post(image: image)
            CloudKit.shared.save(post: newPost, completion: { (success) in
                
                if success {
                    print("Saved Post successfully to CloudKit")
                } else {
                    print("We did NOT successfully save to CloudKit")
                }
            })
            UIImageWriteToSavedPhotosAlbum(image, self, nil, nil)
        }
    }
    
    
    
    @IBAction func filterButtonPressed(_ sender: Any) {
        guard self.imageView.image != nil else { return }
        if (self.collectionViewHeightConstraint.constant < heightConstant) {
            self.collectionViewHeightConstraint.constant = heightConstant
        } else {
            self.collectionViewHeightConstraint.constant = 0
        }
        
        
        UIView.animate(withDuration: 0.5) { 
            self.view.layoutIfNeeded()
        }
        
//        func applyFilter(_ name: FilterName) {
//            Filters.filter(name: name, image: image, completion: { (filteredImage) in
//                self.imageView.image = filteredImage
//            })
//        }
//        
//        let alertController = UIAlertController(title: "Filter", message: "Please select a filter.", preferredStyle: .alert)
//        
//        let blackAndWhiteAction = UIAlertAction(title: "Black & White", style: .default) { (action) in
//            applyFilter(.blackAndWhite)
//        }
//        
//        let vintageAction = UIAlertAction(title: "Vintage", style: .default) { (action) in
//            applyFilter(.vintage)
//        }
//        
//        let comicEffectAction = UIAlertAction(title: "Comic Effect", style: .default) { (action) in
//            applyFilter(.comicEffect)
//        }
//        
//        let bumpDistortionAction = UIAlertAction(title: "Bump Distortion", style: .default) { (action) in
//            applyFilter(.distorted)
//        }
//        
//        let lineOverlayAction = UIAlertAction(title: "Line Overlay", style: .default) { (action) in
//            applyFilter(.lineOverlay)
//        }
//        
//        let resetAction = UIAlertAction(title: "Reset Image", style: .destructive) { (action) in
//            self.imageView.image = Filters.originalImage
//        }
//        
//        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//        
//        alertController.addAction(blackAndWhiteAction)
//        alertController.addAction(vintageAction)
//        alertController.addAction(comicEffectAction)
//        alertController.addAction(bumpDistortionAction)
//        alertController.addAction(lineOverlayAction)
//        alertController.addAction(resetAction)
//        alertController.addAction(cancelAction)
//        
//        self.present(alertController, animated: true, completion: nil)
    }
    
    
    @IBAction func userLongPressed(_ sender: UILongPressGestureRecognizer) {
        
        if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter) {
            guard let composeController = SLComposeViewController(forServiceType: SLServiceTypeTwitter) else { return }
            
            composeController.add(self.imageView.image)
            
            self.present(composeController, animated: true, completion: nil)
        }
        
    }
    
    func presentActionSheet(){
        
        let actionSheetController = UIAlertController(title: "Source", message: "Please select Source Type", preferredStyle: .actionSheet)
        
        actionSheetController.popoverPresentationController?.sourceView = self.view
        //actionSheetController.popoverPresentationController?.sourceRect = self.view
        actionSheetController.modalPresentationStyle = .popover
        
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

//MARK: UICollectionView DataSource and Delegate
extension HomeViewController : UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let filterCell = collectionView.dequeueReusableCell(withReuseIdentifier: FilterCell.identifier, for: indexPath) as! FilterCell
        
        guard let originalImage = Filters.originalImage else { return filterCell }
        
        guard let resizedImage = originalImage.resize(size: CGSize(width: 150, height: 150)) else { return filterCell }
        
        let filterName = self.filterNames[indexPath.row]
        
        Filters.filter(name: filterName, image: resizedImage) { (filteredImage) in
            filterCell.imageView.image = filteredImage
        }
        
        filterCell.filterNameLabel.text = filterName.rawValue
        
        return filterCell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filterNames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let originalImage = Filters.originalImage else { return }
        let filterName = self.filterNames[indexPath.row]
        Filters.filter(name: filterName, image: originalImage) { (image) in
            self.imageView.image = image
        }
    }
}

//MARK: GalleryViewController Delegate
extension HomeViewController : GalleryViewControllerDelegate {
    func galleryController(didSelect image: UIImage) {
        self.imageView.image = image
        
        self.tabBarController?.selectedIndex = 0
    }
}

//MARK: UIImagePickerController Delegate
extension HomeViewController :  UIImagePickerControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print("Info: \(info)")
        
        guard let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage else { return }
        
        Filters.originalImage = originalImage
        
        self.collectionView.reloadData()
        
        self.imageView.image = info["UIImagePickerControllerEditedImage"] as? UIImage
        
        imagePickerControllerDidCancel(picker)
    }
}
