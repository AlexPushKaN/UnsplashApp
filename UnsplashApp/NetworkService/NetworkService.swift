//
//  NetworkService.swift
//  UnsplashApp
//
//  Created by Александр Муклинов on 18.01.2025.
//

import Foundation

protocol NetworkServiceProtocol {
    var isWorked: Bool { get set }
    func fetchPhotoURLs(
        query: String,
        page: Int,
        perPage: Int,
        completion: @escaping (Result<[String], NetworkService.NetworkError>) -> Void
    )
    func loadImage(
        from urlString: String,
        completion: @escaping (Result<Data, NetworkService.NetworkError>) -> Void
    )
    func cancelAllTasks()
}

final class NetworkService: NetworkServiceProtocol {
    enum NetworkError: Error {
        case incorrectURL
        case noData
        case invalidResponse
        case parsingError(Error)
        case networkError(Error)
    }
    private let accessKey: String
    private var tasks: [URLSessionDataTask] = []
    private let syncQueue = DispatchQueue(label: "com.networkService.syncQueue", attributes: .concurrent)
    var isWorked = true
    
    init(accessKey: String) {
        self.accessKey = accessKey
    }
    
    func fetchPhotoURLs(
        query: String,
        page: Int = 1,
        perPage: Int = 10,
        completion: @escaping (Result<[String], NetworkError>) -> Void
    ) {
        let urlString = "https://api.unsplash.com/search/photos?query=\(query)&page=\(page)&per_page=\(perPage)"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(.incorrectURL))
            return
        }

        var request = URLRequest(url: url)
        request.setValue("Client-ID \(accessKey)", forHTTPHeaderField: "Authorization")
        
        var task: URLSessionDataTask?
        task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            defer { if let task = task { self?.removeTask(task) } }
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
        guard let URL = URL(string: urlString) else { return completion(.failure(.incorrectURL)) }
        var task: URLSessionDataTask?
        task  = URLSession.shared.dataTask(with: URL) { [weak self] data, response, error in
            defer { if let task = task { self?.removeTask(task) } }
            if let error = error { completion(.failure(.networkError(error))) }
            guard let data = data else { return completion(.failure(.noData)) }
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
        isWorked = false
    }
}
