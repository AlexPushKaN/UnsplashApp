//
//  NetworkService.swift
//  UnsplashApp
//
//  Created by Александр Муклинов on 08.02.2025.
//

import Foundation

final class NetworkService: NetworkServiceProtocol {
    enum NetworkError: Error {
        case incorrectURL
        case noData
        case invalidResponse
        case parsingError(Error)
        case networkError(Error)
    }
    
    enum APIHeaders {
        static let authorizationKey = "Authorization"
        static let clientIDPrefix = "Client-ID"
    }
    
    private let accessKey: String
    private let baseURL = "https://api.unsplash.com/search/photos"
    private var tasks: [URLSessionDataTask] = []
    private let syncQueue = DispatchQueue(
        label: "com.networkService.syncQueue",
        qos: .utility,
        attributes: .concurrent
    )
    
    init(access key: String) {
        self.accessKey = key
    }
    
    func fetchPhotoURLs(
        query: String,
        page: Int = 1,
        perPage: Int = 10,
        completion: @escaping (Result<[String], NetworkError>) -> Void
    ) {
        let urlString = "\(baseURL)?query=\(query)&page=\(page)&per_page=\(perPage)"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(.incorrectURL))
            return
        }

        var request = URLRequest(url: url)
        request.setValue("\(APIHeaders.clientIDPrefix) \(accessKey)", forHTTPHeaderField: APIHeaders.authorizationKey)
        
        var task: URLSessionDataTask?
        task = URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            defer {
                if let task = task {
                    self?.removeTask(task)
                }
            }
            
            if let error = error {
                completion(.failure(.networkError(error)))
                return
            }

            guard let data = data else {
                completion(.failure(.noData))
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let results = json["results"] as? [[String: Any]] {
                    let photoURLs = results.compactMap { $0["urls"] as? [String: String] }.compactMap { $0["regular"] }
                    completion(.success(photoURLs))
                } else {
                    completion(.failure(.invalidResponse))
                }
            } catch {
                completion(.failure(.parsingError(error)))
            }
        }
        guard let task else { return }
        addTask(task)
        task.resume()
    }
    
    func loadImage(from urlString: String, completion: @escaping (Result<Data, NetworkError>) -> Void) {
        guard let URL = URL(string: urlString) else {
            return completion(.failure(.incorrectURL))
        }
        var task: URLSessionDataTask?
        task  = URLSession.shared.dataTask(with: URL) { [weak self] data, _, error in
            defer {
                if let task = task {
                    self?.removeTask(task)
                }
            }
            
            if let error = error {
                completion(.failure(.networkError(error)))
            }
            
            guard let data = data else {
                return completion(.failure(.noData))
            }
            
            completion(.success(data))
        }
        guard let task else { return }
        addTask(task)
        task.resume()
    }
    
    func addTask(_ task: URLSessionDataTask) {
        syncQueue.async(flags: .barrier) {
            self.tasks.append(task)
        }
    }
    
    func removeTask(_ task: URLSessionDataTask) {
        syncQueue.async(flags: .barrier) {
            if let index = self.tasks.firstIndex(where: { $0 === task }) {
                self.tasks.remove(at: index)
            }
        }
    }
    
    func cancelAllTasks() {
        syncQueue.async(flags: .barrier) { [weak self] in
            self?.tasks.forEach { $0.cancel() }
            self?.tasks.removeAll()
        }
    }
}

