//
//  AppIconView.swift
//  Appinion
//
//  Created by Assistant on 24.06.25.
//

import SwiftUI

struct AppIconView: View {
    let iconURL: String?
    let size: CGFloat
    let cornerRadius: CGFloat
    
    init(iconURL: String?, size: CGFloat = 64, cornerRadius: CGFloat = 16) {
        self.iconURL = iconURL
        self.size = size
        self.cornerRadius = cornerRadius
    }
    
    var body: some View {
        Group {
            if let iconURL = iconURL, let url = URL(string: iconURL) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    // Placeholder while loading
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(Color.blue.gradient)
                        .overlay {
                            ProgressView()
                                .scaleEffect(0.8)
                                .tint(.white)
                        }
                }
                .frame(width: size, height: size)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            } else {
                // Fallback icon when no URL is available
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.blue.gradient)
                    .frame(width: size, height: size)
                    .overlay {
                        Image(systemName: "app.fill")
                            .font(.system(size: size * 0.4))
                            .foregroundColor(.white)
                    }
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        // With real icon URL
        AppIconView(
            iconURL: "https://is1-ssl.mzstatic.com/image/thumb/Purple211/v4/db/89/d0/db89d069-2a1c-9f4f-b823-7be3dedc1f13/AppIcon-1x_U007emarketing-0-7-0-85-220-0.png/512x512bb.jpg",
            size: 64,
            cornerRadius: 16
        )
        
        // Fallback icon
        AppIconView(
            iconURL: nil,
            size: 64,
            cornerRadius: 16
        )
        
        // Small size
        AppIconView(
            iconURL: "https://is1-ssl.mzstatic.com/image/thumb/Purple211/v4/db/89/d0/db89d069-2a1c-9f4f-b823-7be3dedc1f13/AppIcon-1x_U007emarketing-0-7-0-85-220-0.png/512x512bb.jpg",
            size: 32,
            cornerRadius: 8
        )
    }
    .padding()
}
