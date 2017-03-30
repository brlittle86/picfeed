//
//  UIExtensions.swift
//  PicFeed
//
//  Created by Brandon Little on 3/28/17.
//  Copyright © 2017 Brandon Little. All rights reserved.
//

import UIKit

extension UIImage {
    
    func resize(size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContext(size)
        
        self.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return resizedImage
    }
    
    var path: URL {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            fatalError("Error getting the documents directory")
        }
        
        return documentsDirectory.appendingPathComponent("image")
    }
}

extension UIResponder {
    
    static var identifier : String {
        return String(describing: self)
    }
    
}
