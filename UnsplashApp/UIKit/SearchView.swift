//
//  SearchView.swift
//  UnsplashApp
//
//  Created by Александр Муклинов on 08.02.2025.
//

import UIKit

final class SearchView: UIView, CommunicationProtocolDelegate {
    lazy var indicatorLoadingView: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = .red
        activityIndicator.alpha = 0.0
        return activityIndicator
    }()
    lazy var collectionImageView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 10.0
        layout.minimumInteritemSpacing = 10.0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: ImageCell.identifier)
        collectionView.alpha = 0.0
        return collectionView
    }()
    private lazy var noResultsLabel: UILabel = {
        let label = UILabel()
        label.text = "К сожалению, поиск не дал результатов"
        label.sizeToFit()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .systemGray4
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let layout = collectionImageView.collectionViewLayout as? UICollectionViewFlowLayout {
            let itemWidth = (bounds.width - layout.minimumInteritemSpacing * 2) / 3
            layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        }
    }
    
    private func setupUI() {
        addSubview(collectionImageView)
        addSubview(indicatorLoadingView)
        collectionImageView.translatesAutoresizingMaskIntoConstraints = false
        indicatorLoadingView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionImageView.topAnchor.constraint(equalTo: topAnchor),
            collectionImageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            indicatorLoadingView.centerXAnchor.constraint(equalTo: centerXAnchor),
            indicatorLoadingView.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
    
    func updateCollectionView() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            collectionImageView.reloadData()
        }
    }
    
    func indicator(activate: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            if activate {
                indicatorLoadingView.startAnimating()
            } else {
                indicatorLoadingView.stopAnimating()
            }
        }
    }
    
    func labelNoResults(show: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            if show {
                addSubview(noResultsLabel)
            } else {
                noResultsLabel.removeFromSuperview()
            }
        }
    }
}
