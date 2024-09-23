//
//  DeviceInfoManager.swift
//  IosStudy
//
//  Created by mathmaster on 8/7/24.
//

import Foundation
import Security
import UIKit

@MainActor
final class DeviceInfoManager {
    static let shared = DeviceInfoManager()
    private let keychainServiceName = "com.benection.IosStudy"
    private let keychainDeviceUUIDKey = "deviceUUID"
    
    private init() {}
    
    func getDeviceInfo() -> DeviceInfo? {
        guard let deviceUUID = getDeviceUUID() else {
            return nil
        }
        let deviceModel = UIDevice.current.model
        let systemName = UIDevice.current.systemName
        let systemVersion = UIDevice.current.systemVersion
        
        return DeviceInfo(uuid: deviceUUID, model: deviceModel, systemName: systemName, systemVersion: systemVersion)
    }
    
    private func getDeviceUUID() -> String? {
        if let existingUUID = readDeviceUUIDFromKeychain() {
            return existingUUID
        }
        guard let newUUID = generateDeviceUUID() else {
            return nil
        }
        saveDeviceUUIDToKeychain(uuid: newUUID)
        
        return newUUID
    }
    
    private func readDeviceUUIDFromKeychain() -> String? {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: keychainServiceName,
            kSecAttrAccount: keychainDeviceUUIDKey,
            kSecReturnData: true
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        if status == errSecSuccess, let data = result as? Data, let uuid = String(data: data, encoding: .utf8) {
            return uuid
        }
        
        return nil
    }
    
    private func saveDeviceUUIDToKeychain(uuid: String) {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: keychainServiceName,
            kSecAttrAccount: keychainDeviceUUIDKey,
            kSecValueData: uuid.data(using: .utf8)!
        ]
        SecItemDelete(query as CFDictionary) // Delete any existing item with the same key
        let status = SecItemAdd(query as CFDictionary, nil)
        if status != errSecSuccess {
            print("Failed to save device UUID to Keychain: \(status)")
        }
    }
    
    private func generateDeviceUUID() -> String? {
        if let uuid = UIDevice.current.identifierForVendor?.uuidString {
            return uuid
        }
        
        return nil
    }
}

struct DeviceInfo {
    let uuid: String
    let model: String
    let systemName: String
    let systemVersion: String
}
