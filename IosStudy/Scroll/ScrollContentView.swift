//
//  ScrollContentView.swift
//  IosStudy
//
//  Created by July universe on 9/20/24.
//

import SwiftUI

struct ScrollContentView: View {
    @State private var items: [Int] = Array(1...50) // 데이터 소스
    @State private var lastOffset: CGFloat = 0.0
    @State private var isScrolled: Bool = false // 스크롤 여부 추적

    var body: some View {
        VStack(spacing: 0) {
            // 상단 고정 헤더
            HeaderView(showLine: isScrolled)
                .frame(height: 60)
                .background(Color.blue)

            // 스크롤 가능한 본문
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(items, id: \.self) { index in
                        Text("아이템 \(index)")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                    }
                }
                .padding()
            }
            .onScrollPhaseChange { oldPhase, newPhase, context in
                let currentOffset = context.geometry.contentOffset
                switch newPhase {
                case .idle, .tracking:
                    break
                case .interacting, .decelerating, .animating:
                    if context.geometry.contentOffset.y - lastOffset < 0.0 {
                        isScrolled = true
                    } else {
                        isScrolled = false
                    }
                }
                lastOffset = currentOffset.y
            }
            .refreshable {
                await refreshContent()
            }
        }
    }
    
    // 비동기 새로고침 함수
    func refreshContent() async {
        // 새로고침 로직을 여기에 추가하세요.
        // 예를 들어, 데이터를 다시 로드하거나 업데이트합니다.
        // 여기서는 1초 지연 후 아이템 목록을 업데이트하는 예제를 보여드립니다.
        do {
            try await Task.sleep(nanoseconds: 1_000_000_000) // 1초 대기
            items = Array(1...50).shuffled() // 아이템 목록 셔플
        } catch {
            print("새로고침 중 오류 발생: \(error)")
        }
    }
}

struct HeaderView: View {
    var showLine: Bool // 라인 표시 여부

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("고정된 헤더")
                    .foregroundColor(.white)
                    .font(.headline)
                Spacer()
            }
            .padding()

            // 하단 라인
            Rectangle()
                .fill(Color.gray)
                .frame(height: 1)
                .opacity(showLine ? 1 : 0) // 스크롤 위치에 따라 표시 여부 결정
        }
    }
}

#Preview {
    ScrollContentView()
}
