//
//  SceneDelegate.swift
//  Actbind
//
//  Created by 柿本海斗 on 2021/03/09.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    let userDefaults = UserDefaults(suiteName: "group.com.actbind")

    // Sceneが呼ばれたとき
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
        
        if let userDefaults = self.userDefaults {
            let loginrecord = userDefaults.bool(forKey: "loginrecord")

            if !loginrecord {
                let window = UIWindow(windowScene: scene as! UIWindowScene)
                self.window = window
                window.makeKeyAndVisible()
        
                let storyboard = UIStoryboard(name: "LogIn", bundle: nil)
                let viewController = storyboard.instantiateViewController(identifier: "LogIn")
                window.rootViewController = viewController
            } else {
                let window = UIWindow(windowScene: scene as! UIWindowScene)
                self.window = window
                window.makeKeyAndVisible()
        
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let viewController = storyboard.instantiateViewController(identifier: "Main")
                window.rootViewController = viewController
            }
        }
    }

    // Sceneが閉じたとき
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    // Sceneがactiveになったとき
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    // Sceneがinactiveになったとき
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    // Sceneがforegroundになったとき
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    // Sceneがbackgroundになったとき
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
}
