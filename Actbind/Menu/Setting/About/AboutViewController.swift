//
//  AboutViewController.swift
//  Actbind
//
//  Created by 柿本　海斗 on 2020/12/02.
//

import UIKit

final class AboutViewController: UIViewController, UIGestureRecognizerDelegate {
    let userDefaults = UserDefaults(suiteName: "group.com.actbind")
    
    let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    
    @IBOutlet weak var navigationBarTitle: UINavigationItem!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var termsOfServiceView: UIView!
    @IBOutlet weak var termsOfServiceLabel: UILabel!
    @IBOutlet weak var nextImage1: UIImageView!
    @IBOutlet weak var privacyPolicyLabel: UILabel!
    @IBOutlet weak var nextImage2: UIImageView!
    @IBOutlet weak var communityGuidelinesView: UIView!
    @IBOutlet weak var communityGuidelinesLabel: UILabel!
    @IBOutlet weak var nextImage3: UIImageView!
    @IBOutlet weak var openSourceLibraryView: UIView!
    @IBOutlet weak var openSourceLibraryLabel: UILabel!
    @IBOutlet weak var nextImage4: UIImageView!
    @IBOutlet weak var versionText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
        navigationBarTitle.title = "actbindnituite".localized()

        if let userDefaults = userDefaults {
            let myColor = userDefaults.string(forKey: "mycolor")

            if myColor == "Original" {
                backButton.tintColor = UIColor(named: "BlackWhite")
            } else {
                backButton.tintColor = UIColor(named: myColor!)
            }

            if myColor == "Original" {
                nextImage1.image = UIImage(named: "defaultNext")
                nextImage2.image = UIImage(named: "defaultNext")
                nextImage3.image = UIImage(named: "defaultNext")
                nextImage4.image = UIImage(named: "defaultNext")
            } else if myColor == "Red" {
                nextImage1.image = UIImage(named: "redNext")
                nextImage2.image = UIImage(named: "redNext")
                nextImage3.image = UIImage(named: "redNext")
                nextImage4.image = UIImage(named: "redNext")
            } else if myColor == "Orange" {
                nextImage1.image = UIImage(named: "orangeNext")
                nextImage2.image = UIImage(named: "orangeNext")
                nextImage3.image = UIImage(named: "orangeNext")
                nextImage4.image = UIImage(named: "orangeNext")
            } else if myColor == "Yellow" {
                nextImage1.image = UIImage(named: "yellowNext")
                nextImage2.image = UIImage(named: "yellowNext")
                nextImage3.image = UIImage(named: "yellowNext")
                nextImage4.image = UIImage(named: "yellowNext")
            } else if myColor == "Green" {
                nextImage1.image = UIImage(named: "greenNext")
                nextImage2.image = UIImage(named: "greenNext")
                nextImage3.image = UIImage(named: "greenNext")
                nextImage4.image = UIImage(named: "greenNext")
            } else if myColor == "Blue" {
                nextImage1.image = UIImage(named: "blueNext")
                nextImage2.image = UIImage(named: "blueNext")
                nextImage3.image = UIImage(named: "blueNext")
                nextImage4.image = UIImage(named: "blueNext")
            } else {
                nextImage1.image = UIImage(named: "purpleNext")
                nextImage2.image = UIImage(named: "purpleNext")
                nextImage3.image = UIImage(named: "purpleNext")
                nextImage4.image = UIImage(named: "purpleNext")
            }
        }
        
        backButton.image = UIImage(named: "back")
        
        termsOfServiceView.cornerPart(value: 16, fulcrum: "", Location: [.layerMinXMinYCorner, .layerMaxXMinYCorner])
        communityGuidelinesView.cornerPart(value: 16, fulcrum: "", Location: [.layerMinXMaxYCorner, .layerMaxXMaxYCorner])
        openSourceLibraryView.cornerAll(value: 16, fulcrum: "")
        
        termsOfServiceLabel.text = "riyoukiyaku".localized()
        privacyPolicyLabel.text = "puraibasi-porisi-".localized()
        communityGuidelinesLabel.text = "komyunitexigaidorainn".localized()
        openSourceLibraryLabel.text = "o-punnso-suraiburari".localized()
        
        AppTypeCompare.toAppStoreVersion { type in
            switch type {
            case .release:
                DispatchQueue.main.async {
                    self.versionText.text = "ba-jyonn".localized() + " " + self.version
                }
            case .beta:
                DispatchQueue.main.async {
                    self.versionText.text = "ba-jyonn".localized() + " " + self.version + " (Beta)"
                }
            case .error:
                print("エラー")
            }
        }
    }
    
    // 画面に表示される直前に呼ばれます。
    // viewDidLoadとは異なり毎回呼び出されます。
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if toHomeView == "on" {
            let UINavigationController = tabBarController?.viewControllers?[0]
            tabBarController?.selectedViewController = UINavigationController
        }
    }
    
    @IBAction func termsOfServiceButtonTouchUpInside(_ sender: Any) {
        UISelectionFeedbackGenerator().selectionChanged()
        
        let storyBoard = UIStoryboard(name: "AboutActbindWeb", bundle: nil)
        let nextVC = storyBoard.instantiateInitialViewController()
        let nav = (nextVC as? UINavigationController)
        let vc = (nav?.topViewController as! AboutActbindWebViewController)
        
        // 値の設定
        if "language".localized() == "Japanese" {
            vc.weburl = "https://policy.actbind.com/ja/terms"
        } else {
            vc.weburl = "https://policy.actbind.com/terms"
        }
        
        present(nextVC!, animated: true) {}
    }
    
    @IBAction func privacyPolicyButtonTouchUpInside(_ sender: Any) {
        UISelectionFeedbackGenerator().selectionChanged()
        
        let storyBoard = UIStoryboard(name: "AboutActbindWeb", bundle: nil)
        let nextVC = storyBoard.instantiateInitialViewController()
        let nav = (nextVC as? UINavigationController)
        let vc = (nav?.topViewController as! AboutActbindWebViewController)
        
        // 値の設定
        if "language".localized() == "Japanese" {
            vc.weburl = "https://policy.actbind.com/ja/privacy"
        } else {
            vc.weburl = "https://policy.actbind.com/privacy"
        }
        
        present(nextVC!, animated: true) {}
    }
    
    @IBAction func communityGuidelinesButtonTouchUpInside(_ sender: Any) {
        UISelectionFeedbackGenerator().selectionChanged()
        
        let storyBoard = UIStoryboard(name: "AboutActbindWeb", bundle: nil)
        let nextVC = storyBoard.instantiateInitialViewController()
        let nav = (nextVC as? UINavigationController)
        let vc = (nav?.topViewController as! AboutActbindWebViewController)
        
        // 値の設定
        if "language".localized() == "Japanese" {
            vc.weburl = "https://policy.actbind.com/ja/community-guidelines/"
        } else {
            vc.weburl = "https://policy.actbind.com/community-guidelines/"
        }
        
        present(nextVC!, animated: true) {}
    }
    
    @IBAction func openSourceLibraryButtonTouchUpInside(_ sender: Any) {
        UISelectionFeedbackGenerator().selectionChanged()
        
        let storyBoard = UIStoryboard(name: "OpenSourceLibraryWeb", bundle: nil)
        let nextVC = storyBoard.instantiateInitialViewController()
        
        present(nextVC!, animated: true) {}
    }
    
    @IBAction func backBottonAction(_ sender: Any) {
        UISelectionFeedbackGenerator().selectionChanged()
        
        navigationController?.popViewController(animated: true)
    }
}
