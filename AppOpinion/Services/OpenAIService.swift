//
//  OpenAIService.swift
//  Appinion
//
//  Created by Roman Mirzoyan on 23.06.25.
//

import Foundation

class OpenAIService: ObservableObject {
    private let apiKey = Configuration.openAIApiKey
    private let baseURL = "https://api.openai.com/v1"
    private let session = URLSession.shared
    
    func summarizeReviews(_ reviews: [String], for appName: String) async throws -> String {
        guard Configuration.isConfigured else {
            throw OpenAIError.apiKeyRequired
        }
        
        guard !reviews.isEmpty else {
            return "No reviews available for this app."
        }
        
        let reviewText = reviews.joined(separator: "\n\n")
        let prompt = """
        Analyze the following customer reviews for the app "\(appName)" and provide a comprehensive summary in 3-4 paragraphs. Focus on:
        1. Overall user sentiment and satisfaction
        2. Most commonly mentioned positive features
        3. Main complaints and issues users face
        4. Any trends or patterns in the feedback
        
        Reviews:
        \(reviewText)
        
        Please provide a balanced, objective summary that would help someone understand what users think about this app.
        """
        
        let requestBody = OpenAIRequest(
            model: "gpt-3.5-turbo",
            messages: [
                OpenAIMessage(role: "system", content: "You are a helpful assistant that analyzes app store reviews and provides clear, objective summaries."),
                OpenAIMessage(role: "user", content: prompt)
            ],
            maxTokens: 500,
            temperature: 0.3
        )
        
        guard let url = URL(string: "\(baseURL)/chat/completions") else {
            throw OpenAIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(requestBody)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw OpenAIError.apiError
        }
        
        let openAIResponse = try JSONDecoder().decode(OpenAIResponse.self, from: data)
        
        guard let content = openAIResponse.choices.first?.message.content else {
            throw OpenAIError.noContent
        }
        
        return content
    }
}

// MARK: - OpenAI API Models
struct OpenAIRequest: Codable {
    let model: String
    let messages: [OpenAIMessage]
    let maxTokens: Int
    let temperature: Double
    
    enum CodingKeys: String, CodingKey {
        case model, messages, temperature
        case maxTokens = "max_tokens"
    }
}

struct OpenAIMessage: Codable {
    let role: String
    let content: String
}

struct OpenAIResponse: Codable {
    let choices: [OpenAIChoice]
}

struct OpenAIChoice: Codable {
    let message: OpenAIMessage
}

enum OpenAIError: Error, LocalizedError {
    case invalidURL
    case apiError
    case apiKeyRequired
    case noContent
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .apiError:
            return "OpenAI API request failed"
        case .apiKeyRequired:
            return "OpenAI API key required"
        case .noContent:
            return "No content returned from OpenAI"
        }
    }
}
