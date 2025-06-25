//
//  EmptyStateView.swift
//  Appinion
//
//  Created by Roman Mirzoyan on 23.06.25.
//

import SwiftUI

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "magnifyingglass.circle")
                .font(.system(size: 64))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text("Search for Apps")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Find any App Store app and get AI-powered summaries of customer reviews")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                Label("Real-time search results", systemImage: "magnifyingglass")
                Label("AI-generated review summaries", systemImage: "brain.head.profile")
                Label("Search history saved locally", systemImage: "clock.arrow.circlepath")
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding(.horizontal, 32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.background)
    }
}

#Preview {
    EmptyStateView()
}
