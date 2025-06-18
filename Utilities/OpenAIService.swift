import Foundation

class OpenAIService {
    static let shared = OpenAIService()
    
    // ⚠️ Replace this with your actual API key securely
    private let apiKey = "aabbccdd" // this is a mock key
    
    private init() {}
    
    func getAIInsights(expensesSummary: String, completion: @escaping (String) -> Void) {
        let endpoint = "https://api.openai.com/v1/chat/completions"
        
        // body prompt temp
        let messages = [
            [
                "role": "system",
                "content": "You are a helpful assistant providing concise, encouraging financial insights based on a user's trip expenses summary."
            ],
            [
                "role": "user",
                "content": expensesSummary + "\nPlease provide a friendly summary with encouraging tips."
            ]
        ]
        
        let json: [String: Any] = [
            "model": "gpt-3.5-turbo",  // could use gpt 4
            "messages": messages,
            "max_tokens": 150,
            "temperature": 0.7
        ]
        
        guard let url = URL(string: endpoint) else {
            completion("Error: Invalid API URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: json, options: [])
        } catch {
            completion("Error encoding request: \(error.localizedDescription)")
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion("Network error: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                completion("No data received from AI service.")
                return
            }
            
            do {
                // Parse response JSON
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let choices = jsonResponse["choices"] as? [[String: Any]],
                   let message = choices.first?["message"] as? [String: Any],
                   let content = message["content"] as? String {
                    completion(content.trimmingCharacters(in: .whitespacesAndNewlines))
                } else {
                    completion("Failed to parse AI response.")
                }
            } catch {
                completion("JSON parsing error: \(error.localizedDescription)")
            }
        }
        task.resume()
    }
}

