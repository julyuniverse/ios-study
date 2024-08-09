//
//  SocialLoginResponse.swift
//  IosStudy
//
//  Created by mathmaster on 8/8/24.
//

import Foundation

struct SocialLoginResponse: Codable {
    var responseStatus: ResponseStatus
    var account: Account
    var token: Token
}
