//
//  iCloudSyncManager.swift
//  Affirm
//
//  Manages iCloud sync for favorites and custom affirmations using NSUbiquitousKeyValueStore
//

import Foundation
import SwiftUI
import Observation

@Observable @MainActor class iCloudSyncManager {
    static let shared = iCloudSyncManager()
    private let store = NSUbiquitousKeyValueStore.default
    
    var lastSyncDate: Date?
    
    private init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(storeDidChange),
            name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: store
        )
        store.synchronize()
    }
    
    // MARK: - Favorites Sync
    
    func syncFavorites(_ favoriteIDs: [UUID]) {
        let strings = favoriteIDs.map { $0.uuidString }
        store.set(strings, forKey: "favorites")
        store.synchronize()
        lastSyncDate = Date()
    }
    
    func getFavorites() -> [UUID] {
        guard let strings = store.array(forKey: "favorites") as? [String] else {
            return []
        }
        return strings.compactMap { UUID(uuidString: $0) }
    }
    
    // MARK: - Custom Affirmations Sync
    
    func syncCustomAffirmations(_ affirmations: [[String: Any]]) {
        store.set(affirmations, forKey: "customAffirmations")
        store.synchronize()
        lastSyncDate = Date()
    }
    
    func getCustomAffirmations() -> [[String: Any]] {
        return store.array(forKey: "customAffirmations") as? [[String: Any]] ?? []
    }
    
    // MARK: - Change Notification
    
    @objc private func storeDidChange(_ notification: Notification) {
        DispatchQueue.main.async {
            self.lastSyncDate = Date()
            NotificationCenter.default.post(name: .iCloudDataChanged, object: nil)
        }
    }
}

extension Notification.Name {
    static let iCloudDataChanged = Notification.Name("iCloudDataChanged")
}
