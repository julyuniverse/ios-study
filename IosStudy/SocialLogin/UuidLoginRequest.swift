//
//  UuidLoginRequest.swift
//  IosStudy
//
//  Created by mathmaster on 8/7/24.
//

import Foundation

struct UuidLoginRequest: Codable {
    var deviceUuid: String
    var deviceModel: String
    var systemName: String
    var systemVersion: String
}
