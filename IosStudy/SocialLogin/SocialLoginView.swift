//
//  SocialLoginView.swift
//  IosStudy
//
//  Created by mathmaster on 8/7/24.
//

import SwiftUI
import AuthenticationServices

struct SocialLoginView: View {
    @ObservedObject var socialLoginViewModel: SocialLoginViewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var currentNonce: String?
    
    var body: some View {
        SignInWithAppleButton(
            .signIn,
            onRequest: { request in
                let nonce = socialLoginViewModel.randomNonceString()
                currentNonce = nonce
                request.requestedScopes = [.email, .fullName]
                request.nonce = socialLoginViewModel.sha256(nonce)
            },
            onCompletion: { result in
                switch result {
                case .success(let authResults):
                    Task {
                        await socialLoginViewModel.handleAuthorization(authResults)
                    }
                case .failure(let error):
                    print("Authorization failed: \(error.localizedDescription)")
                }
            }
        )
        .signInWithAppleButtonStyle(
            colorScheme == .dark ? .white : .black
        )
        .frame(width: 280, height: 45)
        .alert(isPresented: $socialLoginViewModel.hasError, error: socialLoginViewModel.error) {}
    }
}

#Preview {
    SocialLoginView(socialLoginViewModel: SocialLoginViewModel())
}
