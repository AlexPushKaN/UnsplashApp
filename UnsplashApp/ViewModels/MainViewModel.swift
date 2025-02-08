//
//  MainViewModel.swift
//  UnsplashApp
//
//  Created by Александр Муклинов on 08.02.2025.
//

import Foundation

final class MainViewModel: NSObject, ViewModelProtocol {
    private var service: NetworkServiceProtocol
    private let perPage: Int
    private var currentPage: Int = 1
    private var isLoadingNextPage = false
    private var imagesURLsList: [String] = []
    private var imagesList: [Data] = [] {
        didSet {
            if imagesList.count < imagesURLsList.count {
                isLoadingNextPage = true
            } else {
                isLoadingNextPage = false
            }
            if imagesList.count % 10 == 0 {
                imagesUpdated?()
                loadingStateChanged?(false)
            }
        }
    }
    var imagesUpdated: (() -> Void)?
    var clearCache: (() -> Void)?
    var loadingStateChanged: ((Bool) -> Void)?
    var noResultsFound: ((Bool) -> Void)?
    var imageSelected: ((Data) -> Void)?
    var queryString: String? = nil {
        didSet {
            setQuery(string: queryString)
        }
    }
    
    init(service: NetworkServiceProtocol, countOfLoadImage: Int) {
        self.service = service
        self.perPage = countOfLoadImage
    }
    
    private func fetchPhotoURLs(query: String, page: Int) {
        loadingStateChanged?(true)
        service.fetchPhotoURLs(query: query, page: page, perPage: perPage) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let photoURLs):
                imagesURLsList = photoURLs
                if photoURLs.isEmpty {
                    noResultsFound?(true)
                    loadingStateChanged?(false)
                } else {
                    noResultsFound?(false)
                }
                photoURLs.forEach { urlString in
                    self.loadingStateChanged?(true)
                    self.loadImage(from: urlString)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func loadImage(from urlString: String) {
        service.loadImage(from: urlString) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let data):
                imagesList.append(data)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func resetRequest() {
        currentPage = 1
        service.cancelAllTasks()
        imagesURLsList.removeAll()
        imagesList.removeAll()
        imagesUpdated?()
        clearCache?()
    }
    
    func setQuery(string: String?) {
        guard let string else {
            resetRequest()
            return
        }
        fetchPhotoURLs(query: string, page: currentPage)
    }
    
    func loadNextPage() {
        guard let queryString = queryString, !isLoadingNextPage else { return }
        isLoadingNextPage = true
        currentPage += 1
        fetchPhotoURLs(query: queryString, page: currentPage)
    }
    
    func image(at index: Int) -> Data? {
        guard index < imagesList.count else { return nil }
        return imagesList[index]
    }
    
    func numberOfImages() -> Int {
        imagesList.count
    }
}

