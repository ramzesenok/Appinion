//
//  SearchResultsList.swift
//  Appinion
//
//  Created by Roman Mirzoyan on 23.06.25.
//

import SwiftUI
import SwiftData
import Foundation

struct SearchResultsList: View {
    let results: [AppStoreAppData]
    let onAppSelected: (AppStoreAppData) -> Void
    
    var body: some View {
        List {
            Section {
                ForEach(results, id: \.id) { app in
                    SearchResultRow(app: app) {
                        onAppSelected(app)
                    }
                }
            } header: {
                Text("Search Results")
                    .font(.headline)
                    .foregroundColor(.primary)
            }
        }
        .listStyle(PlainListStyle())
    }
}

struct SearchResultRow: View {
    let app: AppStoreAppData
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                AppIconView(
                    iconURL: app.iconURL,
                    size: 40,
                    cornerRadius: 8
                )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(app.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    
                    Text(app.bundleId)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 4)
            .contentShape(.rect)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    SearchResultsList(
        results: [
            AppStoreAppData(
                id: "1",
                name: "Test App",
                bundleId: "com.test.app",
                iconURL: "https://example.com/icon.png"
            )
        ],
        onAppSelected: { _ in }
    )
}
