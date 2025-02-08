//
//  Protocols.swift
//  UnsplashApp
//
//  Created by Александр Муклинов on 08.02.2025.
//

import UIKit

protocol MainControllerProtocol: AnyObject {
    var inputedText: ((String?) -> Void)? { get set }
}

protocol DetailControllerProtocol: AnyObject {
    var closeButton: UIButton { get }
}

protocol CloseDetailControllerDelegate: AnyObject {
    func close(controller: UIViewController)
}

protocol CommunicationProtocolDelegate: AnyObject {
    var indicatorLoadingView: UIActivityIndicatorView { get set }
    var collectionImageView: UICollectionView { get set }
    func updateCollectionView()
    func indicator(activate: Bool)
    func labelNoResults(show: Bool)
}

protocol NetworkServiceProtocol {
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

protocol ViewModelProtocol: AnyObject {
    var imagesUpdated: (() -> Void)? { get set }
    var clearCache: (() -> Void)? { get set }
    var loadingStateChanged: ((Bool) -> Void)? { get set }
    var noResultsFound: ((Bool) -> Void)? { get set }
    var imageSelected: ((Data) -> Void)? { get set }
    
    func setQuery(string: String?)
    func loadNextPage()
    func image(at index: Int) -> Data?
    func numberOfImages() -> Int
}

