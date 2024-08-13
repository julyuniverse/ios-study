//
//  SocialLoginViewModel.swift
//  IosStudy
//
//  Created by mathmaster on 8/7/24.
//

import Foundation
import AuthenticationServices
import CryptoKit

class SocialLoginViewModel: ObservableObject {
    let defaults = UserDefaults.standard
    @Published var hasError = false
    @Published private(set) var error: UuidLoginError?
    @Published var posts: [Post] = []
    
    @MainActor
    func loginWithUuid() async {
        do {
            // set request body
            guard let deviceInfo = DeviceInfoManager.shared.getDeviceInfo() else {
                throw UuidLoginError.DEVICE_INFO_NOT_FOUND
            }
            let uuidLoginRequest = UuidLoginRequest(deviceUuid: deviceInfo.uuid, deviceModel: deviceInfo.model, systemName: deviceInfo.systemName, systemVersion: deviceInfo.systemVersion)
            let (data, _) = try await NetworkManager.shared.request(to: .UUID_LOGIN(uuidLoginRequest: uuidLoginRequest))
            
            // Optional binding으로 data 안전하게 처리
            guard let data = data else {
                // data가 nil이면 로그인 만료로 간주하고 더 이상의 로직을 수행하지 않음
                return
            }
            let decodedData = try JSONDecoder().decode(UuidLoginResponse.self, from: data)
            print("data: \(decodedData)")
            
            // set local storage
            defaults.set(decodedData.deviceId, forKey: "deviceId")
            if (decodedData.responseStatus.code == "C0001") {
                defaults.set("loggedIn", forKey: "appState")
            } else {
                defaults.set("loggedOut", forKey: "appState")
            }
        } catch {
            self.hasError = true
            if let uuidLoginError = error as? UuidLoginError {
                self.error = uuidLoginError
            } else {
                self.error = .ERROR(error: error)
            }
        }
    }
    
    @MainActor
    func handleAuthorization(_ authResults: ASAuthorization) async {
        guard let appleIDCredential = authResults.credential as? ASAuthorizationAppleIDCredential else {
            print("Invalid state: the returned authorization is not an Apple ID credential.")
            return
        }
        print("appleIDCredential: ")
        debugPrint(appleIDCredential)
        
        guard let idTokenData = appleIDCredential.identityToken else {
            print("Failed to fetch identity token.")
            return
        }
        print("idTokenData: ")
        debugPrint(idTokenData)
        
        guard let idTokenString = String(data: idTokenData, encoding: .utf8) else {
            print("Failed to decode identity token.")
            return
        }
        print("idTokenString: ")
        debugPrint(idTokenString)
        
        guard let authorizationCodeData = appleIDCredential.authorizationCode else {
            print("Failed to fetch authorization code.")
            return
        }
        print("authorizationCodeData: ")
        debugPrint(authorizationCodeData)
        
        guard let authorizationCodeString = String(data: authorizationCodeData, encoding: .utf8) else {
            print("Failed to decode authorization code.")
            return
        }
        print("authorizationCodeString: ")
        debugPrint(authorizationCodeString)
        
        // Get full name
        let fullName = appleIDCredential.fullName
        print("fullName: ")
        debugPrint(fullName ?? "")
        let firstName = fullName?.givenName
        print("firstName: ")
        debugPrint(firstName ?? "")
        let lastName = fullName?.familyName
        print("lastName: ")
        debugPrint(lastName ?? "")
        
        do {
            // set request body
            let socialLoginRequest = SocialLoginRequest(idToken: idTokenString, firstName: firstName, lastName: lastName)
            let (data, _) = try await NetworkManager.shared.request(to: .SOCIAL_LOGIN(socialLoginRequest: socialLoginRequest))
            
            // Optional binding으로 data 안전하게 처리
            guard let data = data else {
                // data가 nil이면 로그인 만료로 간주하고 더 이상의 로직을 수행하지 않음
                return
            }
            let decodedData = try JSONDecoder().decode(SocialLoginResponse.self, from: data)
            print("data: \(decodedData)")
            
            // set local storage
            defaults.set(decodedData.token.accessToken, forKey: "accessToken")
            defaults.set(decodedData.token.refreshToken, forKey: "refreshToken")
            defaults.set("loggedIn", forKey: "appState")
        } catch {
            self.hasError = true
            if let uuidLoginError = error as? UuidLoginError {
                self.error = uuidLoginError
            } else {
                self.error = .ERROR(error: error)
            }
        }
    }
    
    @MainActor
    func logout() async {
        do {
            // request
            let (data, _) = try await NetworkManager.shared.request(to: .LOGOUT)
            
            // Optional binding으로 data 안전하게 처리
            guard let data = data else {
                // data가 nil이면 로그인 만료로 간주하고 더 이상의 로직을 수행하지 않음
                return
            }
            let decodedData = try JSONDecoder().decode(ResponseStatus.self, from: data)
            print("data: \(decodedData)")
            
            // set local storage
            defaults.set("", forKey: "accessToken")
            defaults.set("", forKey: "refreshToken")
            defaults.set("loggedOut", forKey: "appState")
        } catch {
            self.hasError = true
            if let uuidLoginError = error as? UuidLoginError {
                self.error = uuidLoginError
            } else {
                self.error = .ERROR(error: error)
            }
        }
    }
    
    @MainActor
    func getPosts() async {
        do {
            // request
            let (data, _) = try await NetworkManager.shared.request(to: .GET_POST)
            
            // Optional binding으로 data 안전하게 처리
            guard let data = data else {
                // data가 nil이면 로그인 만료로 간주하고 더 이상의 로직을 수행하지 않음
                return
            }
            let decodedData = try JSONDecoder().decode(Posts.self, from: data)
            print("data: \(decodedData)")
            self.posts = decodedData.posts
        } catch {
            self.hasError = true
            if let uuidLoginError = error as? UuidLoginError {
                self.error = uuidLoginError
            } else {
                self.error = .ERROR(error: error)
            }
        }
    }
    
    // Utility functions to generate nonce and hash
    func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0..<16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
}

extension SocialLoginViewModel {
    enum UuidLoginError: LocalizedError {
        case DEVICE_INFO_NOT_FOUND // 디바이스 정보를 찾을 수 없음.
        case ERROR(error: Error)
    }
}

extension SocialLoginViewModel.UuidLoginError {
    var errorDescription: String? {
        switch self {
        case .DEVICE_INFO_NOT_FOUND:
            return "Error: Device information not found."
        case .ERROR(let error):
            return error.localizedDescription
        }
    }
}
