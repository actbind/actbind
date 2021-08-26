//
//  MainViewController.swift
//  Actbind
//
//  Created by 柿本　海斗 on 2021/01/31.
//

import AVFoundation
import Photos
import UIKit

protocol MainViewControllerProtocol {
    func onTapScrollToTop()
}

var toHomeView = "off"

final class MainViewController: UITabBarController {
    let userDefaults = UserDefaults(suiteName: "group.com.actbind")
    
    private var currentTabIndex: Int = 0
    
    enum TabNumber: Int {
        case home
        case post
        case menu
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        AppVersionCompare.toAppStoreVersion { type in
            switch type {
            case .latest: break
            case .old:
                DispatchQueue.main.async {
                    let storyBoard = UIStoryboard(name: "Update", bundle: nil)
                    let nextVC = storyBoard.instantiateInitialViewController()
                    self.present(nextVC!, animated: false) {}
                }
            case .error:
                print("エラー")
            }
        }
        
        delegate = self

        if let userDefaults = userDefaults {
            let myColor = userDefaults.string(forKey: "mycolor")

            if myColor == "Original" {
                // TabBarアイコン選択時の色
                UITabBar.appearance().tintColor = UIColor(named: "BlackWhite")
            } else {
                // TabBarアイコン選択時の色
                UITabBar.appearance().tintColor = UIColor(named: myColor!)
            }
        }

        // TabBarバーアイコン非選択時の色を変更
        UITabBar.appearance().unselectedItemTintColor = UIColor.gray
        
        guard let viewControllers = self.viewControllers else {
            return
        }
        // 3ページを格納
        let homeViewController = viewControllers[TabNumber.home.rawValue]
        let postViewController = viewControllers[TabNumber.post.rawValue]
        let menuViewController = viewControllers[TabNumber.menu.rawValue]
                
        // TabBarのボタンの画像のパーツ
        let homeImage = UIImage(named: "home mono")
        let selectedHomeImage = UIImage(named: "home")
        let postImage = UIImage(named: "post mono")
        let selectedPostImage = UIImage(named: "post mono")
        let menuImage = UIImage(named: "menu mono")
        let selectedMenuImage = UIImage(named: "menu")
                
        // それぞれのViewControllerのボタン(TabBarItem)に用意した画像を設定
        homeViewController.tabBarItem = UITabBarItem(title: "", image: homeImage, selectedImage: selectedHomeImage)
        postViewController.tabBarItem = UITabBarItem(title: "", image: postImage, selectedImage: selectedPostImage)
        menuViewController.tabBarItem = UITabBarItem(title: "", image: menuImage, selectedImage: selectedMenuImage)
    }
}

extension MainViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        UISelectionFeedbackGenerator().selectionChanged()
        
        // viewControllerをas?でUINavigationControllerに
        if let nav = (viewController as? UINavigationController) {
            if nav.topViewController is PostCameraViewController {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    if let userDefaults = self.userDefaults {
                        userDefaults.setValue(0, forKeyPath: "camerafrontback")
                        userDefaults.setValue(0, forKeyPath: "flashonoff")
                    }
                
                    if AVCaptureDevice.authorizationStatus(for: AVMediaType.video) == .authorized {
                        if PHPhotoLibrary.authorizationStatus() != .notDetermined, PHPhotoLibrary.authorizationStatus() != .restricted, PHPhotoLibrary.authorizationStatus() != .denied {
                            let storyBoard = UIStoryboard(name: "PostCamera", bundle: nil)
                            let nextVC = storyBoard.instantiateInitialViewController()
                            self.present(nextVC!, animated: true) {}
                        } else {
                            let storyBoard = UIStoryboard(name: "CameraAndCamerarollAuthorization", bundle: nil)
                            let nextVC = storyBoard.instantiateInitialViewController()
                            let nav = (nextVC as? UINavigationController)
                            let vc = (nav?.topViewController as! CameraAndCamerarollAuthorizationViewController)
                        
                            // 値の設定
                            vc.nextvcname = "PostCamera"
                        
                            self.present(nextVC!, animated: true) {}
                        }
                    } else {
                        let storyBoard = UIStoryboard(name: "CameraAndCamerarollAuthorization", bundle: nil)
                        let nextVC = storyBoard.instantiateInitialViewController()
                        let nav = (nextVC as? UINavigationController)
                        let vc = (nav?.topViewController as! CameraAndCamerarollAuthorizationViewController)
                    
                        // 値の設定
                        vc.nextvcname = "PostCamera"
                    
                        self.present(nextVC!, animated: true) {}
                    }
                }
                
                return false
            }
        }
        return true
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        // viewControllerをas?でUINavigationControllerに
        if let nav = (viewController as? UINavigationController) {
            // MainViewControllerProtocolに
            if let vc = (nav.topViewController as? MainViewControllerProtocol) {
                // currentTabIndex（前のViewのIndex）とタップされた時のIndexが同じ時に実行
                if currentTabIndex == tabBarController.selectedIndex {
                    vc.onTapScrollToTop()
                }
                
                currentTabIndex = tabBarController.selectedIndex
            }
        }
    }
}
