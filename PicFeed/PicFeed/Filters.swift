//
//  Filters.swift
//  PicFeed
//
//  Created by Brandon Little on 3/28/17.
//  Copyright © 2017 Brandon Little. All rights reserved.
//

import UIKit

enum FilterName : String {
    case vintage = "CIPhotoEffectTransfer"
    case blackAndWhite = "CIPhotoEffectMono"
    case comicEffect = "CIComicEffect"
    case distorted = "CIBumpDistortion"
    case lineOverlay = "CILineOverlay"
}

typealias FilterCompletion = (UIImage?) -> ()

class Filters {
    
    static let shared = Filters()
    
    var context : CIContext
    
    private init() {
        let options = [kCIContextWorkingColorSpace: NSNull()]
        guard let eaglContext = EAGLContext(api: .openGLES2) else { fatalError("Failed to create EAGLContext") }
        self.context = CIContext(eaglContext: eaglContext, options: options)
    }
    
    //store original image user picks
    static var originalImage = UIImage()
    
    //GPU Context lines, NSNull object that represents nil
    
    
    class func filter(name: FilterName, image: UIImage, completion: @escaping FilterCompletion) {
        
        OperationQueue().addOperation {
            guard let filter = CIFilter(name: name.rawValue) else {fatalError("Failed to create CIFilter")}
            
            let coreImage = CIImage(image: image)
            filter.setValue(coreImage, forKey: kCIInputImageKey)
            
            
            //Get final image using GPU
            
            guard let outputImage = filter.outputImage else { fatalError("Failed to get output image from filter.") }
            
            if let cgImage = Filters.shared.context.createCGImage(outputImage, from: outputImage.extent) {
                
                let finalImage = UIImage(cgImage: cgImage)
                
                OperationQueue.main.addOperation {
                    completion(finalImage)
                }
                
            } else {
                OperationQueue.main.addOperation {
                    completion(nil)
                }
            }
            
        }
        
    }
    
}
