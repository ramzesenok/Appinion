//
//  iTunesRSSService.swift
//  Appinion
//
//  Created by Assistant on 24.06.25.
//

import Foundation

class iTunesRSSService: ObservableObject {
    private let session = URLSession.shared
    
    func fetchReviews(for appId: String, limit: Int = 50) async throws -> [String] {
        print("🔍 Starting iTunes RSS Reviews fetch for app ID: \(appId)")
        
        // iTunes RSS feed URL for reviews
        let baseURL = "https://itunes.apple.com/us/rss/customerreviews"
        let urlString = "\(baseURL)/id=\(appId)/sortBy=mostRecent/json"
        
        guard let url = URL(string: urlString) else {
            print("❌ Invalid RSS URL: \(urlString)")
            throw iTunesRSSError.invalidURL
        }
        
        print("🌐 RSS URL: \(urlString)")
        
        do {
            let (data, response) = try await session.data(from: url)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📊 HTTP Status: \(httpResponse.statusCode)")
                
                guard httpResponse.statusCode == 200 else {
                    print("❌ RSS API Error - Status: \(httpResponse.statusCode)")
                    throw iTunesRSSError.apiError(httpResponse.statusCode)
                }
            }
            
            let rssResponse = try JSONDecoder().decode(iTunesRSSResponse.self, from: data)
            
            // Filter out the first entry as it's usually app info, not a review
            let reviewEntries = Array(rssResponse.feed.entry.dropFirst().prefix(limit))
            
            let reviews = reviewEntries.map { entry in
                "\(entry.title.label) - \(entry.content.label)"
            }
            
            print("✅ Found \(reviews.count) reviews from RSS feed")
            
            if !reviews.isEmpty {
                print("📋 Sample reviews:")
                for review in reviews.prefix(3) {
                    let bodyPreview = String(review.prefix(100))
                    print("   - \(bodyPreview)...")
                }
            }
            
            return reviews
            
        } catch let decodingError as DecodingError {
            print("❌ JSON Decoding Error: \(decodingError)")
            throw iTunesRSSError.decodingError(decodingError.localizedDescription)
        } catch let error as URLError {
            print("❌ Network Error: \(error.localizedDescription)")
            throw iTunesRSSError.networkError(error.localizedDescription)
        } catch {
            print("❌ Unexpected error: \(error)")
            throw error
        }
    }
    
    private func parseDate(from dateString: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: dateString)
    }
}

// MARK: - iTunes RSS Data Models
struct iTunesRSSResponse: Codable {
    let feed: iTunesRSSFeed
}

struct iTunesRSSFeed: Codable {
    let entry: [iTunesRSSEntry]
}

struct iTunesRSSEntry: Codable {
    let id: iTunesRSSLabel
    let title: iTunesRSSLabel
    let content: iTunesRSSLabel
    let author: iTunesRSSAuthor
    let updated: iTunesRSSLabel
    let rating: iTunesRSSLabel
    
    enum CodingKeys: String, CodingKey {
        case id, title, content, author, updated
        case rating = "im:rating"
    }
}

struct iTunesRSSLabel: Codable {
    let label: String
}

struct iTunesRSSAuthor: Codable {
    let name: iTunesRSSLabel
}

enum iTunesRSSError: Error, LocalizedError {
    case invalidURL
    case apiError(Int)
    case networkError(String)
    case decodingError(String)
    case noData
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid RSS URL"
        case .apiError(let statusCode):
            return "iTunes RSS request failed with status code: \(statusCode)"
        case .networkError(let message):
            return "Network error: \(message)"
        case .decodingError(let message):
            return "Data parsing error: \(message)"
        case .noData:
            return "No review data available"
        }
    }
}
