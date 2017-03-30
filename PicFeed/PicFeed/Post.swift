//
//  Post.swift
//  PicFeed
//
//  Created by Brandon Little on 3/28/17.
//  Copyright © 2017 Brandon Little. All rights reserved.
//

import UIKit
import CloudKit

class Post{
    let image : UIImage
    let date : Date
    
    init(image : UIImage, date: Date = Date()) {
        self.image = image
        self.date = date
    }
}

enum PostError : Error {
    case writingImageToData
    case writingDataToDisk
}

extension Post {
    
    class func recordFor(post: Post) throws -> CKRecord? {
        guard let data = UIImageJPEGRepresentation(post.image, 0.7) else { throw PostError.writingImageToData }
        
        do {
            try data.write(to: post.image.path)
            
            let asset = CKAsset(fileURL: post.image.path)
            
            let record = CKRecord(recordType: "Post")
            record.setValue(asset, forKey: "image")
            record.setValue(post.date, forKey: "date")
            
            return record
        } catch  {
            throw PostError.writingDataToDisk
        }
    }
}
