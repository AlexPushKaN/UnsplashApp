//
//  MainView.swift
//  UnsplashApp
//
//  Created by Александр Муклинов on 16.01.2025.
//

import UIKit

final class MainView: UIView, CommunicationProtocol {
    enum State {
        case startSearching(String)
        case endSearching
    }
    lazy var searchFieldView = SearchFieldView()
    lazy var searchView: UIView & CommunicationProtocolDelegate = SearchView()
    private var centerYConstraint: NSLayoutConstraint!
    private var topConstraint: NSLayoutConstraint!
    var inputedText: ((String?) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        searchFieldView.state = { [weak self] state in
            switch state {
            case .startSearching(let inputedText):
                guard !inputedText.isEmpty else { return }
                self?.updateConstraintsFor(search: false)
                self?.searchView.indicator(activate: true)
                self?.keyboard(hide: true)
                self?.searchView(hide: false)
                self?.inputedText?(inputedText)
            case .endSearching:
                self?.updateConstraintsFor(search: true)
                self?.searchView.indicator(activate: false)
                self?.keyboard(hide: true)
                self?.searchView(hide: true)
                self?.searchFieldView.hideFindButton()
                self?.inputedText?(nil)
                self?.searchView.labelNoResults(show: false)
            }
        }
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        searchFieldView.state?(.endSearching)
    }
    
    private func setupUI() {
        addSubview(searchFieldView)
        addSubview(searchView)
        searchFieldView.translatesAutoresizingMaskIntoConstraints = false
        searchView.translatesAutoresizingMaskIntoConstraints = false
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let statusBarHeight = windowScene.statusBarManager?.statusBarFrame.height {
            topConstraint = searchFieldView.topAnchor.constraint(equalTo: topAnchor, constant: statusBarHeight)
            centerYConstraint = searchFieldView.centerYAnchor.constraint(equalTo: centerYAnchor)
        }

        NSLayoutConstraint.activate([
            searchFieldView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.0),
            searchFieldView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.0),
            searchFieldView.heightAnchor.constraint(equalToConstant: 48.0),
            centerYConstraint
        ])
        
        NSLayoutConstraint.activate([
            searchView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.0),
            searchView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.0),
            searchView.topAnchor.constraint(equalTo: searchFieldView.bottomAnchor, constant: 16.0),
            searchView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16.0)
        ])
    }

    private func updateConstraintsFor(search isCenter: Bool) {
        NSLayoutConstraint.deactivate([centerYConstraint, topConstraint])
        if isCenter {
            centerYConstraint.isActive = true
        } else {
            topConstraint.isActive = true
        }
        UIView.animate(withDuration: 0.5) {
            self.layoutIfNeeded()
        }
    }

    private func keyboard(hide: Bool) {
        if hide {
            searchFieldView.searchField.resignFirstResponder()
        } else {
            searchFieldView.searchField.becomeFirstResponder()
        }
    }
    
    private func searchView(hide: Bool) {
        UIView.animate(withDuration: 0.5) {
            self.searchView.collectionImageView.alpha = hide ? 0.0 : 1.0
            self.searchView.indicatorLoadingView.alpha = hide ? 0.0 : 1.0
        }
    }
}
