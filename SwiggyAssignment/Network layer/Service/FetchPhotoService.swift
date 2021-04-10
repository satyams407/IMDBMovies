//
//  FetchPhotoService.swift
//  SwiggyAssignment
//
//  Created by Satyam Sehgal on 08/04/21.

import Foundation

struct FetchMovieService: FetchMovieServiceProtocol {
    
    func fetchMovie(with endPoint: FetchEndPoint, completionHandler: @escaping (Result<MovieResponseModel, APIServiceError>) -> Void) {
        NetworkRequest.sharedInstance.executeRequest(buildRequest(endPoint: endPoint)) { result in
            switch result {
            case.failure(let apiError) :
                completionHandler(.failure(apiError))
            case .success(let data):
                if let movieResponseModel = try? JSONDecoder().decode(MovieResponseModel.self, from: data) {
                    completionHandler(.success(movieResponseModel))
                } else {
                    completionHandler(.failure(.decodeError))
                }
            }
        }
    }
}
