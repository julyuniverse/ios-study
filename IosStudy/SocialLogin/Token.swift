//
//  Token.swift
//  IosStudy
//
//  Created by mathmaster on 8/7/24.
//

import Foundation

struct Token: Codable {
    var accessToken: String = ""
    var refreshToken: String = ""
    
    func encode() -> Data? {
        let encoder = JSONEncoder()
        
        // struct를 Data 타입으로 인코딩, 반환값은 @AppStorage에 저장되는 값
        if let encoded = try? encoder.encode(self) {
            return encoded
        } else {
            return nil
        }
    }
    
    // @AppStorage에서 Data 타입의 값을 struct로 변환
    static func decode(data: Data) -> Token? {
        let decoder = JSONDecoder()
        if let token = try? decoder.decode(Token.self, from: data) {
            return token
        } else {
            return nil
        }
    }
}
