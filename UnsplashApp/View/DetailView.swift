//
//  DetailView.swift
//  UnsplashApp
//
//  Created by Александр Муклинов on 08.02.2025.
//

import UIKit

final class DetailView: UIView, DetailControllerProtocol {
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 12.0
        imageView.layer.masksToBounds = true
        return imageView
    }()
    lazy var closeButton: UIButton = {
        let button = UIButton(type: .close)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    convenience init(image: UIImage) {
        self.init(frame: .zero)
        imageView.image = image
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = .white
        addSubview(closeButton)
        addSubview(imageView)
        
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            closeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.0),
            closeButton.topAnchor.constraint(equalTo: topAnchor, constant: 16.0),
            closeButton.widthAnchor.constraint(equalToConstant: 24.0),
            closeButton.heightAnchor.constraint(equalToConstant: 24.0),
            
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.0),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.0),
            imageView.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 8.0),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16.0)
        ])
    }
}
