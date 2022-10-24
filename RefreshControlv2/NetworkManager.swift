//
//  NetworkManager.swift
//  RefreshControlv2
//
//  Created by YouTube on 10/14/22.
//

import Foundation

enum NetworkError: Error {
    case invalidResponse
}

struct Response: Decodable {
    let results: [People]
}

struct People: Decodable {
    let name: String
}

class NetworkManager {
    
    func fetchPeople() async throws -> [People] {
        let url = URL(string: "https://swapi.dev/api/people/?format=json")!
        let (data, httpResponse) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = httpResponse as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NetworkError.invalidResponse
        }
        
        let decoder = JSONDecoder()
        let results = try decoder.decode(Response.self, from: data)
        return results.results
    }
    
    
}
