//
//  MainViewController.swift
//  UnsplashApp
//
//  Created by Александр Муклинов on 08.02.2025.
//

import UIKit

final class MainViewController: UIViewController {
    private let mainView: MainView
    private let viewModel: ViewModelProtocol
    private let cacheImages = NSCache<NSNumber, UIImage>()

    init(view: MainView, viewModel: ViewModelProtocol) {
        self.mainView = view
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBindings()
    }
    
    private func setupBindings() {
        viewModel.imagesUpdated = { [weak self] in
            guard let self else { return }
            DispatchQueue.main.async {
                self.mainView.searchView.collectionImageView.reloadData()
            }
        }
        
        viewModel.clearCache = { [weak self] in
            guard let self else { return }
            cacheImages.removeAllObjects()
        }
        
        viewModel.loadingStateChanged = { [weak self] isLoading in
            guard let self else { return }
            mainView.searchView.indicator(activate: isLoading)
        }

        viewModel.noResultsFound = { [weak self] show in
            guard let self else { return }
            mainView.searchView.labelNoResults(show: show)
        }
        
        viewModel.imageSelected = { [weak self] imageData in
            guard let self,
                  let image = UIImage(data: imageData) else { return }
            let detailViewController = ViewControllerFactory.createDetailController(delegate: self, image: image)
            present(detailViewController, animated: true)
        }
    }
}

// MARK: - CloseViewControllerDelegate
extension MainViewController: CloseDetailControllerDelegate {
    func close(controller: UIViewController) {
        controller.dismiss(animated: true)
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension MainViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.numberOfImages()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCell.identifier, for: indexPath) as! ImageCell

        let index = NSNumber(value: indexPath.item)

        if let cachedImage = cacheImages.object(forKey: index) {
            cell.setImage(image: cachedImage)
        } else {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                guard let self = self,
                      let imageData = self.viewModel.image(at: indexPath.item),
                      let image = UIImage(data: imageData) else { return }
                cacheImages.setObject(image, forKey: index)
                DispatchQueue.main.async {
                    if let updatedCell = collectionView.cellForItem(at: indexPath) as? ImageCell {
                        updatedCell.setImage(image: image)
                    }
                }
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let image = viewModel.image(at: indexPath.item) {
            viewModel.imageSelected?(image)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.size.height
        if offsetY > contentHeight - frameHeight + 50.0 {
            viewModel.loadNextPage()
        }
        mainView.endEditing(true)
    }
}
