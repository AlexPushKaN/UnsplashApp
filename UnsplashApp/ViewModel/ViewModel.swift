//
//  ModelView.swift
//  UnsplashApp
//
//  Created by Александр Муклинов on 18.01.2025.
//

import UIKit

final class ViewModel: NSObject {
    private var service: NetworkServiceProtocol // не понятно почему надо var чтоб менять service.isWorked = true
    private let group = DispatchGroup()
    private let semaphore = DispatchSemaphore(value: 5)
    private let lock = NSLock()
    private let perPage: Int
    private var currentPage: Int = 1
    private var isLoadingNextPage = false
    private var imagesList: [UIImage] = [] {
        didSet {
            guard service.isWorked else { return }
            let startIndex = oldValue.count
            let newIndexPaths = (startIndex..<imagesList.count).map { IndexPath(item: $0, section: 0) }
            guard let collectionView = view?.collectionImageView else { return }
            collectionView.performBatchUpdates {
                collectionView.insertItems(at: newIndexPaths)
            }
        }
    }
    private var imagesURLsList: [String] = [] {
        didSet {
            guard service.isWorked else { return }
            imagesURLsList.forEach { urlString in
                semaphore.wait()
                group.enter()
                DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                    self?.loadImage(from: urlString)
                    self?.group.leave()
                    self?.semaphore.signal()
                }
            }
            group.notify(queue: .main) { [weak self] in
                self?.view?.indicator(activate: false)
                self?.isLoadingNextPage = false
            }
        }
    }
    var queryString: String? = nil {
        didSet {
            guard let queryString else {
                self.resetRequest()
                return
            }
            
            service.isWorked = true
            fetchPhotoURLs(query: queryString, page: currentPage)
        }
    }
    var selectedImage: ((UIImage) -> Void)?
    weak var view: CommunicationProtocolDelegate?

    init(service: NetworkServiceProtocol, countOfLoadImage: Int ) {
        self.service = service
        self.perPage = countOfLoadImage
    }
    
    private func fetchPhotoURLs(query: String, page: Int) {
        view?.indicator(activate: true)
        service.fetchPhotoURLs(query: query, page: page, perPage: perPage) { result in
            switch result {
            case .success(let photoURLs):
                self.imagesURLsList = photoURLs
                if photoURLs.isEmpty {
                    self.resetRequest()
                    self.view?.labelNoResults(show: true)
                } else {
                    self.view?.labelNoResults(show: false)
                }
            case .failure(let error):
                switch error {
                case .incorrectURL:
                    print("Ошибка: Некорректный URL")
                case .noData:
                    print("Ошибка: Ответ не содержит данных")
                case .invalidResponse:
                    print("Ошибка: Непредвиденный формат JSON")
                case .parsingError(let parsingError):
                    print("Ошибка парсинга JSON: \(parsingError)")
                case .networkError(let networkError):
                    print("Сетевая ошибка: \(networkError)")
                }
            }
        }
    }
    
    private func loadImage(from urlString: String) {
        service.loadImage(from: urlString) { [weak self] result in
            switch result {
            case .success(let data):
                guard let image = UIImage(data: data) else {
                    print("Не удалось преобразовать данные в изображение")
                    return
                }
                DispatchQueue.main.async { [weak self] in
                    self?.imagesList.append(image)
                }
            case .failure(let error):
                print("Сетевая ошибка: \(error.localizedDescription)")
            }
        }
    }
    
    private func resetRequest() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            lock.lock()
            currentPage = 1
            service.cancelAllTasks()
            imagesURLsList.removeAll()
            imagesList.removeAll()
            view?.collectionImageView.reloadData()
            lock.unlock()
        }
    }
}


//MARK: - UICollectionViewDataSource
extension ViewModel: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        imagesList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCell.identifier, for: indexPath) as! ImageCell
        cell.setImage(image: imagesList[indexPath.item])
        return cell
    }
}

//MARK: - UICollectionViewDelegate
extension ViewModel: UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView is UICollectionView else { return }
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.size.height
        if offsetY > contentHeight - frameHeight + 50.0, !isLoadingNextPage {
            loadNextPage()
        }
    }
    private func loadNextPage() {
        guard let queryString else { return }
        isLoadingNextPage = true
        currentPage += 1
        fetchPhotoURLs(query: queryString, page: currentPage)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let cell = collectionView.cellForItem(at: indexPath) as! ImageCell
        if let image = cell.imageView.image {
            selectedImage?(image)
        }
    }
}
