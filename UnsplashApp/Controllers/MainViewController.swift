//
//  ViewController.swift
//  UnsplashApp
//
//  Created by Александр Муклинов on 16.01.2025.
//

import UIKit

final class MainViewController<T: UIView & CommunicationProtocol>: UIViewController {
    var detailViewController: DetailViewController?
    var mainView: T
    let viewModel: ViewModel
    
    init(mainView: T, viewModel: ViewModel) {
        self.mainView = mainView
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainView.inputedText = { [weak self] text in
            self?.viewModel.queryString = text
        }
        viewModel.selectedImage = { [weak self] image in
            guard let self else { return }
            detailViewController = DetailViewController()
            detailViewController?.delegate = self
            detailViewController?.set(image: image)
            detailViewController?.modalTransitionStyle = .coverVertical
            detailViewController?.modalPresentationStyle = .automatic
            if let detailViewController = detailViewController {
                present(detailViewController, animated: true)
            }
        }
    }
}

//MARK: - CloseViewControllerDelegate
extension MainViewController: CloseViewControllerDelegate {
    func close(viewController: UIViewController) {
        detailViewController?.dismiss(animated: true, completion: { [weak self] in
            self?.detailViewController = nil
        })
    }
}
