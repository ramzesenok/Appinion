//
//  MainViewModel.swift
//  Appinion
//
//  Created by Roman Mirzoyan on 23.06.25.
//

import Foundation
import SwiftUI

@MainActor
class MainViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var searchResults: [AppStoreAppData] = []
    @Published var recentApps: [AppStoreApp] = []
    @Published var isSearching = false
    @Published var errorMessage: String?
    @Published var selectedApp: AppStoreApp?
    
    private let iTunesService = iTunesSearchService()
    private let rssService = iTunesRSSService()
    private let openAIService = OpenAIService()
    private let dataService = DataService()
    
    private var searchTask: Task<Void, Never>?
    
    init() {
        loadRecentApps()
    }
    
    // MARK: - Search Functionality
    func onSearchTextChanged() {
        // Cancel previous search
        searchTask?.cancel()
        
        // Clear results if search is empty
        if searchText.isEmpty {
            searchResults = []
            return
        }
        
        // Debounce search with 500ms delay
        searchTask = Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 500ms
            
            guard !Task.isCancelled else { return }
            
            await performSearch()
        }
    }
    
    private func performSearch() async {
        guard !searchText.isEmpty else { return }
        
        isSearching = true
        errorMessage = nil
        
        do {
            // Use iTunes Search API for public app search
            let iTunesResults = try await iTunesService.searchApps(query: searchText)
            // Convert iTunes results to our expected format
            searchResults = iTunesResults.map { iTunesApp in
                AppStoreAppData(
                    id: String(iTunesApp.trackId),
                    name: iTunesApp.trackName,
                    bundleId: iTunesApp.bundleId,
                    iconURL: iTunesApp.artworkUrl512 ?? iTunesApp.artworkUrl100
                )
            }
        } catch {
            errorMessage = error.localizedDescription
            searchResults = []
        }
        
        isSearching = false
    }
    
    // MARK: - App Selection
    func selectApp(_ appData: AppStoreAppData) {
        // Save/update app in data service
        dataService.saveApp(appData)
        
        // Get the saved app from data service
        if let savedApp = dataService.getApp(by: appData.id) {
            selectedApp = savedApp
            loadRecentApps() // Refresh recent apps
        }
    }
    
    func selectRecentApp(_ app: AppStoreApp) {
        selectedApp = app
        // Update last searched date - this will be handled by the data service
        app.lastSearched = Date()
        loadRecentApps()
    }
    
    // MARK: - Summary Generation
    func generateSummary(for app: AppStoreApp) async {
        do {
            // Fetch reviews using iTunes RSS (works for all public apps)
            let reviews = try await rssService.fetchReviews(for: app.id)
            print("✅ Used iTunes RSS for reviews")
            
            let summary = try await openAIService.summarizeReviews(reviews, for: app.name)
            
            dataService.updateAppSummary(appId: app.id, summary: summary)
            
            // Update the selected app if it's the same one
            if selectedApp?.id == app.id {
                selectedApp?.reviewSummary = summary
                selectedApp?.summaryGeneratedDate = Date()
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - Data Management
    private func loadRecentApps() {
        recentApps = dataService.getRecentApps()
    }
    
    func deleteApp(_ app: AppStoreApp) {
        dataService.deleteApp(app)
        loadRecentApps()
        
        // Clear selection if deleted app was selected
        if selectedApp?.id == app.id {
            selectedApp = nil
        }
    }
    
    func clearSearchResults() {
        searchText = ""
        searchResults = []
        searchTask?.cancel()
    }
    
    // MARK: - Computed Properties
    var shouldShowSearchResults: Bool {
        !searchText.isEmpty && (!searchResults.isEmpty || isSearching)
    }
    
    var shouldShowRecentApps: Bool {
        searchText.isEmpty && !recentApps.isEmpty
    }
    
    var shouldShowEmptyState: Bool {
        searchText.isEmpty && recentApps.isEmpty
    }
}
