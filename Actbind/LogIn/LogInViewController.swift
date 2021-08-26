//
//  LogInViewController.swift
//  Actbind
//
//  Created by 柿本　海斗 on 2020/12/17.
//

import AudioToolbox
import UIKit

final class LogInViewController: UIViewController {
    let userDefaults = UserDefaults(suiteName: "group.com.actbind")
    let api = KeyManager().getValue(key: "API") as? String

    @IBOutlet weak var mailAddressTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var logInButtonRight: NSLayoutConstraint!
    @IBOutlet weak var logInButtonLeft: NSLayoutConstraint!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var signUpButtonRight: NSLayoutConstraint!
    @IBOutlet weak var signUpButtonLeft: NSLayoutConstraint!
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var errorViewBottom: NSLayoutConstraint!

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
        
        mailAddressTextField.uiTextFieldSetting(placeholder: "me-ruadoresu".localized())

        passwordTextField.uiTextFieldSetting(placeholder: "pasuwa-do".localized())

        errorViewBottom.constant = -60

        logInButton.setTitle("roguinn".localized(), for: .normal)

        signUpButton.setTitle("atarasiiakaunntowosakusei".localized(), for: .normal)
    }

    // キーボード以外をタップでキーボードが閉じる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

    // 完了キーをタップでキーボードが閉じる
    @IBAction func mailAddressTextFieldDidEndOnExit(_ sender: Any) {}

    @IBAction func mailAddressTextFieldEditingChanged(_ sender: Any) {
        // passwordTextFieldに入力された文字数を取得
        let passwordCount = passwordTextField.text!.count

        // パスワードが8文字以上の時
        if passwordCount >= 8 {
            // mailAddressTextFieldが入力されていない時
            if mailAddressTextField.text == "" {
                logInButton.isEnabled = false
                logInButton.setTitleColor(UIColor(named: "EnabledButtonText"), for: .normal)
                logInButton.backgroundColor = UIColor(named: "EnabledButton")
                // mailAddressTextFieldが入力されている時
            } else {
                logInButton.isEnabled = true
                logInButton.setTitleColor(UIColor(named: "White"), for: .normal)
                logInButton.backgroundColor = UIColor(named: "Blue")
            }
            // パスワードが8文字未満の時
        } else {
            logInButton.isEnabled = false
            logInButton.setTitleColor(UIColor(named: "EnabledButtonText"), for: .normal)
            logInButton.backgroundColor = UIColor(named: "EnabledButton")
        }
    }

    @IBAction func mailAddressTextFieldEditingDidBegin(_ sender: Any) {
        mailAddressTextField.layer.borderColor = UIColor.systemBlue.cgColor
        passwordTextField.layer.borderColor = UIColor.lightGray.cgColor
    }

    @IBAction func mailAddressTextFieldEditingDidEnd(_ sender: Any) {
        mailAddressTextField.layer.borderColor = UIColor.lightGray.cgColor
    }

    // 完了キーをタップでキーボードが閉じる
    @IBAction func passwordTextFieldDidEndOnExit(_ sender: Any) {}

    @IBAction func passwordTextFieldEditingChanged(_ sender: Any) {
        // passwordTextFieldに入力された文字数を取得
        let passwordCount = passwordTextField.text!.count

        // パスワードが8文字以上の時
        if passwordCount >= 8 {
            // mailAddressTextFieldが入力されていない時
            if mailAddressTextField.text == "" {
                logInButton.isEnabled = false
                logInButton.setTitleColor(UIColor(named: "EnabledButtonText"), for: .normal)
                logInButton.backgroundColor = UIColor(named: "EnabledButton")
                // mailAddressTextFieldが入力されている時
            } else {
                logInButton.isEnabled = true
                logInButton.setTitleColor(UIColor(named: "White"), for: .normal)
                logInButton.backgroundColor = UIColor(named: "Blue")
            }
            // パスワードが8文字未満の時
        } else {
            logInButton.isEnabled = false
            logInButton.setTitleColor(UIColor(named: "EnabledButtonText"), for: .normal)
            logInButton.backgroundColor = UIColor(named: "EnabledButton")
        }
    }

    @IBAction func passwordTextFieldEditingDidBegin(_ sender: Any) {
        passwordTextField.layer.borderColor = UIColor.systemBlue.cgColor
        mailAddressTextField.layer.borderColor = UIColor.lightGray.cgColor
    }

    @IBAction func passwordTextFieldEditingDidEnd(_ sender: Any) {
        passwordTextField.layer.borderColor = UIColor.lightGray.cgColor
    }

    @IBAction func logInButtonTouchDown(_ sender: Any) {
        UIButton().uiButtonTapOn(item: logInButton, itemRight: logInButtonRight, itemLeft: logInButtonLeft)
    }

    @IBAction func logInButtonTouchDragOutside(_ sender: Any) {
        UIButton().uiButtonTapOff(item: logInButton, itemRight: logInButtonRight, itemLeft: logInButtonLeft)
    }

    @IBAction func logInButtonTouchUpInside(_ sender: Any) {
        UISelectionFeedbackGenerator().selectionChanged()
        
        UIButton().uiButtonTapOff(item: logInButton, itemRight: logInButtonRight, itemLeft: logInButtonLeft)

        view.endEditing(true)

        // メールアドレスが正しい時
        if MailAddressViewController.isValidMailAddress(mailAddressTextField.text!) {
            // パスワードが正しい時
            if PasswordViewController.isValidPassword(passwordTextField.text!) {
                activityIndicator.startAnimating()
                logInButton.setTitle("", for: .normal)
                logInButton.isEnabled = false
                signUpButton.isEnabled = false
                mailAddressTextField.isEnabled = false
                passwordTextField.isEnabled = false
                    
                apiLogin()
                    
                // パスワードが正しくない時
            } else {
                passwordTextField.layer.borderColor = UIColor.systemPink.cgColor
                errorLabel.text = "pasuwa-doera-".localized()
                errorView.errorViewTransition(value: 182)
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.error)
            }
            // メールアドレスが正しくない時
        } else {
            mailAddressTextField.layer.borderColor = UIColor.systemPink.cgColor
            errorLabel.text = "me-ruadoresuera-".localized()
            errorView.errorViewTransition(value: 182)
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
        }
    }

    @IBAction func signUpButtonTouchDown(_ sender: Any) {
        signUpButtonRight.constant = 25
        signUpButtonLeft.constant = 25

        signUpButton.setTitleColor(UIColor(named: "BlueHalf"), for: .normal)
    }

    @IBAction func signUpButtonTouchDragoutside(_ sender: Any) {
        signUpButtonRight.constant = 20
        signUpButtonLeft.constant = 20

        signUpButton.setTitleColor(UIColor(named: "Blue"), for: .normal)
    }

    @IBAction func signUpButtonTouchUpInside(_ sender: Any) {
        UISelectionFeedbackGenerator().selectionChanged()
        
        signUpButtonRight.constant = 20
        signUpButtonLeft.constant = 20

        signUpButton.setTitleColor(UIColor(named: "Blue"), for: .normal)

        mailAddressTextField.layer.borderColor = UIColor.lightGray.cgColor
        passwordTextField.layer.borderColor = UIColor.lightGray.cgColor

        view.endEditing(true)
        
        let storyBoard = UIStoryboard(name: "SignUpName", bundle: nil)
        let nextVC = storyBoard.instantiateInitialViewController()
        present(nextVC!, animated: true) {}
    }
    
    func apiLogin() {
        // 入力されたメールアドレスを小文字にして代入
        let mailAddressMini = mailAddressTextField.text!.lowercased()
        let mailAddressMiniNotwhitespaces = mailAddressMini.stringCharacterSetRemove(characterSet: .whitespaces)
        let passwordTextFieldNotwhitespaces = passwordTextField.text!.stringCharacterSetRemove(characterSet: .whitespaces)
        
        let afterPassword = passwordTextFieldNotwhitespaces.stringReplacement()
        
        let url = URL(string: api! + "user")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST" // Postリクエストを送る(このコードがないとGetリクエストになる)
        request.addValue("application/json", forHTTPHeaderField: "content-type")
        // request.addValue("", forHTTPHeaderField: "authorization") //APIKey
        
        // 構造体を作成
        struct Login: Codable {
            let OperationType: String
            let mailaddress: String
        }
        
        let encoder = JSONEncoder()
        
        let body = Login(OperationType: "LOGIN", mailaddress: mailAddressMiniNotwhitespaces)
        
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
                    self.activityIndicator.stopAnimating()
                    self.logInButton.setTitle("roguinn".localized(), for: .normal)
                    self.logInButton.isEnabled = true
                    self.signUpButton.isEnabled = true
                    self.mailAddressTextField.isEnabled = true
                    self.passwordTextField.isEnabled = true
                
                    print("クライアントエラー: \(error.localizedDescription)")
                    self.apiError()
                }
            }

            guard let data = data, let response = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.logInButton.setTitle("roguinn".localized(), for: .normal)
                    self.logInButton.isEnabled = true
                    self.signUpButton.isEnabled = true
                    self.mailAddressTextField.isEnabled = true
                    self.passwordTextField.isEnabled = true
                }
                
                print("no data or no response")
                return
            }
            
            if response.statusCode == 200 {
                let json = String(data: data, encoding: .utf8)!
                print(json)
                
                if json == "[]" {
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                        self.logInButton.setTitle("roguinn".localized(), for: .normal)
                        self.logInButton.isEnabled = true
                        self.signUpButton.isEnabled = true
                        self.mailAddressTextField.isEnabled = true
                        self.passwordTextField.isEnabled = true
                        
                        let alertTitle = "me-ruadoresugatadasikuarimasenn".localized()
                        let alertMessage = "akaunntogaarimasenn".localized()
                        let retryTitle = "mouitidojikkou".localized()

                        let alertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)

                        alertController.view.tintColor = UIColor(named: "BlackWhite")
                        let retryButton = UIAlertAction(title: retryTitle, style: .cancel, handler: nil)

                        alertController.addAction(retryButton)

                        self.present(alertController, animated: true, completion: nil)

                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.error)
                    }
                }
                
                struct User: Codable {
                    let userId: Int
                    let userName: String
                    let bio: String
                    let birthday: String
                    let createDate: String
                    let deleteDate: String
                    let gender: Int
                    let mailaddress: String
                    let myColor: String
                    let name1: String
                    let name2: String
                    let password: String
                    let profileimageUrl: String
                    let website: String
                    let accountType: String
                    let accountCategory: String
                    let verification: String
                }
                
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let decoded: [User] = try! decoder.decode([User].self, from: data)
                for user in decoded {
                    print(user)
                    
                    // 登録時のパスワードと入力されたパスワードが同じ時
                    if user.password == afterPassword {
                        print("OK")
                        
                        if let userDefaults = self.userDefaults {
                            userDefaults.setValue(user.userId, forKeyPath: "userid")
                            userDefaults.setValue(user.name1, forKeyPath: "name1")
                            userDefaults.setValue(user.name2, forKeyPath: "name2")
                            userDefaults.setValue(user.mailaddress, forKeyPath: "mailaddress")
                            userDefaults.setValue(user.password, forKeyPath: "password")
                            userDefaults.setValue(user.gender, forKeyPath: "gender")
                            userDefaults.setValue(user.birthday, forKeyPath: "birthday")
                            userDefaults.setValue(user.userName, forKeyPath: "username")
                            userDefaults.setValue(user.profileimageUrl, forKeyPath: "profileimage")
                            userDefaults.setValue(user.bio, forKeyPath: "bio")
                            userDefaults.setValue(user.myColor, forKeyPath: "mycolor")
                            userDefaults.setValue(user.website, forKeyPath: "website")
                            userDefaults.setValue(user.accountType, forKeyPath: "accounttype")
                            userDefaults.setValue(user.accountCategory, forKeyPath: "accountcategory")
                            userDefaults.setValue(user.verification, forKeyPath: "verification")
                            userDefaults.setValue("On", forKeyPath: "savephoto")
                        }
                        
                        self.apiLike(userId: user.userId)
                        // 登録時のパスワードと入力されたパスワードが違う時
                    } else {
                        DispatchQueue.main.async {
                            self.activityIndicator.stopAnimating()
                            self.logInButton.setTitle("roguinn".localized(), for: .normal)
                            self.logInButton.isEnabled = true
                            self.signUpButton.isEnabled = true
                            self.mailAddressTextField.isEnabled = true
                            self.passwordTextField.isEnabled = true
                            
                            let alertTitle = String(format: "pasuwa-dogamatigatteimasu".localized(), self.mailAddressTextField.text!)
                            let alertMessage = "nyuuryokusaretapasuwa-dohatadasikuarimasenn".localized()
                            let retryTitle = "mouitidojikkou".localized()
                               
                            let alertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)

                            let retryButton = UIAlertAction(title: retryTitle, style: .cancel, handler: nil)

                            alertController.view.tintColor = UIColor(named: "BlackWhite")
                            alertController.addAction(retryButton)

                            self.present(alertController, animated: true, completion: nil)

                            let generator = UINotificationFeedbackGenerator()
                            generator.notificationOccurred(.error)
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.logInButton.setTitle("roguinn".localized(), for: .normal)
                    self.logInButton.isEnabled = true
                    self.signUpButton.isEnabled = true
                    self.mailAddressTextField.isEnabled = true
                    self.passwordTextField.isEnabled = true
                
                    // レスポンスのステータスコードが200でない場合などはサーバサイドエラー
                    print("サーバエラー ステータスコード: \(response.statusCode)")
                    self.apiError()
                }
            }
        }
        task.resume()
    }
    
    func apiLike(userId: Int) {
        let url = URL(string: api! + "like")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST" // Postリクエストを送る(このコードがないとGetリクエストになる)
        request.addValue("application/json", forHTTPHeaderField: "content-type")
        // request.addValue("", forHTTPHeaderField: "authorization") //APIKey
        
        // 構造体を作成
        struct Like: Codable {
            let OperationType: String
            let userId: Int
        }
        
        let encoder = JSONEncoder()
        
        let body = Like(OperationType: "MYLIKESCAN", userId: userId)
        
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
                    self.activityIndicator.stopAnimating()
                    self.logInButton.setTitle("roguinn".localized(), for: .normal)
                    self.logInButton.isEnabled = true
                    self.signUpButton.isEnabled = true
                    self.mailAddressTextField.isEnabled = true
                    self.passwordTextField.isEnabled = true
                
                    print("クライアントエラー: \(error.localizedDescription)")
                    self.apiError()
                }
            }

            guard let data = data, let response = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.logInButton.setTitle("roguinn".localized(), for: .normal)
                    self.logInButton.isEnabled = true
                    self.signUpButton.isEnabled = true
                    self.mailAddressTextField.isEnabled = true
                    self.passwordTextField.isEnabled = true
                }
                
                print("no data or no response")
                return
            }
            
            if response.statusCode == 200 {
                let json = String(data: data, encoding: .utf8)!
                
                if json == "[]" {
                    if let userDefaults = self.userDefaults {
                        let likepostidArray: [Int] = []
                        userDefaults.setValue(likepostidArray, forKey: "likepostid")
                        // ログイン！
                        userDefaults.setValue(true, forKeyPath: "loginrecord")
                    }
                    DispatchQueue.main.async {
                        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                        let nextVC = storyBoard.instantiateInitialViewController()
                        self.present(nextVC!, animated: false) {}
                    }
                }
                
                struct Like: Codable {
                    let postId: Int
                }
                
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let decoded: [Like] = try! decoder.decode([Like].self, from: data)
                for like in decoded {
                    if let userDefaults = self.userDefaults {
                        if userDefaults.array(forKey: "likepostid") as? [Int] == nil {
                            var likepostidArray: [Int] = []
                            likepostidArray.append(like.postId)
                            // 配列の保存
                            userDefaults.setValue(likepostidArray, forKey: "likepostid")
                            // ログイン！
                            userDefaults.setValue(true, forKeyPath: "loginrecord")
                        } else {
                            var likepostidArray: [Int] = userDefaults.array(forKey: "likepostid") as! [Int]
                            likepostidArray.append(like.postId)
                            // 配列の保存
                            userDefaults.setValue(likepostidArray, forKey: "likepostid")
                            // ログイン！
                            userDefaults.setValue(true, forKeyPath: "loginrecord")
                        }
                    }
                    DispatchQueue.main.async {
                        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                        let nextVC = storyBoard.instantiateInitialViewController()
                        self.present(nextVC!, animated: false) {}
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.logInButton.setTitle("roguinn".localized(), for: .normal)
                    self.logInButton.isEnabled = true
                    self.signUpButton.isEnabled = true
                    self.mailAddressTextField.isEnabled = true
                    self.passwordTextField.isEnabled = true
                
                    // レスポンスのステータスコードが200でない場合などはサーバサイドエラー
                    print("サーバエラー ステータスコード: \(response.statusCode)")
                    self.apiError()
                }
            }
        }
        task.resume()
    }
    
    func apiError() {
        errorLabel.text = "era-".localized()
        errorView.errorViewTransition(value: 182)
        
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
}
