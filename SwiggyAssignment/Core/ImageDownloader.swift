//
//  CustomUIImageView.swift
//  SwiggyAssignment
//
//  Created by Satyam Sehgal on 08/04/21.


import UIKit
import Foundation

class ImageDownloader {
    var imageCache = NSCache<NSString, AnyObject>()
    
    static let sharedInstance = ImageDownloader()
    private init() {}
    
    func downloadFromLink(indexPath: IndexPath?, urlLink: URL, contentMode: UIView.ContentMode, completion: @escaping (UIImage?, URL, IndexPath?, APIServiceError?) -> Void) {
        
        // Checking whether its already in cache or not
        if let imageFromCache = imageCache.object(forKey: urlLink.absoluteString as NSString) as? UIImage {
            completion(imageFromCache, urlLink, indexPath, nil)
            return
        }
        
        let taskInstance = ImageDownloadTask(url: urlLink, indexPath: indexPath ?? IndexPath(row: 0, section: 0))
        taskInstance.downloadFromURL()
        taskInstance.completionHandler = { [weak self] (image, url, indexPath, error) in
            guard let sself = self else { return }
            if let image = image {
                sself.imageCache.setObject(image, forKey: urlLink.absoluteString as NSString)
            }
            completion(image, urlLink, indexPath, nil)
        }
    }
}

class ImageDownloadTask {
    var completionHandler: ((_ image: UIImage?, _ url: URL, _ indexPath: IndexPath?, _ error: Error?) -> Void)?
    var imageURL: URL
    var indexPath: IndexPath
    
    init(url: URL, indexPath: IndexPath) {
        self.imageURL = url
        self.indexPath = indexPath
    }
    
    func downloadFromURL() {
        let imageURL = self.imageURL
        URLSession.shared.downloadTask(with: imageURL, completionHandler: { [weak self] (url, response, error) -> Void in
            guard error == nil else { return }
            guard let self = self else {
                print("return when self nil")
                return
            }
            
            if let url = url, let data = try? Data(contentsOf: url){
                let image = UIImage(data: data)
                self.completionHandler?(image, imageURL, self.indexPath, error)
            }
        }).resume()
    }
}
