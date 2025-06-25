//
//  AppSummaryView.swift
//  Appinion
//
//  Created by Roman Mirzoyan on 23.06.25.
//

import SwiftUI

struct AppSummaryView: View {
    let app: AppStoreApp
    let onGenerateSummary: () async -> Void
    
    @State private var isGeneratingSummary = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header with title and close button
                HStack {
                    Text("App Summary")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.secondary)
                            .background(Color.clear)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.bottom, 8)
                
                // App Header
                AppHeaderView(app: app)
                
                // Summary Section
                SummarySection(
                    app: app,
                    isGenerating: isGeneratingSummary,
                    onGenerateSummary: {
                        await generateSummary()
                    }
                )
                
                Spacer(minLength: 32)
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.background)
    }
    
    private func generateSummary() async {
        isGeneratingSummary = true
        await onGenerateSummary()
        isGeneratingSummary = false
    }
}

struct AppHeaderView: View {
    let app: AppStoreApp
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // App icon with AppIconView component
                AppIconView(
                    iconURL: app.iconURL,
                    size: 64,
                    cornerRadius: 16
                )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(app.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .lineLimit(2)
                    
                    Text(app.bundleId)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Image(systemName: "clock")
                        Text("Searched \(app.lastSearched, style: .relative) ago")
                    }
                    .font(.caption2)
                    .foregroundColor(.secondary)
                }
                
                Spacer()
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

struct SummarySection: View {
    let app: AppStoreApp
    let isGenerating: Bool
    let onGenerateSummary: () async -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Label("Review Summary", systemImage: "brain.head.profile")
                    .font(.headline)
                
                Spacer()
                
                if let summaryDate = app.summaryGeneratedDate {
                    Text("Generated \(summaryDate, style: .relative) ago")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            if isGenerating {
                LoadingSummaryView()
            } else if let summary = app.reviewSummary {
                SummaryContentView(summary: summary)
            } else {
                NoSummaryView(onGenerate: onGenerateSummary)
            }
        }
    }
}

struct LoadingSummaryView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            
            Text("Analyzing customer reviews...")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 120)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

struct SummaryContentView: View {
    let summary: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(summary)
                .font(.body)
                .lineSpacing(4)
            
            HStack {
                Spacer()
                Label("Powered by AI", systemImage: "sparkles")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

struct NoSummaryView: View {
    let onGenerate: () async -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 32))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text("No Summary Available")
                    .font(.headline)
                
                Text("Generate an AI-powered summary of customer reviews for this app")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: {
                Task {
                    await onGenerate()
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "brain.head.profile")
                    Text("Generate Summary")
                }
                .font(.callout)
                .fontWeight(.medium)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .buttonStyle(PlainButtonStyle())
            .controlSize(.large)
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    let sampleApp = AppStoreApp(id: "1", name: "Test App", bundleId: "com.test.app")
    sampleApp.reviewSummary = "This is a sample review summary that shows how the AI-generated content would appear in the app. Users generally love the app's intuitive interface and smooth performance."
    sampleApp.summaryGeneratedDate = Date()
    
    return AppSummaryView(app: sampleApp) {
        // Mock async function
    }
}
