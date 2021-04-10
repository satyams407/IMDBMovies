//
//  AppError.swift
//  SwiggyAssignment
//
//  Created by Satyam Sehgal on 08/04/21.

import Foundation

enum APIServiceError: Error {
    case networkError
    case fetchError
    case decodeError
    
    var errorMessage: String {
        switch self {
        case .networkError: return "Something went wrong!"
        case .fetchError: return "Unable to Fetch!"
        case .decodeError: return "Unable to decode the response"
        }
    }
}
