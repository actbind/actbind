//
//  WebsiteEditViewController.swift
//  Actbind
//
//  Created by 柿本海斗 on 2021/08/26.
//

import UIKit

final class WebsiteEditViewController: UIViewController, UIGestureRecognizerDelegate {
    let userDefaults = UserDefaults(suiteName: "group.com.actbind")
    let api = KeyManager().getValue(key: "API") as? String
    
    @IBOutlet weak var navigationBarTitle: UINavigationItem!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var websiteTitleLabel: UILabel!
    @IBOutlet weak var websiteTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var saveButtonRight: NSLayoutConstraint!
    @IBOutlet weak var saveButtonLeft: NSLayoutConstraint!
    @IBOutlet weak var activityView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var checkmarkImage: UIImageView!
    @IBOutlet weak var activityLabel: UILabel!
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var errorTextLabel: UILabel!
    @IBOutlet weak var errorViewBottom: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
        navigationBarTitle.title = "webusaitowohennsyuu".localized()

        if let userDefaults = userDefaults {
            let myColor = userDefaults.string(forKey: "mycolor")
            let website = userDefaults.string(forKey: "website")

            if myColor == "Original" {
                backButton.tintColor = UIColor(named: "BlackWhite")
                websiteTextField.tintColor = UIColor(named: "Blue")
                saveButton.backgroundColor = UIColor(named: "Blue")
            } else {
                backButton.tintColor = UIColor(named: myColor!)
                websiteTextField.tintColor = UIColor(named: myColor!)
                saveButton.backgroundColor = UIColor(named: myColor!)
            }
            
            if website == "" {
                websiteTextField.text = ""
            } else {
                websiteTextField.text = website
            }
        }
        
        backButton.image = UIImage(named: "back")
        
        websiteTitleLabel.text = "webusaito".localized()
        
        websiteTextField.uiTextFieldSetting(placeholder: "webusaitowonyuuryoku".localized())
        
        saveButton.setTitle("hozonn".localized(), for: .normal)
        
        activityView.cornerAll(value: 16, fulcrum: "")
        activityView.isHidden = true
        
        checkmarkImage.image = UIImage(named: "")
        activityLabel.text = "hennkounaiyousetteityuu".localized()
        
        errorTextLabel.text = ""
        errorViewBottom.constant = -60
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
    
    // キーボード以外をタップでキーボードが閉じる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    // 完了キーをタップでキーボードが閉じる
    @IBAction func websiteTextFieldDidEndOnExit(_ sender: Any) {}
    
    @IBAction func websiteTextFieldEditingDidBegin(_ sender: Any) {
        if let userDefaults = userDefaults {
            let myColor = userDefaults.string(forKey: "mycolor")
            
            if myColor == "Original" || myColor == "Blue" {
                websiteTextField.layer.borderColor = UIColor.systemBlue.cgColor
            } else if myColor == "Red" {
                websiteTextField.layer.borderColor = UIColor.blue.cgColor
            } else if myColor == "Orange" {
                websiteTextField.layer.borderColor = UIColor.orange.cgColor
            } else if myColor == "Yellow" {
                websiteTextField.layer.borderColor = UIColor.yellow.cgColor
            } else if myColor == "Green" {
                websiteTextField.layer.borderColor = UIColor.green.cgColor
            } else {
                websiteTextField.layer.borderColor = UIColor.purple.cgColor
            }
        }
    }

    @IBAction func websiteTextFieldEditingDidEnd(_ sender: Any) {
        websiteTextField.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    @IBAction func saveButtonTouchDown(_ sender: Any) {
        UIButton().uiButtonTapOn(item: saveButton, itemRight: saveButtonRight, itemLeft: saveButtonLeft)
    }
    
    @IBAction func saveButtonTouchDragOutside(_ sender: Any) {
        UIButton().uiButtonTapOff(item: saveButton, itemRight: saveButtonRight, itemLeft: saveButtonLeft)
    }
    
    @IBAction func saveButtonTouchUpInside(_ sender: Any) {
        UISelectionFeedbackGenerator().selectionChanged()
        
        UIButton().uiButtonTapOff(item: saveButton, itemRight: saveButtonRight, itemLeft: saveButtonLeft)
        
        view.endEditing(true)
        
        if websiteTextField.text!.prefix(7) == "http://" {
            websiteTextField.text = "https://" + websiteTextField.text!.dropFirst(7)
        }
        
        let websiteMini = websiteTextField.text!.lowercased()
        
        if let userDefaults = userDefaults {
            let website = userDefaults.string(forKey: "website")
            
            if websiteMini == "" {
                if websiteMini == website {
                    navigationController?.popViewController(animated: true)
                } else {
                    saveButton.isEnabled = false
                    navigationController?.interactivePopGestureRecognizer?.isEnabled = false
                    backButton.isEnabled = false
                    activityView.isHidden = false
                    activityIndicator.startAnimating()
                
                    // データ登録・更新
                
                    let userId = userDefaults.integer(forKey: "userid")
                    apiWebsite(userId: userId, value: websiteTextField.text!)
                }
            } else {
                // URLが正しい時
                if UrlViewController.isValidUrl(websiteTextField.text!) {
                    if websiteMini == website {
                        navigationController?.popViewController(animated: true)
                    } else {
                        saveButton.isEnabled = false
                        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
                        backButton.isEnabled = false
                        activityView.isHidden = false
                        activityIndicator.startAnimating()
                
                        // データ登録・更新
                
                        let userId = userDefaults.integer(forKey: "userid")
                        apiWebsite(userId: userId, value: websiteTextField.text!)
                    }
                } else {
                    websiteTextField.layer.borderColor = UIColor.systemPink.cgColor
                    errorTextLabel.text = "webusaitoera-".localized()
                    errorView.errorViewTransition(value: 114)
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.error)
                }
            }
        }
    }

    @IBAction func backBottonAction(_ sender: Any) {
        UISelectionFeedbackGenerator().selectionChanged()
        
        navigationController?.popViewController(animated: true)
    }
    
    func apiWebsite(userId: Int, value: String) {
        let url = URL(string: api! + "userchange")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST" // Postリクエストを送る(このコードがないとGetリクエストになる)
        request.addValue("application/json", forHTTPHeaderField: "content-type")
        // request.addValue("", forHTTPHeaderField: "authorization") //APIKey
        
        // 構造体を作成
        struct UserChange: Codable {
            let changeKey: String
            let userId: Int
            let website: String
        }
        
        let encoder = JSONEncoder()
        
        let body = UserChange(changeKey: "website", userId: userId, website: value)
        
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
                        userDefaults.setValue(value, forKeyPath: "website")
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
            
            self.navigationController?.popViewController(animated: true)
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
            
            self.navigationController?.popViewController(animated: true)
        }
    }
}
