//
//  AppleDevice.swift
//  IosStudy
//
//  Created by July universe on 10/26/24.
//

import Foundation
import SwiftData

@Model
class AppleDevice {
    var deviceName: String
    @Transient var isActive = false
    
    init(deviceName: String) {
        self.deviceName = deviceName
    }
}
