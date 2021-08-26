//
//  ProfileEditViewController.swift
//  Actbind
//
//  Created by 柿本海斗 on 2021/03/02.
//

import AVFoundation
import Nuke
import Photos
import UIKit

class ProfileEditViewController: UIViewController, UIGestureRecognizerDelegate {
    let userDefaults = UserDefaults(suiteName: "group.com.actbind")
    let api = KeyManager().getValue(key: "API") as? String
    
    @IBOutlet weak var navigationBarTitle: UINavigationItem!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var userProfileImageTitleLabel: UILabel!
    @IBOutlet weak var userProfileImageEditButton: UIButton!
    @IBOutlet var tapGesture: UITapGestureRecognizer!
    @IBOutlet weak var userProfileImage: UIImageView!
    @IBOutlet weak var bioTitleLabel: UILabel!
    @IBOutlet weak var bioEditButton: UIButton!
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var bioButton: UIButton!
    @IBOutlet weak var websiteTitleLabel: UILabel!
    @IBOutlet weak var websiteEditButton: UIButton!
    @IBOutlet weak var websiteLabel: UILabel!
    @IBOutlet weak var websiteButton: UIButton!
    @IBOutlet weak var activityView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var checkmarkImage: UIImageView!
    @IBOutlet weak var activityLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
        navigationBarTitle.title = "purofi-ruwohennsyuu".localized()

        if let userDefaults = userDefaults {
            let myColor = userDefaults.string(forKey: "mycolor")

            if myColor == "Original" {
                backButton.tintColor = UIColor(named: "BlackWhite")
                userProfileImageEditButton.setTitleColor(UIColor(named: "Blue"), for: .normal)
                bioEditButton.setTitleColor(UIColor(named: "Blue"), for: .normal)
                websiteEditButton.setTitleColor(UIColor(named: "Blue"), for: .normal)
            } else {
                backButton.tintColor = UIColor(named: myColor!)
                userProfileImageEditButton.setTitleColor(UIColor(named: myColor!), for: .normal)
                bioEditButton.setTitleColor(UIColor(named: myColor!), for: .normal)
                websiteEditButton.setTitleColor(UIColor(named: myColor!), for: .normal)
            }
        }

        backButton.image = UIImage(named: "back")
        
        userProfileImageTitleLabel.text = "purofi-rusyasinn".localized()
        userProfileImageEditButton.setTitle("hennsyuu".localized(), for: .normal)
        userProfileImage.cornerAll(value: 0, fulcrum: "")
        
        bioTitleLabel.text = "jikosyoukai".localized()
        bioEditButton.setTitle("hennsyuu".localized(), for: .normal)
        
        websiteTitleLabel.text = "webusaito".localized()
        websiteEditButton.setTitle("hennsyuu".localized(), for: .normal)
        
        activityView.cornerAll(value: 16, fulcrum: "")
        activityView.isHidden = true
        
