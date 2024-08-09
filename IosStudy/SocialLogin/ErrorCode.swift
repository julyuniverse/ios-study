//
//  ErrorCode.swift
//  IosStudy
//
//  Created by mathmaster on 8/7/24.
//

import Foundation

enum ErrorCode: String {
    case FAILED
    case EXPIRED_TOKEN
    case INVALID_TOKEN_SIGNATURE
    case TOKEN_DECODING_FAILED
    case TOKEN_VERIFICATION_FAILED
    case TOKEN_NO_AUTHORITY
    case NOT_AN_ACCESS_TOKEN
    case NOT_A_REFRESH_TOKEN
    case NO_TOKEN_TYPE
    case NO_DEVICE_ID
    case ACCOUNT_LOGGED_OUT
    case NO_TOKEN_PROVIDED
    case TOKEN_MISMATCH
}
