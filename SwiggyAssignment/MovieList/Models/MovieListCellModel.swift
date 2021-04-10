//
//  MovieListCellModel.swift
//  SwiggyAssignment
//
//  Created by Satyam on 08/04/21.
//

import Foundation

// To acheive some sort of abstarction  - SOLID principles refernce
struct MovieListCellModel {
    let imageUrl, title, id: String?
    
    init(with model: Search) {
        self.imageUrl = model.poster
        self.title = model.title
        self.id = model.imdbID
    }
}
