//
//  FetchPhotoServiceProtocol.swift
//  SwiggyAssignment
//
//  Created by Satyam Sehgal on 08/04/21.

import Foundation

protocol FetchMovieServiceProtocol {
    func fetchMovie(with endPoint: FetchEndPoint, completionHandler: @escaping (Result<MovieResponseModel, APIServiceError>) -> Void)
}

extension FetchMovieServiceProtocol {
    func buildRequest(endPoint: FetchEndPoint) -> URLRequest {
        var request = URLRequest(url: endPoint.baseURL, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 15)
        request.httpMethod = endPoint.httpMethod.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        endPoint.encode(request: &request, urlParameters: endPoint.urlParameters)
        return request
    }
}