        checkmarkImage.image = UIImage(named: "")
        activityLabel.text = "hennkounaiyousetteityuu".localized()
    }
    
    // 画面に表示される直前に呼ばれます。
    // viewDidLoadとは異なり毎回呼び出されます。
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if toHomeView == "on" {
            let UINavigationController = tabBarController?.viewControllers?[0]
            tabBarController?.selectedViewController = UINavigationController
        }

        if let userDefaults = userDefaults {
            let userName = userDefaults.string(forKey: "username")!
            let profileimage = userDefaults.string(forKey: "profileimage")
            let bio = userDefaults.string(forKey: "bio")
            let website = userDefaults.string(forKey: "website")
            
            if profileimage == "Default" {
                userProfileImage.image = UIImage(named: "defaultProfileImage")
            } else {
                let profileImageUrlString = "https://www.actbind.com/" + userName + "/profile-image/" + profileimage!
                let userProfileImageURL = URL(string: profileImageUrlString)!
                Nuke.loadImage(with: userProfileImageURL, into: userProfileImage)
            }

            if bio == "" {
                bioLabel.text = ""
                bioButton.setTitle("jikosyoukai".localized(), for: .normal)
            } else {
                bioLabel.text = bio
                bioButton.setTitle("", for: .normal)
            }
            
            if website == "" {
                websiteLabel.text = ""
                websiteButton.setTitle("webusaito".localized(), for: .normal)
            } else {
                websiteLabel.text = website
                websiteButton.setTitle("", for: .normal)
            }
        }
        
        bioButton.setTitleColor(UIColor(named: "TextFieldText"), for: .normal)
        
        websiteButton.setTitleColor(UIColor(named: "TextFieldText"), for: .normal)
    }
    
    @IBAction func userProfileImageEditButtonTouchDown(_ sender: Any) {
        if let userDefaults = userDefaults {
            let myColor = userDefaults.string(forKey: "mycolor")

            if myColor == "Original" {
                userProfileImageEditButton.backgroundColor = UIColor(named: "BlueHalf")
            } else if myColor == "Red" {
                userProfileImageEditButton.backgroundColor = UIColor(named: "RedHalf")
            } else if myColor == "Orange" {
                userProfileImageEditButton.backgroundColor = UIColor(named: "OrangeHalf")
            } else if myColor == "Yellow" {
                userProfileImageEditButton.backgroundColor = UIColor(named: "YellowHalf")
            } else if myColor == "Green" {
                userProfileImageEditButton.backgroundColor = UIColor(named: "GreenHalf")
            } else if myColor == "Blue" {
                userProfileImageEditButton.backgroundColor = UIColor(named: "BlueHalf")
            } else {
                userProfileImageEditButton.backgroundColor = UIColor(named: "PurpleHalf")
            }
        }
    }
    
    @IBAction func userProfileImageEditButtonTouchDragOutside(_ sender: Any) {
        userProfileImageEditButton.backgroundColor = UIColor.clear
    }
    
    @IBAction func userProfileImageEditButtonTouchUpInside(_ sender: Any) {
        UISelectionFeedbackGenerator().selectionChanged()
        
        userProfileImageEditButton.backgroundColor = UIColor.clear

        let alertText = "purofi-rusyasinnhennkou".localized()
        let takePhotoText = "syasinnwotoru".localized()
        let removePhotoText = "gennzainosyasinnwosakujyo".localized()
        let cancelText = "kyannseru".localized()

        let alertController = UIAlertController(title: alertText, message: nil, preferredStyle: .actionSheet)

        let takePhotoButton = UIAlertAction(title: takePhotoText, style: .default, handler: { _ in
            if let userDefaults = self.userDefaults {
                userDefaults.setValue(0, forKeyPath: "camerafrontback")
                userDefaults.setValue(0, forKeyPath: "flashonoff")
            }
            
            if AVCaptureDevice.authorizationStatus(for: AVMediaType.video) == .authorized {
                if PHPhotoLibrary.authorizationStatus() != .notDetermined, PHPhotoLibrary.authorizationStatus() != .restricted, PHPhotoLibrary.authorizationStatus() != .denied {
                    let storyBoard = UIStoryboard(name: "ProfileImageCamera", bundle: nil)
                    let nextVC = storyBoard.instantiateInitialViewController()
                    self.present(nextVC!, animated: true) {}
                } else {
                    let storyBoard = UIStoryboard(name: "CameraAndCamerarollAuthorization", bundle: nil)
                    let nextVC = storyBoard.instantiateInitialViewController()
                    let nav = (nextVC as? UINavigationController)
                    let vc = (nav?.topViewController as! CameraAndCamerarollAuthorizationViewController)
                    
                    // 値の設定
                    vc.nextvcname = "ProfileImageCamera"
                    
                    self.present(nextVC!, animated: true) {}
                }
            } else {
                let storyBoard = UIStoryboard(name: "CameraAndCamerarollAuthorization", bundle: nil)
                let nextVC = storyBoard.instantiateInitialViewController()
                let nav = (nextVC as? UINavigationController)
                let vc = (nav?.topViewController as! CameraAndCamerarollAuthorizationViewController)
                
                // 値の設定
                vc.nextvcname = "ProfileImageCamera"
                
                self.present(nextVC!, animated: true) {}
            }
        })
        let removePhotoButton = UIAlertAction(title: removePhotoText, style: .default, handler: { _ in
            let alertText = "gennzainosyasinnwosakujyosimasuka".localized()
            let removeText = "sakujyo".localized()
            let cancelText = "kyannseru".localized()

            let alertController = UIAlertController(title: alertText, message: nil, preferredStyle: .alert)

            let removeButton = UIAlertAction(title: removeText, style: .destructive, handler: { _ in
                if let userDefaults = self.userDefaults {
                    let profileImage = userDefaults.string(forKey: "profileimage")
                    
                    if profileImage != "Default" {
                        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
                        self.backButton.isEnabled = false
                        self.userProfileImageEditButton.isEnabled = false
                        self.tapGesture.isEnabled = false
                        self.bioEditButton.isEnabled = false
                        self.bioButton.isEnabled = false

                        self.activityView.isHidden = false
                        self.activityIndicator.startAnimating()

                        // データ登録・更新
                        if let userDefaults = self.userDefaults {
                            let userId = userDefaults.integer(forKey: "userid")
                            self.apiProfileImage(userId: userId)
                        }
                    }
                }
            })
            let cancelButton = UIAlertAction(title: cancelText, style: .cancel, handler: nil)

            alertController.view.tintColor = UIColor(named: "BlackWhite")
            alertController.addAction(removeButton)
            alertController.addAction(cancelButton)

            self.present(alertController, animated: true, completion: nil)
        })
        let cancelButton = UIAlertAction(title: cancelText, style: .cancel, handler: nil)

        alertController.view.tintColor = UIColor(named: "BlackWhite")
        alertController.addAction(takePhotoButton)
        alertController.addAction(removePhotoButton)
        alertController.addAction(cancelButton)

        alertController.popoverPresentationController?.sourceView = view
        let screenSize = UIScreen.main.bounds
        // ここで表示位置を調整
        // xは画面中央、yは画面下部になる様に指定
        alertController.popoverPresentationController?.sourceRect = CGRect(x: screenSize.size.width / 2, y: screenSize.size.height, width: 0, height: 0)

        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func tapGesture(_ sender: Any) {
        UISelectionFeedbackGenerator().selectionChanged()
        
        UserDefaults.standard.set("Off", forKey: "flashonoff")
        
        let alertText = "purofi-rusyasinnhennkou".localized()
        let takePhotoText = "syasinnwotoru".localized()
        let removePhotoText = "gennzainosyasinnwosakujyo".localized()
        let cancelText = "kyannseru".localized()

        let alertController = UIAlertController(title: alertText, message: nil, preferredStyle: .actionSheet)

        let takePhotoButton = UIAlertAction(title: takePhotoText, style: .default, handler: { _ in
            if let userDefaults = self.userDefaults {
                userDefaults.setValue(0, forKeyPath: "camerafrontback")
                userDefaults.setValue(0, forKeyPath: "flashonoff")
            }
            
            if AVCaptureDevice.authorizationStatus(for: AVMediaType.video) == .authorized {
                if PHPhotoLibrary.authorizationStatus() != .notDetermined, PHPhotoLibrary.authorizationStatus() != .restricted, PHPhotoLibrary.authorizationStatus() != .denied {
                    let storyBoard = UIStoryboard(name: "ProfileImageCamera", bundle: nil)
                    let nextVC = storyBoard.instantiateInitialViewController()
                    self.present(nextVC!, animated: true) {}
                } else {
                    let storyBoard = UIStoryboard(name: "CameraAndCamerarollAuthorization", bundle: nil)
                    let nextVC = storyBoard.instantiateInitialViewController()
                    let nav = (nextVC as? UINavigationController)
                    let vc = (nav?.topViewController as! CameraAndCamerarollAuthorizationViewController)
                    
                    // 値の設定
                    vc.nextvcname = "ProfileImageCamera"
                    
                    self.present(nextVC!, animated: true) {}
                }
            } else {
                let storyBoard = UIStoryboard(name: "CameraAndCamerarollAuthorization", bundle: nil)
                let nextVC = storyBoard.instantiateInitialViewController()
                let nav = (nextVC as? UINavigationController)
                let vc = (nav?.topViewController as! CameraAndCamerarollAuthorizationViewController)
                
                // 値の設定
                vc.nextvcname = "ProfileImageCamera"
                
                self.present(nextVC!, animated: true) {}
            }
        })
        let removePhotoButton = UIAlertAction(title: removePhotoText, style: .default, handler: { _ in
            let alertText = "gennzainosyasinnwosakujyosimasuka".localized()
            let removeText = "sakujyo".localized()
            let cancelText = "kyannseru".localized()

            let alertController = UIAlertController(title: alertText, message: nil, preferredStyle: .alert)

            let removeButton = UIAlertAction(title: removeText, style: .destructive, handler: { _ in
                if let userDefaults = self.userDefaults {
                    let profileImage = userDefaults.string(forKey: "profileimage")
                    
                    if profileImage != "Default" {
                        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
                        self.backButton.isEnabled = false
                        self.userProfileImageEditButton.isEnabled = false
                        self.tapGesture.isEnabled = false
                        self.bioEditButton.isEnabled = false
                        self.bioButton.isEnabled = false

                        self.activityView.isHidden = false
                        self.activityIndicator.startAnimating()

                        // データ登録・更新
                        if let userDefaults = self.userDefaults {
                            let userId = userDefaults.integer(forKey: "userid")
                            self.apiProfileImage(userId: userId)
                        }
                    }
                }
            })
            let cancelButton = UIAlertAction(title: cancelText, style: .cancel, handler: nil)

            alertController.view.tintColor = UIColor(named: "BlackWhite")
            alertController.addAction(removeButton)
            alertController.addAction(cancelButton)

            self.present(alertController, animated: true, completion: nil)
        })
        let cancelButton = UIAlertAction(title: cancelText, style: .cancel, handler: nil)

        alertController.view.tintColor = UIColor(named: "BlackWhite")
        alertController.addAction(takePhotoButton)
        alertController.addAction(removePhotoButton)
        alertController.addAction(cancelButton)

        alertController.popoverPresentationController?.sourceView = view
        let screenSize = UIScreen.main.bounds
        // ここで表示位置を調整
        // xは画面中央、yは画面下部になる様に指定
        alertController.popoverPresentationController?.sourceRect = CGRect(x: screenSize.size.width / 2, y: screenSize.size.height, width: 0, height: 0)

        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func bioEditButtonTouchDown(_ sender: Any) {
        if let userDefaults = userDefaults {
            let myColor = userDefaults.string(forKey: "mycolor")

            if myColor == "Original" {
                bioEditButton.backgroundColor = UIColor(named: "BlueHalf")
            } else if myColor == "Red" {
                bioEditButton.backgroundColor = UIColor(named: "RedHalf")
            } else if myColor == "Orange" {
                bioEditButton.backgroundColor = UIColor(named: "OrangeHalf")
            } else if myColor == "Yellow" {
                bioEditButton.backgroundColor = UIColor(named: "YellowHalf")
            } else if myColor == "Green" {
                bioEditButton.backgroundColor = UIColor(named: "GreenHalf")
            } else if myColor == "Blue" {
                bioEditButton.backgroundColor = UIColor(named: "BlueHalf")
            } else {
                bioEditButton.backgroundColor = UIColor(named: "PurpleHalf")
            }
        }
    }
    
    @IBAction func bioEditButtonTouchDragOutside(_ sender: Any) {
        bioEditButton.backgroundColor = UIColor.clear
    }
    
    @IBAction func bioEditButtonTouchUpInside(_ sender: Any) {
        UISelectionFeedbackGenerator().selectionChanged()
        
        bioEditButton.backgroundColor = UIColor.clear
        
        let storyBoard = UIStoryboard(name: "BioEdit", bundle: nil)
        let nextVC = storyBoard.instantiateInitialViewController()
        
        navigationController?.pushViewController(nextVC!, animated: true)
    }
    
    @IBAction func bioButtonTouchUpInside(_ sender: Any) {
        UISelectionFeedbackGenerator().selectionChanged()
        
        let storyBoard = UIStoryboard(name: "BioEdit", bundle: nil)
        let nextVC = storyBoard.instantiateInitialViewController()
        
        navigationController?.pushViewController(nextVC!, animated: true)
    }
    
    @IBAction func websiteEditButtonTouchDown(_ sender: Any) {
        if let userDefaults = userDefaults {
            let myColor = userDefaults.string(forKey: "mycolor")

            if myColor == "Original" {
                websiteEditButton.backgroundColor = UIColor(named: "BlueHalf")
            } else if myColor == "Red" {
                websiteEditButton.backgroundColor = UIColor(named: "RedHalf")
            } else if myColor == "Orange" {
                websiteEditButton.backgroundColor = UIColor(named: "OrangeHalf")
            } else if myColor == "Yellow" {
                websiteEditButton.backgroundColor = UIColor(named: "YellowHalf")
            } else if myColor == "Green" {
                websiteEditButton.backgroundColor = UIColor(named: "GreenHalf")
            } else if myColor == "Blue" {
                websiteEditButton.backgroundColor = UIColor(named: "BlueHalf")
            } else {
                websiteEditButton.backgroundColor = UIColor(named: "PurpleHalf")
            }
        }
    }
    
    @IBAction func websiteEditButtonTouchDragOutside(_ sender: Any) {
        websiteEditButton.backgroundColor = UIColor.clear
    }
    
    @IBAction func websiteEditButtonTouchUpInside(_ sender: Any) {
        UISelectionFeedbackGenerator().selectionChanged()
        
        websiteEditButton.backgroundColor = UIColor.clear
        
        let storyBoard = UIStoryboard(name: "WebsiteEdit", bundle: nil)
        let nextVC = storyBoard.instantiateInitialViewController()
        
        navigationController?.pushViewController(nextVC!, animated: true)
    }
    
    @IBAction func websiteButtonTouchUpInside(_ sender: Any) {
        UISelectionFeedbackGenerator().selectionChanged()
        
        let storyBoard = UIStoryboard(name: "WebsiteEdit", bundle: nil)
        let nextVC = storyBoard.instantiateInitialViewController()
        
        navigationController?.pushViewController(nextVC!, animated: true)
    }
    
    @IBAction func backBottonAction(_ sender: Any) {
        UISelectionFeedbackGenerator().selectionChanged()
        
        navigationController?.popViewController(animated: true)
    }
    
    func apiProfileImage(userId: Int) {
        let url = URL(string: api! + "userchange")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST" // Postリクエストを送る(このコードがないとGetリクエストになる)
        request.addValue("application/json", forHTTPHeaderField: "content-type")
        // request.addValue("", forHTTPHeaderField: "authorization") //APIKey
        
        // 構造体を作成
        struct UserChange: Codable {
            let changeKey: String
            let userId: Int
            let profileImage: String
        }
        
        let encoder = JSONEncoder()
        
        let body = UserChange(changeKey: "profileImage", userId: userId, profileImage: "Default")
        
        do {
            // EncodeしてhttpBodyに設定
            let data = try encoder.encode(body)
            request.httpBody = data
        } catch let encodeError as NSError {
            print("Encoder error: \(encodeError.localizedDescription)")
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in

            // ここのエラーはクライアントサイドのエラー(ホストに接続できないなど)
            if let error = error {
                DispatchQueue.main.async {
                    print("クライアントエラー: \(error.localizedDescription)")
                    self.apiError()
                }
            }

            guard let data = data, let response = response as? HTTPURLResponse else {
                print("no data or no response")
                return
            }

            if response.statusCode == 200 {
                let json = String(data: data, encoding: .utf8)!
                print(json)
                DispatchQueue.main.async {
                    if let userDefaults = self.userDefaults {
                        userDefaults.setValue("Default", forKeyPath: "profileimage")
                        
                        self.userProfileImage.image = UIImage(named: "defaultProfileImage")
                    }
                    
                    self.apiSuccess()
                }
            } else {
                DispatchQueue.main.async {
                    // レスポンスのステータスコードが200でない場合などはサーバサイドエラー
                    print("サーバエラー ステータスコード: \(response.statusCode)")
                    self.apiError()
                }
            }
        }
        task.resume()
    }
    
    func apiSuccess() {
        activityIndicator.stopAnimating()
        checkmarkImage.image = UIImage(named: "success")
        activityLabel.text = "hennkounaiyouhozonn".localized()
        
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.checkmarkImage.image = UIImage(named: "")
            
            self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
            self.backButton.isEnabled = true
            self.userProfileImageEditButton.isEnabled = true
            self.tapGesture.isEnabled = true
            self.bioEditButton.isEnabled = true
            self.bioButton.isEnabled = true

            self.activityView.isHidden = true
        }
    }
    
    func apiError() {
        activityIndicator.stopAnimating()
        checkmarkImage.image = UIImage(named: "error")
        activityLabel.text = "era-".localized()
        
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.checkmarkImage.image = UIImage(named: "")
            
            self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
            self.backButton.isEnabled = true
            self.userProfileImageEditButton.isEnabled = true
            self.tapGesture.isEnabled = true
            self.bioEditButton.isEnabled = true
            self.bioButton.isEnabled = true

            self.activityView.isHidden = true
        }
    }
}
