//
//  UuidLoginResponse.swift
//  IosStudy
//
//  Created by mathmaster on 8/7/24.
//

import Foundation

struct UuidLoginResponse: Codable {
    var responseStatus: ResponseStatus
    var deviceId: Int
    var account: Account?
}
