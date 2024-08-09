//
//  AlertManager.swift
//  IosStudy
//
//  Created by mathmaster on 8/9/24.
//

import Foundation

/// 설정된 구간에 따라 알림 창 출력을 할 수 있는 클래스입니다.
class AlertManager: ObservableObject {
    static let shared = AlertManager()
    @Published var showAlert: Bool = false
    @Published var alertTitle: String?
    @Published var alertMessage: String?
    
    private init() {}
    
    func showTokenErrorAlert() {
        DispatchQueue.main.async {
            self.alertTitle = NSLocalizedString("authenticationExpiration", comment: "")
            self.alertMessage = NSLocalizedString("authenticationExpirationNotification", comment: "")
            self.showAlert = true
        }
    }
}
