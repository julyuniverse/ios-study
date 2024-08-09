//
//  Account.swift
//  IosStudy
//
//  Created by mathmaster on 8/7/24.
//

import Foundation

struct Account: Codable {
    var accountId: Int
    var email: String
    var firstName: String?
    var lastName: String?
    
    // 예) local storage에 저장할 때 사용
    func encode() -> Data? {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(self) {
            return encoded
        } else {
            return nil
        }
    }
    
    // 예) local storage에 저장할 된 것을 꺼내서 다시 디코딩 할 때 사용
    static func decode(data: Data) -> Account? {
        let decoder = JSONDecoder()
        if let decoded = try? decoder.decode(Account.self, from: data) {
            return decoded
        } else {
            return nil
        }
    }
}
