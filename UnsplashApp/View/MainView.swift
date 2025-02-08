//
//  MainView.swift
//  UnsplashApp
//
//  Created by Александр Муклинов on 08.02.2025.
//

import UIKit

final class MainView: UIView, MainControllerProtocol {

    enum SearchFieldPosition  {
        case top
        case center
    }
    
    enum State {
        case startSearching(String)
        case endSearching
    }
    
    private lazy var searchFieldView = SearchFieldView()
    lazy var searchView: UIView & CommunicationProtocolDelegate = SearchView()
    var inputedText: ((String?) -> Void)?
    
    private var centerYConstraint: NSLayoutConstraint!
    private var topConstraint: NSLayoutConstraint!

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        
        searchFieldView.searchFieldPosition = { [weak self] position in
            guard let self else { return }
            switch position {
            case .top:
                updateConstraintsForSearch(isCenter: false)
                searchView(hide: false)
                keyboard(hide: false)
            case .center:
                updateConstraintsForSearch(isCenter: true)
                keyboard(hide: false)
                searchView(hide: true)
            }
        }
        
        searchFieldView.state = { [weak self] currentState in
            guard let self else { return }
            switch currentState {
            case .startSearching(let text):
                searchView.indicator(activate: true)
                inputedText?(text)
            case .endSearching:
                searchView.indicator(activate: false)
                inputedText?(nil)
                searchView.labelNoResults(show: false)
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
        searchFieldView.searchFieldPosition?(.center)
        searchFieldView.hideFindButton()
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

    private func updateConstraintsForSearch(isCenter: Bool) {
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
            searchFieldView.searchField.becomeFirstResponder()
        } else {
            searchFieldView.searchField.resignFirstResponder()
        }
    }
    
    private func searchView(hide: Bool) {
        UIView.animate(withDuration: 0.5) {
            self.searchView.collectionImageView.alpha = hide ? 0.0 : 1.0
            self.searchView.indicatorLoadingView.alpha = hide ? 0.0 : 1.0
        }
    }
}
