//
//  NetworkManager.swift
//  IosStudy
//
//  Created by mathmaster on 8/7/24.
//

import Foundation

enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
}

enum ContentType {
    case JSON
    case MULTIPART_FORM_DATA(boundary: String)
    
    var headerValue: String {
        switch self {
        case .JSON:
            return "application/json"
        case .MULTIPART_FORM_DATA(let boundary):
            return "multipart/form-data; boundary=\(boundary)"
        }
    }
}

enum Endpoint {
    private static let boundary = "Boundary-\(Foundation.UUID().uuidString)"
    case UUID_LOGIN(uuidLoginRequest: UuidLoginRequest)
    case REISSUE_TOKEN
    case SOCIAL_LOGIN(socialLoginRequest: SocialLoginRequest)
    case LOGOUT
    case GET_POST
    case CREATE_POST(parameters: [String:Any], media: [Media]?)
    
    var baseURL: URL {
        return URL(string: "http://localhost:8080")!
    }
    
    var path: String {
        switch self {
        case .UUID_LOGIN:
            return "/api/auth/login/uuid"
        case .REISSUE_TOKEN:
            return "/api/auth/token/reissue"
        case .SOCIAL_LOGIN:
            return "/api/auth/login/social"
        case .LOGOUT:
            return "/api/auth/logout"
        case .GET_POST:
            return "/api/posts"
        case .CREATE_POST:
            return "/api/posts"
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .UUID_LOGIN,
                .REISSUE_TOKEN,
                .SOCIAL_LOGIN,
                .LOGOUT,
                .CREATE_POST:
            return .POST
        case .GET_POST:
            return .GET
        }
    }
    
    var contentType: ContentType {
        switch self {
        case .UUID_LOGIN,
                .REISSUE_TOKEN,
                .SOCIAL_LOGIN,
                .LOGOUT,
                .GET_POST:
            return .JSON
        case .CREATE_POST:
            return .MULTIPART_FORM_DATA(boundary: Endpoint.boundary)
        }
    }
    
    var body: Data? {
        switch self {
        case .UUID_LOGIN(let body):
            return try? JSONEncoder().encode(body)
        case .REISSUE_TOKEN:
            var body = [String: String]()
            if let refreshToken = UserDefaults.standard.refreshToken {
                body["refreshToken"] = refreshToken
            }
            return try? JSONEncoder().encode(body)
        case .SOCIAL_LOGIN(let body):
            return try? JSONEncoder().encode(body)
        case .LOGOUT,
                .GET_POST:
            return nil
        case .CREATE_POST(let parameters, let media):
            return createMultipartFormData(parameters: parameters, media: media, boundary: Endpoint.boundary)
        }
    }
    
    func createMultipartFormData(parameters: [String: Any], media: [Media]?, boundary: String) -> Data {
        var formData = Data()
        
        // 텍스트 파라미터 추가
        for (key, value) in parameters {
            formData.append("--\(boundary)\r\n".data(using: .utf8)!)
            formData.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            formData.append("\(value)\r\n".data(using: .utf8)!)
        }
        
        // 미디어(예: 이미지) 파라미터 추가
        media?.forEach { medium in
            formData.append("--\(boundary)\r\n".data(using: .utf8)!)
            formData.append("Content-Disposition: form-data; name=\"\(medium.key)\"; filename=\"\(medium.fileName)\"\r\n".data(using: .utf8)!)
            formData.append("Content-Type: \(medium.mimeType)\r\n\r\n".data(using: .utf8)!)
            formData.append(medium.data)
            formData.append("\r\n".data(using: .utf8)!)
        }
        
        // 마지막 boundary 추가
        formData.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        return formData
    }
}

struct Media {
    let key: String
    let fileName: String
    let data: Data
    let mimeType: String
}

class NetworkManager {
    static let shared = NetworkManager()
    private var isTokenReissuing = false // 토큰 재발행 하는 동안 들어온 요청 처리 방지 플래그
    private var waitingRequests: [(Endpoint, (Result<(Data?, URLResponse?), Error>) -> Void)] = []
    
    private init() {}
    
    private func prepareURLRequest(for endpoint: Endpoint) -> URLRequest {
        let url = endpoint.baseURL.appendingPathComponent(endpoint.path)
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.httpMethod.rawValue
        request.httpBody = endpoint.body
        request.addValue(endpoint.contentType.headerValue, forHTTPHeaderField: "Content-Type")
        addAuthorizationHeader(to: &request)
        
        return request
    }
    
