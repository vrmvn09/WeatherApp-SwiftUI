//
//  NetworkServiceType.swift
//  WeatherApp
//
//  Created by Arman Urstem on 2025.
//

import Foundation

/// Протокол для работы с сетевыми запросами
protocol NetworkServiceType {
    func request<T: Decodable>(_ url: URL) async throws -> T
}
