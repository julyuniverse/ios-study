//
//  LearnerView.swift
//  IosStudy
//
//  Created by July universe on 10/26/24.
//

import SwiftUI
import SwiftData

struct LearnerView: View {
    @Environment(\.modelContext) private var modelContext
    @Query var learners: [Learner]
    
    func createLearner() {
        // 새로운 Learner 생성
        let newLearner = Learner(studentID: UUID(), name: "한톨", appleDevices: [AppleDevice(deviceName: "iPhone")])
        // ModelContext에 새로운 데이터 추가 알림
        modelContext.insert(newLearner)
    }
    
    func updateLearner(to index: Int) {

        // 업데이트 할 Learner 데이터
        // 위에서 만든 @Query를 이용해 fetch해옴.
        let learner = learners[index]
        
        // 업데이트
        learner.name = "두톨"
    }
    
    func deleteLearner(to index: Int) {

        // 삭제 할 Learner 데이터
        // 위에서 만든 @Query를 이용해 fetch해옴.
        let learner = learners[index]
        
        // ModelContext를 이용한 삭제
        modelContext.delete(learner)
    }
    
    var body: some View {
        Button("추가") {
            createLearner()
        }
        
        List {
            ForEach(learners.indices, id: \.self) { index in
                HStack {
                    Text(learners[index].name)
                    Text("Index: \(index)") // 인덱스를 표시하기 위한 예시
                    Button("삭제") {
                        deleteLearner(to: index)
                    }
                }
            }
        }
    }
}
