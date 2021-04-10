//
//  MovieDetailViewController.swift
//  SwiggyAssignment
//
//  Created by Satyam on 08/04/21.
//

import UIKit

class MovieDetailViewController: UIViewController {

    @IBOutlet weak var imageTitle: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    var imageStringURl, titleStr: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let url = imageStringURl { imageView.downloadFromLink(link: url, contentMode: .scaleAspectFit) }
        self.imageTitle.text = titleStr
    }
}
