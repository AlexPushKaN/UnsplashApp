//
//  ViewControllerFactory.swift
//  UnsplashApp
//
//  Created by Александр Муклинов on 08.02.2025.
//

import UIKit

final class ViewControllerFactory: ViewControllerFactoryProtocol {
    static func makeMainController(access key: String) -> UIViewController {
        let networkService = NetworkService(access: key)
        let viewModel = MainViewModel(service: networkService, countOfLoadImage: 30)
        let view = MainView()
        let controller = MainViewController(view: view, viewModel: viewModel)
        view.searchView.collectionImageView.dataSource = controller
        view.searchView.collectionImageView.delegate = controller
        view.inputedText = { [weak viewModel] text in
            viewModel?.queryString = text
        }
        return controller
    }
    
    static func makeDetailController(delegate: CloseDetailControllerDelegate, image: UIImage) -> UIViewController {
        let view = DetailView(image: image)
        let controller = DetailViewController(view: view)
        controller.delegate = delegate
        controller.modalTransitionStyle = .coverVertical
        controller.modalPresentationStyle = .automatic
        return controller
    }
}
