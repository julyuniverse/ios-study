//
//  HomeView.swift
//  IosStudy
//
//  Created by mathmaster on 8/7/24.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var socialLoginViewModel: SocialLoginViewModel
    
    var body: some View {
        VStack {
            Text("HomeView")
            Button("getPosts") {
                Task {
                    await socialLoginViewModel.getPosts()
                }
            }
            ForEach(socialLoginViewModel.posts, id: \.postId) { post in
                Text("titile: \(post.title)")
                Text("content: \(post.content)")
            }
            Button("logout") {
                Task {
                    await socialLoginViewModel.logout()
                }
            }
        }
        .alert(isPresented: $socialLoginViewModel.hasError, error: socialLoginViewModel.error) {}
    }
}

#Preview {
    HomeView(socialLoginViewModel: SocialLoginViewModel())
}
