//
//  FetchEndPointProtocol.swift
//  SwiggyAssignment
//
//  Created by Satyam Sehgal on 08/04/21.

import Foundation

protocol FetchEndPointProtocol {
    var baseURL: URL { get }
    var path: String { get }
    var httpMethod: HTTPMethod { get }
}
