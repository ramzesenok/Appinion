//
//  Configuration.swift
//  Appinion
//
//  Created by Roman Mirzoyan on 23.06.25.
//

import Foundation

enum Configuration {
    // MARK: - OpenAI API Configuration
    
    /// Your OpenAI API Key
    /// This will be loaded from a Config.plist file or environment variable
    static let openAIApiKey: String = {
        // First, try to load from Config.plist (for local development)
        if let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
           let plist = NSDictionary(contentsOfFile: path),
           let apiKey = plist["OPENAI_API_KEY"] as? String,
           !apiKey.isEmpty {
            return apiKey
        }
        
        // Fallback to environment variable (for CI/CD or advanced users)
        if let envKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"],
           !envKey.isEmpty {
            return envKey
        }
        
        // Return empty string if no configuration found
        return ""
    }()

    // MARK: - Validation
    static var isConfigured: Bool {
        return !openAIApiKey.isEmpty && openAIApiKey.hasPrefix("sk-")
    }
}
