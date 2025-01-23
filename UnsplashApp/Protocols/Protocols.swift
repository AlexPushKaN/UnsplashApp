//
//  Protocols.swift
//  UnsplashApp
//
//  Created by Александр Муклинов on 19.01.2025.
//

import UIKit

protocol CommunicationProtocolDelegate: AnyObject {
    var indicatorLoadingView: UIActivityIndicatorView { get set }
    var collectionImageView: UICollectionView { get set }
    func indicator(activate: Bool)
    func labelNoResults(show: Bool)
}

protocol CommunicationProtocol: AnyObject {
    var inputedText: ((String?) -> Void)? { get set }
    var searchView: UIView & CommunicationProtocolDelegate { get }
}

protocol CloseViewControllerDelegate: AnyObject {
    func close(viewController: UIViewController)
}
