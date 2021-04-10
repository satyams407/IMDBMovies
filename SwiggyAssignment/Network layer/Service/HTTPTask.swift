//
//  HTTPTask.swift
//  SwiggyAssignment
//
//  Created by Satyam Sehgal on 08/04/21.

import Foundation

public typealias HTTPHeaders = [String: String]

public enum HTTPTask {
    case request
    
    case requestParameters(bodyParamters: Parameters?, urlParameters: Parameters?)
    
    case requestParametersAndHeaders(bodyParamters: Parameters?, urlParameters: Parameters?, additionalHeaders: HTTPHeaders?)
}
