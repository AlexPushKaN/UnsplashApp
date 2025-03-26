//
//  SearchFieldView.swift
//  UnsplashApp
//
//  Created by Александр Муклинов on 08.02.2025.
//

import UIKit

final class SearchFieldView: UIView {
    struct Constants {
        static let placeholder = "Телефоны, яблоки, груши..."
        static let titleTextButton = "Искать"
    }
    private var currentText: String = ""
    lazy var searchField: UITextField = {
        let searchIconView = UIImageView(frame: CGRect(origin: CGPoint(x: 8.0, y: 0.0),
                                                       size: CGSize(width: 20.0, height: 20.0)))
        searchIconView.image = UIImage(systemName: "magnifyingglass")
        searchIconView.contentMode = .scaleAspectFit
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 36.0, height: 20.0))
        containerView.addSubview(searchIconView)
        let textField = UITextField(frame: .zero)
        textField.borderStyle = .none
        textField.placeholder = Constants.placeholder
        textField.leftView = containerView
        textField.leftViewMode = .always
        textField.leftView?.tintColor = .lightGray
        textField.tintColor = .black
        textField.clearButtonMode = .whileEditing
        textField.returnKeyType = .search
        textField.layer.cornerRadius = 12.0
        textField.layer.masksToBounds = true
        return textField
    }()
    lazy var findButton: UIButton = {
        let action = UIAction { [weak self] _ in
            guard let self = self, let text = self.searchField.text, !text.isEmpty else { return }
            state?(.startSearching(text))
            searchFieldPosition?(.top)
        }
        let button = UIButton(frame: .zero, primaryAction: action)
        var config = UIButton.Configuration.filled()
        config.title = Constants.titleTextButton
        config.baseBackgroundColor = .red
        config.baseForegroundColor = .white
        config.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
        button.configuration = config
        button.layer.cornerRadius = 12.0
        button.layer.masksToBounds = true
        return button
    }()
    private var findButtonWidthConstraint: NSLayoutConstraint!
    var state: ((MainView.State) -> Void)?
    var searchFieldPosition: ((MainView.SearchFieldPosition) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        searchField.backgroundColor = .systemGray6
        searchField.delegate = self
        setupUI()
    }
    
    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(searchField)
        addSubview(findButton)
        searchField.translatesAutoresizingMaskIntoConstraints = false
        findButton.translatesAutoresizingMaskIntoConstraints = false
        
        findButtonWidthConstraint = findButton.widthAnchor.constraint(equalToConstant: 0.0)
        NSLayoutConstraint.activate([
            searchField.leadingAnchor.constraint(equalTo: leadingAnchor),
            searchField.trailingAnchor.constraint(equalTo: findButton.leadingAnchor, constant: -8.0),
            searchField.topAnchor.constraint(equalTo: topAnchor),
            searchField.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            findButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            findButton.topAnchor.constraint(equalTo: topAnchor),
            findButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            findButtonWidthConstraint
        ])
    }
    
    private func showFindButton() {
        UIView.animate(withDuration: 0.5) {
            self.findButtonWidthConstraint.constant = self.bounds.width * 0.2
            self.layoutIfNeeded()
        }
    }
    
    func hideFindButton() {
        UIView.animate(withDuration: 0.5) {
            self.findButtonWidthConstraint.constant = 0.0
            self.layoutIfNeeded()
        }
        searchField.resignFirstResponder()
    }
}

//MARK: - UITextFieldDelegate
extension SearchFieldView: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        showFindButton()
        guard let text = textField.text else { return false }
        if !text.isEmpty, currentText == text {
            searchFieldPosition?(.top)
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let text = textField.text, !text.isEmpty else { return false }
        state?(.startSearching(text))
        searchFieldPosition?(.top)
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newText = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? string
        currentText = newText
        if newText.isEmpty {
            searchField.text = newText
            state?(.endSearching)
            searchFieldPosition?(.center)
            hideFindButton()
        }
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        state?(.endSearching)
        searchFieldPosition?(.center)
        hideFindButton()
        return true
    }
}
