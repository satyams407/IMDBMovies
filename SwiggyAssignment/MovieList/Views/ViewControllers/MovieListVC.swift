//
//  MovieListVC.swift
//  SwiggyAssignment
//
//  Created by Satyam on 08/04/21.
//

import UIKit

class MovieListVC: UIViewController {
    
    // MARK: - IBOutelts
    @IBOutlet weak var mainCollectionView: UICollectionView! 
    @IBOutlet weak var movieSearchBar: UISearchBar! {
        didSet {
            movieSearchBar.delegate = self
        }
    }
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var retryButtton: UIButton! {
        didSet {
            retryButtton.isHidden = true
        }
    }
    @IBOutlet weak var footerActivityIndicator: UIActivityIndicatorView! {
        didSet {
            footerActivityIndicator.isHidden = true
        }
    }
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Properties
    let viewModel = MovieListViewModel()
    var debounceTimer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.fetchMoviesData()
        screenSetup()
        bindUIElements()
    }
    
    private func screenSetup() {
        title = StringConstants.navTitle
        registerCells()
        configureSearchBar()
    }
    
    private func configureSearchBar() {
        movieSearchBar.placeholder = StringConstants.searchBarPlaceHolder
        movieSearchBar.showsCancelButton = true
    }
        
    private func registerCells() {
        let identifier = AppConstants.CellIdentifiers.movieCollectionCell.rawValue
        mainCollectionView.register(UINib(nibName: identifier, bundle: nil), forCellWithReuseIdentifier: identifier)
    }
    
    private func bindUIElements() {
        viewModel.responseModel.bind({ [weak self] model in
            guard model != nil else { return }
            self?.viewModel.setUpDataSource()
            self?.retryButtton.isHidden = self?.viewModel.toShowRetryButton() == false
            self?.mainCollectionView.reloadData()
        })
        
        viewModel.isFetching.bind({ [weak self] value in
            if value == true {
                self?.activityIndicator.isHidden = false
                self?.activityIndicator.startAnimating()
            } else {
                self?.activityIndicator.isHidden = true
                self?.activityIndicator.stopAnimating()
                self?.footerActivityIndicator.isHidden = true
                self?.footerActivityIndicator.stopAnimating()
            }
        })
    }

    // MARK: - Button Actions
    @IBAction func didTapOnRetryButton(_ sender: UIButton) {
        viewModel.isFetching.value = true
        viewModel.fetchMoviesData()
    }

    @IBAction func segmentControlAction(_ sender: UISegmentedControl) {
        viewModel.viewType = sender.selectedSegmentIndex == 0 ? .list : .grid
        mainCollectionView.reloadData()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offSetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if offSetY > contentHeight - scrollView.frame.height*2 {
            if viewModel.isFetching.value == false {
                footerActivityIndicator.isHidden = false
                footerActivityIndicator.startAnimating()
                viewModel.pageNumber = viewModel.pageNumber + 1
                viewModel.fetchMoviesData()
            }
        }
    }
    
    // TODO - Deeplink proper handling with IMDB id
    func navigateToMovieDetail(from model: MovieListCellModel) {
        let storyboard = UIStoryboard(name: AppConstants.StoryBoards.main.rawValue, bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: AppConstants.ViewControllerIdentifiers.moviewDetail.rawValue) as? MovieDetailViewController {
            vc.imageStringURl = model.imageUrl
            vc.titleStr = model.title
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

// MARK: - UICollection View DataSource and delgates methods
extension MovieListVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.getNumberOfRows
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let collectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: AppConstants.CellIdentifiers.movieCollectionCell.rawValue, for: indexPath)
        if let row = viewModel.getRowDetails(for: indexPath.row) {
            switch row {
            case .movieCell(let model):
                if let cell = collectionCell as? MovieCollectionCell {
                    cell.indexPath = indexPath
                    cell.configure(with: model)
                }
            }
        }
        return collectionCell
    }
        
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availbleWidth = CGFloat(collectionView.frame.width - 30)
        let numbersOfItem = viewModel.viewType.numberOfItemsInRow()
        return CGSize.init(width: availbleWidth/CGFloat(numbersOfItem), height: 200)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let row = viewModel.getRowDetails(for: indexPath.row) {
            switch row {
            case .movieCell(let model):
                navigateToMovieDetail(from: model)
            }
        }
    }
}

// MARK: - SearchBar Delegate Methods
extension MovieListVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let text = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if text.count > 2 {
            if let timer = debounceTimer {
                timer.invalidate()    // when search button is tapped multiple times
            }
            // start the timer
            debounceTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateSearchResult(_:)), userInfo: text, repeats: false)
        }
    }
    
    @objc func updateSearchResult(_ timer: Timer) {
        if let searchText = timer.userInfo as? String {
            viewModel.dataSource.removeAll()
            viewModel.searchText = searchText
            viewModel.isFetching.value = true
            viewModel.fetchMoviesData()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.endEditing(true)
        scrollToTop()
    }
    
    func scrollToTop() {
        UIView.animate(withDuration: 0.3, animations: {
        }, completion: { (_) in
            self.mainCollectionView.contentOffset = CGPoint.init(x: 0, y: 0)
        })
    }
}
