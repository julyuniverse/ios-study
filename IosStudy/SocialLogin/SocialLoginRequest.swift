//
//  SocialLoginRequest.swift
//  IosStudy
//
//  Created by mathmaster on 8/7/24.
//

import Foundation

struct SocialLoginRequest: Codable {
    var idToken: String
    var firstName: String?
    var lastName: String?
}
