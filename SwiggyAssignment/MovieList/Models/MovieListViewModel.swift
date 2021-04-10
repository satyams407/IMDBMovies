//
//  MovieListViewModel.swift
//  SwiggyAssignment
//
//  Created by Satyam on 08/04/21.
//

import Foundation

class MovieListViewModel {
    enum Row: Equatable {
        case movieCell(MovieListCellModel)
        
        static func == (lhs: MovieListViewModel.Row, rhs: MovieListViewModel.Row) -> Bool {
            switch (lhs, rhs) {
            case (movieCell(let item1), movieCell(let item2)):
                return item1.id == item2.id
            }
        }
    }
    
    // MARK: - Properties
    var dataSource = [Row]()
    var responseModel = Binding<MovieResponseModel?>.init(value: nil)
    var isFetching = Binding<Bool?>.init(value: nil)
    var searchText = StringConstants.defaultSearchKeyword
    var pageNumber = 1
    
    enum ViewType {
        case list
        case grid
        
        func numberOfItemsInRow() -> Int {
            switch self {
            case .list: return 1
            case .grid: return 3
            }
        }
    }
    var viewType: ViewType = .list
        
    var getNumberOfRows: Int { return dataSource.count }
    
    func getRowDetails(for row: Int) -> Row? {
        if row < dataSource.count {
            return dataSource[row]
        }
        return nil
    }
    
    func setUpDataSource() { addRows() }
    
    private func addRows() {
        responseModel.value?.search?.forEach({ movie in
            let cellModel = MovieListCellModel.init(with: movie)
            dataSource.append(.movieCell(cellModel))
        })
    }
    
    func toShowRetryButton() -> Bool { return dataSource.count == 0 }
    
    // MARK: - API Request
    func fetchMoviesData() {
        self.isFetching.value = true
        FetchMovieService().fetchMovie(with: .fetchMovie(searchText: searchText, pageNumber: pageNumber), completionHandler: { [weak self] (result) in
            self?.isFetching.value = false
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                //can be used further as per UI req.
               // Utility.showAlert(message: error.errorMessage, onController: )
                debugPrint(error.errorMessage)
                self.responseModel.value = nil
            case .success(let movieModel):
                self.responseModel.value = movieModel
            }
        })
    }
}
