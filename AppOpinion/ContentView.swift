//
//  ContentView.swift
//  Appinion
//
//  Created by Roman Mirzoyan on 23.06.25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = MainViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search Bar
                SearchBar(text: $viewModel.searchText)
                    .onChange(of: viewModel.searchText) { _, _ in
                        viewModel.onSearchTextChanged()
                    }
                
                // Dynamic Content
                if viewModel.isSearching {
                    LoadingView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.shouldShowSearchResults {
                    SearchResultsList(results: viewModel.searchResults) { app in
                        viewModel.selectApp(app)
                    }
                } else if viewModel.shouldShowRecentApps {
                    RecentAppsList(apps: viewModel.recentApps) { app in
                        viewModel.selectRecentApp(app)
                    } deleteAction: { app in
                        viewModel.deleteApp(app)
                    }
                } else if viewModel.shouldShowEmptyState {
                    EmptyStateView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                
                Spacer()
            }
            .navigationTitle("Appinion")
            // Navigation configuration for macOS
            .sheet(item: $viewModel.selectedApp) { app in
                AppSummaryView(app: app) {
                    await viewModel.generateSummary(for: app)
                }
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: AppStoreApp.self, inMemory: true)
}
