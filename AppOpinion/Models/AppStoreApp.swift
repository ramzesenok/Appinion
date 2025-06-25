//
//  AppStoreApp.swift
//  Appinion
//
//  Created by Roman Mirzoyan on 23.06.25.
//

import Foundation
import SwiftData

@Model
class AppStoreApp {
    @Attribute(.unique) var id: String
    var name: String
    var bundleId: String
    var iconURL: String?
    var lastSearched: Date
    var reviewSummary: String?
    var summaryGeneratedDate: Date?
    
    init(id: String, name: String, bundleId: String, iconURL: String? = nil) {
        self.id = id
        self.name = name
        self.bundleId = bundleId
        self.iconURL = iconURL
        self.lastSearched = Date()
    }
}

// Simple data transfer object for app search results
struct AppStoreAppData: Codable {
    let id: String
    let name: String
    let bundleId: String
    let iconURL: String?
    
    init(id: String, name: String, bundleId: String, iconURL: String? = nil) {
        self.id = id
        self.name = name
        self.bundleId = bundleId
        self.iconURL = iconURL
    }
}
