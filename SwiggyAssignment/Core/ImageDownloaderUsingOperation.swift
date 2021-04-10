//
//  ImageDownloaderUsingOperation.swift
//  SwiggyAssignment
//
//  Created by Satyam Sehgal on 08/04/21.

import UIKit

class ImageDownloaderAsync {
    lazy var operationQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "DownloadImage"
        return queue
    }()
    
    var imageCache = NSCache<NSString, AnyObject>()
    
    // Make it singleton
    static let sharedInstance = ImageDownloaderAsync()
    private init () {}
    
    
    func downLoadImageFromLink(urlLink: URL, indexPath: IndexPath?, completion: @escaping (UIImage?, URL, IndexPath?, APIServiceError?) -> Void) {
        
        // Checking whether its already in cache or not
        if let imageFromCache = imageCache.object(forKey: urlLink.absoluteString as NSString) as? UIImage {
            completion(imageFromCache, urlLink, indexPath, nil)
            return
        }
        
        // Changing to high priority
        if let imageDownloadOperation = operationQueue.operations as? [ImageDownloadOperation], let firstOperation = imageDownloadOperation.first {
            for operation in imageDownloadOperation where  operation.imageURL.absoluteString == urlLink.absoluteString
                && !operation.isFinished && operation.isExecuting {
                    operation.queuePriority = .veryHigh
            }
            if indexPath == nil {
                firstOperation.queuePriority = .high
            }
        }
        
        let operationInstance = ImageDownloadOperation.init(url: urlLink, indexPath: indexPath ?? IndexPath.init(row: 0, section: 0))
        operationInstance.completionHandler = { [weak self] (image, url, indexPath, error) in
            guard let sself = self else { return }
            if let image = image {
                sself.imageCache.setObject(image, forKey: urlLink.absoluteString as NSString)
            }
            completion(image, urlLink, indexPath, nil)
        }
        self.operationQueue.addOperation(operationInstance)
    }
    
    func slowDownThePriority(_ urlLink: URL) {
        if let imageDownloadOperation = operationQueue.operations as? [ImageDownloadOperation] {
            for operation in imageDownloadOperation where  operation.imageURL.absoluteString == urlLink.absoluteString
                && !operation.isFinished && operation.isExecuting {
                    operation.queuePriority = .veryLow
            }
        }
    }
}

class ImageDownloadOperation: Operation {
    var completionHandler: ((_ image: UIImage?, _ url: URL, _ indexPath: IndexPath?, _ error: Error?) -> Void)?
    var imageURL: URL
    var indexPath: IndexPath
    
    init(url: URL, indexPath: IndexPath) {
        self.imageURL = url
        self.indexPath = indexPath
    }
    
    override func main() {
        guard !isCancelled else {
            finish(true)
            return
        }
        executing(true)
        downloadFromURL(imageURL)
    }
    
    @discardableResult func downloadFromURL(_ imageURL: URL) -> URLSessionDownloadTask {
        let task = URLSession.shared.downloadTask(with: imageURL, completionHandler: { [weak self] (url, response, error) -> Void in
            guard error == nil else { return }
            guard let self = self else { return }
            
            if let url = url, let data = try? Data(contentsOf: url){
                let image = UIImage(data: data)
                self.completionHandler?(image, imageURL, self.indexPath, error)
            }
        })
        task.resume()
        return task
    }
    
    override var isAsynchronous: Bool { return true }
    
    private var _executing = false {
        willSet {
            willChangeValue(forKey: "isExecuting")
        }
        didSet {
            didChangeValue(forKey: "isExecuting")
        }
    }
    
    override var isExecuting: Bool { return _executing }
    
    private var _finished = false {
        willSet {
            willChangeValue(forKey: "isFinished")
        }
        
        didSet {
            didChangeValue(forKey: "isFinished")
        }
    }
    
    override var isFinished: Bool { return _finished }
    
    func executing(_ executing: Bool) { _executing = executing }
    
    func finish(_ finished: Bool) { _finished = finished }
}
