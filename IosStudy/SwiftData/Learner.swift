//
//  Learner.swift
//  IosStudy
//
//  Created by July universe on 10/26/24.
//

import Foundation
import SwiftData // 1. SwiftData 받아오기

@Model // 2. 매크로 추가
class Learner {
    @Attribute(.unique) var studentID: UUID
    var name: String
    @Relationship(deleteRule: .cascade) var appleDevices: [AppleDevice]
    
    init(studentID: UUID, name: String, appleDevices: [AppleDevice]) {
        self.studentID = studentID
        self.name = name
        self.appleDevices = appleDevices
    }
}
