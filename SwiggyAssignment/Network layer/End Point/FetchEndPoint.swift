//
//  FetchEndPoint.swift
//  SwiggyAssignment
//
//  Created by Satyam Sehgal on 08/04/21.

import Foundation


// Can have mutilple cases for fetch request for different api calls
enum FetchEndPoint {
    case fetchMovie(searchText: String, pageNumber: Int)
}

extension FetchEndPoint: FetchEndPointProtocol {
    var path: String {
        return "/services/rest/"
    }
    
    var baseURL: URL {
        guard let url = URL(string: AppURLConstants.basefetchURL) else {
            fatalError("url can't be made right now")
        }
        return url
    }
    
    var httpMethod: HTTPMethod {
        return .get
    }

    // http://www.omdbapi.com/?apikey=1c1df4a4&s=krissh&page=1
    // http://www.omdbapi.com/?i=tt3896198&apikey=1c1df4a4
    var urlParameters: Parameters {
        switch self {
        case .fetchMovie(let searchText, let pageNumber):
            return [
                KeyConstants.FetchMovies.apikey.rawValue: "1c1df4a4",
                KeyConstants.FetchMovies.page.rawValue: pageNumber,
                KeyConstants.FetchMovies.searchText.rawValue: searchText
            ]
        }
    }
    
    func encode(request: inout URLRequest, urlParameters: Parameters?) {
        guard let urlParameters = urlParameters, let url = request.url  else { return }
        if var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) {
            urlComponents.queryItems = [URLQueryItem]()
            for (key, value) in urlParameters {
                let queryItem = URLQueryItem(name: key,
                                             value: "\(value)".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed))
                urlComponents.queryItems?.append(queryItem)
            }
            request.url = urlComponents.url
        }
    }
}
