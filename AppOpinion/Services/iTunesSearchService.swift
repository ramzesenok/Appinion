//
//  iTunesSearchService.swift
//  Appinion
//
//  Created by Assistant on 24.06.25.
//

import Foundation
import SwiftData

class iTunesSearchService: ObservableObject {
    private let baseURL = "https://itunes.apple.com/search"
    private let session = URLSession.shared
    
    func searchApps(query: String) async throws -> [iTunesAppData] {
        print("🔍 Starting iTunes Search for: '\(query)'")
        
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return []
        }
        
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed.subtracting(CharacterSet(charactersIn: "+&"))) ?? ""
        print("🔤 Original query: '\(query)'")
        print("🔤 Encoded query: '\(encodedQuery)'")
        let urlString = "\(baseURL)?term=\(encodedQuery)&entity=software&limit=50&country=US"
        
        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL: \(urlString)")
            throw iTunesSearchError.invalidURL
        }
        
        print("🌐 iTunes Search URL: \(urlString)")
        
        do {
            let (data, response) = try await session.data(from: url)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📊 HTTP Status: \(httpResponse.statusCode)")
                print("📊 Response Headers: \(httpResponse.allHeaderFields)")
                
                guard httpResponse.statusCode == 200 else {
                    print("❌ iTunes API Error - Status: \(httpResponse.statusCode)")
                    print("❌ Response Body: \(String(data: data, encoding: .utf8) ?? "Unable to decode")")
                    throw iTunesSearchError.apiError(httpResponse.statusCode)
                }
            }
            
            let searchResponse = try JSONDecoder().decode(iTunesSearchResponse.self, from: data)
            print("✅ Found \(searchResponse.results.count) apps")
            
            if !searchResponse.results.isEmpty {
                print("📋 Found apps:")
                for app in searchResponse.results.prefix(5) {
                    print("   - \(app.trackName) by \(app.artistName)")
                }
            }
            
            return searchResponse.results
            
        } catch let error as URLError {
            print("❌ Network Error: \(error.localizedDescription)")
            throw iTunesSearchError.networkError(error.localizedDescription)
        } catch {
            print("❌ Unexpected error: \(error)")
            throw error
        }
    }
    
    func getAppDetails(trackId: Int) async throws -> iTunesAppData? {
        let urlString = "\(baseURL)?id=\(trackId)&entity=software"
        
        guard let url = URL(string: urlString) else {
            throw iTunesSearchError.invalidURL
        }
        
        do {
            let (data, response) = try await session.data(from: url)
            
            if let httpResponse = response as? HTTPURLResponse {
                guard httpResponse.statusCode == 200 else {
                    throw iTunesSearchError.apiError(httpResponse.statusCode)
                }
            }
            
            let searchResponse = try JSONDecoder().decode(iTunesSearchResponse.self, from: data)
            return searchResponse.results.first
            
        } catch {
            throw error
        }
    }
}

// MARK: - iTunes Search Data Models
struct iTunesSearchResponse: Codable {
    let resultCount: Int
    let results: [iTunesAppData]
}

struct iTunesAppData: Codable, Identifiable {
    let trackId: Int
    let trackName: String
    let artistName: String
    let bundleId: String
    let artworkUrl512: String?
    let artworkUrl100: String?
    let trackViewUrl: String
    let description: String?
    let averageUserRating: Double?
    let userRatingCount: Int?
    let version: String
    let price: Double
    let currency: String
    let genres: [String]
    let releaseDate: String
    let minimumOsVersion: String
    
    var id: Int { trackId }
}

enum iTunesSearchError: Error, LocalizedError {
    case invalidURL
    case apiError(Int)
    case networkError(String)
    case noData
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .apiError(let statusCode):
            return "iTunes API request failed with status code: \(statusCode)"
        case .networkError(let message):
            return "Network error: \(message)"
        case .noData:
            return "No data available"
        }
    }
}
