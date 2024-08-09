//
//  SocialLoginContentView.swift
//  IosStudy
//
//  Created by mathmaster on 8/8/24.
//

import SwiftUI

struct SocialLoginContentView: View {
    /// 앱의 전반적인 상태를 나타내는 프로퍼티입니다.
    /// 초기값은 "checking"으로 설정되며, 서버와의 통신 후
    /// "loggedIn" 또는 "loggedOut"으로 변경됩니다.
    ///
    /// - Possible Values:
    ///   - "checking": 서버와 통신하여 상태를 확인 중.
    ///   - "loggedIn": 사용자가 로그인된 상태.
    ///   - "loggedOut": 사용자가 로그인되지 않은 상태.
    @AppStorage("appState") var appState: String = UserDefaults.standard.string(forKey: "appState") ?? "checking"
    @StateObject var socialLoginViewModel: SocialLoginViewModel
    @StateObject private var alertManager = AlertManager.shared
    
    init() {
        UserDefaults.standard.set("checking", forKey: "appState")
        _socialLoginViewModel = StateObject(wrappedValue: SocialLoginViewModel())
    }
    
    var body: some View {
        VStack {
            if (appState == "checking") {
                ProgressView()
            } else if (appState == "loggedIn") {
                HomeView(socialLoginViewModel: socialLoginViewModel)
            } else if (appState == "loggedOut") {
                SocialLoginView(socialLoginViewModel: socialLoginViewModel)
            }
        }
        .onAppear {
            Task {
                await socialLoginViewModel.loginWithUuid()
            }
        }
        .alert(isPresented: $alertManager.showAlert) {
            return Alert(
                title: Text(alertManager.alertTitle ?? "Notification"),
                message: Text(alertManager.alertMessage ?? ""),
                dismissButton: .default(Text("confirmation")) {
                    appState = "loggedOut"
                }
            )
        }
    }
}

#Preview {
    SocialLoginContentView()
}
