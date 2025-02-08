//
//  DetailViewController.swift
//  UnsplashApp
//
//  Created by Александр Муклинов on 08.02.2025.
//

import UIKit

final class DetailViewController: UIViewController {
    private let detailView: UIView & DetailControllerProtocol
    weak var delegate: CloseDetailControllerDelegate?
    
    init(view: UIView & DetailControllerProtocol) {
        self.detailView = view
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = detailView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        detailView.closeButton.addTarget(self, action: #selector(closeSelf), for: .touchUpInside)
    }
    
    @objc private func closeSelf() {
        delegate?.close(controller: self)
    }
    
    deinit {
        print(#function)
    }
}
