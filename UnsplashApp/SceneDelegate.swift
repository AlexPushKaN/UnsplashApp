//
//  SceneDelegate.swift
//  UnsplashApp
//
//  Created by Александр Муклинов on 08.02.2025.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "UnsplashAccessKey") as? String else {
            fatalError("Access key for Unsplash.com not found in Info.plist")
        }
        guard let scene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: scene)
        window.rootViewController = ViewControllerFactory.createMainController(access: key)
        window.makeKeyAndVisible()
        self.window = window
    }
}
