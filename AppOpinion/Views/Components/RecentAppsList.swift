//
//  RecentAppsList.swift
//  Appinion
//
//  Created by Roman Mirzoyan on 23.06.25.
//

import SwiftUI

struct RecentAppsList: View {
    let apps: [AppStoreApp]
    let onAppSelected: (AppStoreApp) -> Void
    let deleteAction: (AppStoreApp) -> Void
    
    var body: some View {
        List {
            Section {
                ForEach(apps, id: \.id) { app in
                    RecentAppRow(app: app) {
                        onAppSelected(app)
                    }
                    #if os(macOS)
                    .contextMenu {
                        Button("Delete", role: .destructive) {
                            deleteAction(app)
                        }
                    }
                    #endif
                }
                #if os(iOS) || os(iPadOS)
                .onDelete { indexSet in
                    for index in indexSet {
                        deleteAction(apps[index])
                    }
                }
                #endif
            } header: {
                HStack {
                    Text("Recent Searches")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    if !apps.isEmpty {
                        Text("\(apps.count) app\(apps.count == 1 ? "" : "s")")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .listStyle(PlainListStyle())
    }
}

struct RecentAppRow: View {
    let app: AppStoreApp
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                // App icon
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
                    
                    HStack {
                        Text(app.bundleId)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        if app.reviewSummary != nil {
                            Label("Summary Available", systemImage: "checkmark.circle.fill")
                                .font(.caption2)
                                .foregroundColor(.green)
                        }
                    }
                    
                    Text("Last viewed \(app.lastSearched, style: .relative) ago")
                        .font(.caption2)
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
        .buttonStyle(.plain)
    }
}

#Preview {
    RecentAppsList(
        apps: [
            AppStoreApp(id: "1", name: "Test App", bundleId: "com.test.app")
        ],
        onAppSelected: { _ in },
        deleteAction: { _ in }
    )
}
