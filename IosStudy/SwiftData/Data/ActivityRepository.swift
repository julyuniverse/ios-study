//
//  ActivityRepository.swift
//  IosStudy
//
//  Created by mathmaster on 11/4/24.
//

import Foundation
import SwiftUI
import SwiftData

class ActivityRepository {
    @Environment(\.modelContext) private var modelContext: ModelContext
    
    func fetchAllActivities() -> [Activity] {
        do {
            return try modelContext.fetch(FetchDescriptor<Activity>())
        } catch {
            return []
        }
    }
}
