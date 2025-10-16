//
//  NetworkService.swift
//  WeatherApp
//
//  Created by Arman Urstem on 2025.
//

import Foundation

final class NetworkService: NetworkServiceType {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func request<T: Decodable>(_ url: URL) async throws -> T {
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidResponse
        }
        
        do {
            let decoded = try JSONDecoder().decode(T.self, from: data)
            return decoded
        } catch {
            throw error
        }
    }
}
