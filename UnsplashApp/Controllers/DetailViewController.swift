//
//  DetailViewController.swift
//  UnsplashApp
//
//  Created by Александр Муклинов on 20.01.2025.
//

import UIKit

final class DetailViewController: UIViewController {
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 12.0
        imageView.layer.masksToBounds = true
        return imageView
    }()
    private let closeButton: UIButton = {
        let button = UIButton(type: .close)
        button.addTarget(nil, action: #selector(closeViewController), for: .touchUpInside)
        return button
    }()
    weak var delegate: CloseViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(closeButton)
        view.addSubview(imageView)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16.0),
            closeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 16.0),
            closeButton.widthAnchor.constraint(equalToConstant: 24.0),
            closeButton.heightAnchor.constraint(equalToConstant: 24.0),
            
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16.0),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16.0),
            imageView.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 8.0),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16.0)
        ])
    }
    
    func set(image: UIImage) {
        imageView.image = image
    }
    
    @objc func closeViewController() {
        delegate?.close(viewController: self)
    }
    
    deinit {
        print(#function)
    }
}
