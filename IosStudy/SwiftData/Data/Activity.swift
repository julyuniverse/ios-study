//
//  Activity.swift
//  IosStudy
//
//  Created by mathmaster on 11/4/24.
//

import Foundation
import SwiftData

@Model
final class Activity {
    @Attribute(.unique) var id: UUID
    var title: String
    var desc: String
    var date: Date
    
    init(id: UUID = UUID(), title: String, desc: String, date: Date = Date()) {
        self.id = id
        self.title = title
        self.desc = desc
        self.date = date
    }
}
