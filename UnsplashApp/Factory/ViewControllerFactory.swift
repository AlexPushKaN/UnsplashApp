//
//  ViewControllerFactory.swift
//  UnsplashApp
//
//  Created by Александр Муклинов on 08.02.2025.
//

import UIKit

final class ViewControllerFactory {
    static func createMainController(access key: String) -> MainViewController {
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
    
    static func createDetailController(delegate: CloseDetailControllerDelegate, image: UIImage) -> DetailViewController {
        let view = DetailView(image: image)
        let controller = DetailViewController(view: view)
        controller.delegate = delegate
        controller.modalTransitionStyle = .coverVertical
        controller.modalPresentationStyle = .automatic
        return controller
    }
}
