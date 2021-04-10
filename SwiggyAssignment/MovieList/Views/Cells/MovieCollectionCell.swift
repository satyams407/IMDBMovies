//
//  MovieCollectionCell.swift
//  SwiggyAssignment
//
//  Created by Satyam on 08/04/21.
//

import UIKit

class MovieCollectionCell: UICollectionViewCell {

    @IBOutlet weak var movieImage: UIImageView!
    
    var imageURL: URL!
    var indexPath: IndexPath!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configure(with model: MovieListCellModel) {
        if let url = model.imageUrl {
            imageURL = URL(string: url)
        }
        
        ImageDownloaderAsync.sharedInstance.downLoadImageFromLink(urlLink: imageURL, indexPath: indexPath) { [weak self] (image, url, indexPath, error)  in
            guard let strongSelf = self else { return }
            if let indexPath = indexPath, indexPath == strongSelf.indexPath {
                DispatchQueue.main.async {
                    strongSelf.movieImage.image = image
                }
            }
        }
    }
}
