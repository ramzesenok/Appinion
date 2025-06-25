//
//  DataService.swift
//  Appinion
//
//  Created by Roman Mirzoyan on 23.06.25.
//

import Foundation
import SwiftData

@MainActor
class DataService: ObservableObject {
    private var modelContainer: ModelContainer
    private var modelContext: ModelContext
    
    init() {
        do {
            modelContainer = try ModelContainer(for: AppStoreApp.self)
            modelContext = modelContainer.mainContext
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
    
    func saveApp(_ appData: AppStoreAppData) {
        // Check if app already exists
        let fetchDescriptor = FetchDescriptor<AppStoreApp>(
            predicate: #Predicate<AppStoreApp> { app in
                app.id == appData.id
            }
        )
        
        do {
            let existingApps = try modelContext.fetch(fetchDescriptor)
            
            if let existingApp = existingApps.first {
                // Update last searched date and icon URL if available
                existingApp.lastSearched = Date()
                if let iconURL = appData.iconURL {
                    existingApp.iconURL = iconURL
                }
            } else {
                // Create new app
                let newApp = AppStoreApp(
                    id: appData.id,
                    name: appData.name,
                    bundleId: appData.bundleId,
                    iconURL: appData.iconURL
                )
                modelContext.insert(newApp)
            }
            
            try modelContext.save()
        } catch {
            print("Failed to save app: \(error)")
        }
    }
    
    func updateAppSummary(appId: String, summary: String) {
        let fetchDescriptor = FetchDescriptor<AppStoreApp>(
            predicate: #Predicate<AppStoreApp> { app in
                app.id == appId
            }
        )
        
        do {
            let apps = try modelContext.fetch(fetchDescriptor)
            
            if let app = apps.first {
                app.reviewSummary = summary
                app.summaryGeneratedDate = Date()
                try modelContext.save()
            }
        } catch {
            print("Failed to update app summary: \(error)")
        }
    }
    
    func getRecentApps(limit: Int = 10) -> [AppStoreApp] {
        var fetchDescriptor = FetchDescriptor<AppStoreApp>(
            sortBy: [SortDescriptor(\.lastSearched, order: .reverse)]
        )
        fetchDescriptor.fetchLimit = limit
        
        do {
            return try modelContext.fetch(fetchDescriptor)
        } catch {
            print("Failed to fetch recent apps: \(error)")
            return []
        }
    }
    
    func getApp(by id: String) -> AppStoreApp? {
        let fetchDescriptor = FetchDescriptor<AppStoreApp>(
            predicate: #Predicate<AppStoreApp> { app in
                app.id == id
            }
        )
        
        do {
            let apps = try modelContext.fetch(fetchDescriptor)
            return apps.first
        } catch {
            print("Failed to fetch app: \(error)")
            return nil
        }
    }
    
    func deleteApp(_ app: AppStoreApp) {
        modelContext.delete(app)
        
        do {
            try modelContext.save()
        } catch {
            print("Failed to delete app: \(error)")
        }
    }
    
    func clearAllData() {
        do {
            try modelContext.delete(model: AppStoreApp.self)
            try modelContext.save()
        } catch {
            print("Failed to clear all data: \(error)")
        }
    }
}