    func request(to endpoint: Endpoint) async throws -> (Data?, URLResponse?) {
        let urlRequest = prepareURLRequest(for: endpoint)
        do {
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            guard let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode) else {
                let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
                if (errorResponse.code == ErrorCode.EXPIRED_TOKEN.rawValue) {
                    // 토큰 재발행
                    if !isTokenReissuing {
                        isTokenReissuing = true
                        do {
                            try await reissueToken()
                            
                            // 재발행 후 첫 번째 요청 다시 요청 시도
                            return try await request(to: endpoint)
                        } catch {
                            throw error
                        }
                    }
                    return try await withCheckedThrowingContinuation { continuation in
                        self.waitingRequests.append((endpoint, continuation.resume))
                    }
                } else {
                    if (errorResponse.code == ErrorCode.EXPIRED_TOKEN.rawValue || errorResponse.code == ErrorCode.INVALID_TOKEN_SIGNATURE.rawValue || errorResponse.code == ErrorCode.TOKEN_DECODING_FAILED.rawValue || errorResponse.code == ErrorCode.TOKEN_VERIFICATION_FAILED.rawValue || errorResponse.code == ErrorCode.TOKEN_NO_AUTHORITY.rawValue || errorResponse.code == ErrorCode.NOT_AN_ACCESS_TOKEN.rawValue || errorResponse.code == ErrorCode.NOT_A_REFRESH_TOKEN.rawValue || errorResponse.code == ErrorCode.NO_TOKEN_TYPE.rawValue || errorResponse.code == ErrorCode.NO_DEVICE_ID.rawValue || errorResponse.code == ErrorCode.ACCOUNT_LOGGED_OUT.rawValue || errorResponse.code == ErrorCode.NO_TOKEN_PROVIDED.rawValue || errorResponse.code == ErrorCode.TOKEN_MISMATCH.rawValue) {
                        throw NetworkError.UNAUTHORIZED
                    } else {
                        throw NetworkError.BAD_SERVER_RESPONSE
                    }
                }
            }
            return (data, response)
        } catch {
            switch error {
            case NetworkError.UNAUTHORIZED:
                AlertManager.shared.showTokenErrorAlert()
                return(nil, nil) // 메서드 로직 종료
            default:
                throw error
            }
        }
    }
    
    private func reissueToken() async throws {
        print("[reissueToken] proceed")
        let reissueTokenEndpoint = Endpoint.REISSUE_TOKEN
        let request = prepareURLRequest(for: reissueTokenEndpoint)
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            print("[reissueToken] request")
            guard let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode) else {
                let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
                if (errorResponse.code == ErrorCode.EXPIRED_TOKEN.rawValue || errorResponse.code == ErrorCode.INVALID_TOKEN_SIGNATURE.rawValue || errorResponse.code == ErrorCode.TOKEN_DECODING_FAILED.rawValue || errorResponse.code == ErrorCode.TOKEN_VERIFICATION_FAILED.rawValue || errorResponse.code == ErrorCode.TOKEN_NO_AUTHORITY.rawValue || errorResponse.code == ErrorCode.NOT_AN_ACCESS_TOKEN.rawValue || errorResponse.code == ErrorCode.NOT_A_REFRESH_TOKEN.rawValue || errorResponse.code == ErrorCode.NO_TOKEN_TYPE.rawValue || errorResponse.code == ErrorCode.NO_DEVICE_ID.rawValue || errorResponse.code == ErrorCode.ACCOUNT_LOGGED_OUT.rawValue || errorResponse.code == ErrorCode.NO_TOKEN_PROVIDED.rawValue || errorResponse.code == ErrorCode.TOKEN_MISMATCH.rawValue) {
                    throw NetworkError.UNAUTHORIZED
                } else {
                    throw NetworkError.BAD_SERVER_RESPONSE
                }
            }
            let token = try JSONDecoder().decode(Token.self, from: data)
            UserDefaults.standard.accessToken = token.accessToken // 추출한 토큰 저장
            UserDefaults.standard.refreshToken = token.refreshToken // 추출한 토큰 저장
            isTokenReissuing = false
            retryWaitingRequests()
            print("[reissueToken] Success.")
        } catch {
            print("[reissueToken] Failure.")
            cancelWaitingRequests(with: error)
            throw error
        }
    }
    
    // 재시도 대기 요청들
    private func retryWaitingRequests() {
        print("[retryWaitingRequests] proceed")
        let requests = waitingRequests
        waitingRequests = []
        for (endpoint, continuation) in requests {
            print("[retryWaitingRequests] loop proceed")
            Task {
                do {
                    let result = try await request(to: endpoint)
                    continuation(.success(result))
                } catch {
                    continuation(.failure(error))
                }
            }
        }
    }
    
    // 재시도 대기 요청들 모두 요청 취소
    private func cancelWaitingRequests(with error: Error) {
        print("[cancelWaitingRequests] proceed")
        let requests = waitingRequests
        waitingRequests = []
        for (_, continuation) in requests {
            continuation(.failure(error))
        }
        isTokenReissuing = false
    }
    
    private func addAuthorizationHeader(to request: inout URLRequest) {
        request.setValue("iOS", forHTTPHeaderField: "Platform")
        request.setValue(UserDefaults.standard.string(forKey: "deviceId"), forHTTPHeaderField: "Device-Id")
        if let accessToken = UserDefaults.standard.accessToken {
            request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }
    }
}

extension NetworkManager {
    enum NetworkError: LocalizedError {
        case BAD_SERVER_RESPONSE
        case UNAUTHORIZED
        case ERROR(error: Error)
    }
}

extension NetworkManager.NetworkError {
    var errorDescription: String? {
        switch self {
        case .BAD_SERVER_RESPONSE:
            return "Bad server response."
        case .UNAUTHORIZED:
            return nil
        case .ERROR(let error):
            return "\(error.localizedDescription)"
        }
    }
}

extension UserDefaults {
    private enum Keys {
        static let accessToken = "accessToken"
        static let refreshToken = "refreshToken"
    }
    
    var accessToken: String? {
        get { string(forKey: Keys.accessToken) }
        set { set(newValue, forKey: Keys.accessToken) }
    }
    
    var refreshToken: String? {
        get { string(forKey: Keys.refreshToken) }
        set { set(newValue, forKey: Keys.refreshToken) }
    }
}
