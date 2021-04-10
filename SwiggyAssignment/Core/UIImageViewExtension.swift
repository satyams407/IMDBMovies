//
//  UIImageViewExtension.swift
//  SwiggyAssignment
//
//  Created by Satyam Sehgal on 08/04/21.

import UIKit

var imageCache = NSCache<NSString, AnyObject>()
    
extension UIImageView {
    // Either use SDWebImage or kingfisher library but i tired to make my own
    // Note: There is bug that i am not able to solve in given time for this assignment
    // Bug is when we do fast scrolling then sometimes photos at particular indexpath is reassigned with different pic.
    // Alternative:We can use SDWebImage or kingfisher library to have async download of image
    
    // **Additional - Implemented Image Caching**
    func downloadFromLink(link: String, contentMode: UIView.ContentMode) {
        self.image = nil
        let imageURLString = link
        if let imageFromCache = imageCache.object(forKey: link as NSString) as? UIImage {
            self.image = imageFromCache
            return
        }
        
        guard let url = URL(string: link) else {
            self.image = UIImage.init(named: "placeHolderImage.png")
            return
        }
        
        URLSession.shared.dataTask(with: url, completionHandler: { [weak self] (data, response, error) -> Void in
            guard let data = data, error == nil else { return }
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.contentMode = contentMode
                let imageToCache = UIImage(data: data)
                if imageURLString == link {
                    self.image = imageToCache
                }
                imageCache.setObject(imageToCache!, forKey: link as NSString)
            }
        }).resume()
    }
}

