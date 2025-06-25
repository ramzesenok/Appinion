//
//  SearchBar.swift
//  Appinion
//
//  Created by Roman Mirzoyan on 23.06.25.
//

import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    @FocusState private var isSearchFocused: Bool
    
    var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Search App Store apps...", text: $text)
                    .focused($isSearchFocused)
                    .textFieldStyle(PlainTextFieldStyle())
                
                if !text.isEmpty {
                    Button(action: {
                        text = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 10))
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
}

#Preview {
    SearchBar(text: .constant("Test Search"))
}
