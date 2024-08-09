//
//  ErrorResponse.swift
//  IosStudy
//
//  Created by mathmaster on 8/7/24.
//

import Foundation

struct ErrorResponse: Codable {
    let timestamp: String
    let status: Int
    let error: String
    let message: String
    let code: String
}
