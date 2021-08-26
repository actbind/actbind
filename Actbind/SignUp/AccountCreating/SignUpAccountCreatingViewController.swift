//
//  AccountCreatingViewController.swift
//  Actbind
//
//  Created by 柿本　海斗 on 2020/12/17.
//

import UIKit

final class SignUpAccountCreatingViewController: UIViewController {
    let userDefaults = UserDefaults(suiteName: "group.com.actbind")
    let api = KeyManager().getValue(key: "API") as? String
    
    var name1 = ""
    var name2 = ""
    var mailaddress = ""
    var password = ""
    var gender = 0
    var birthday = ""
    var username = ""

    @IBOutlet weak var accountCreatingLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()

        accountCreatingLabel.text = "akaunntowosakiseisiteimasu".localized()
        activityIndicator.startAnimating()
        
        let url = URL(string: api! + "user")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST" // Postリクエストを送る(このコードがないとGetリクエストになる)
        request.addValue("application/json", forHTTPHeaderField: "content-type")
        // request.addValue("", forHTTPHeaderField: "authorization") //APIKey
        
        // 構造体を作成
        struct User: Codable {
            let OperationType: String
            let name1: String
            let name2: String
            let mailaddress: String
            let password: String
            let gender: Int
            let birthday: String
            let username: String
            let createDate: String
        }
        
        let encoder = JSONEncoder()
        
        let now = Date()
        let createDate = now.dateToString(format: "yyyy-MM-dd HH:mm:ss")
        
        let body = User(OperationType: "PUT", name1: name1, name2: name2, mailaddress: mailaddress, password: password, gender: gender, birthday: birthday, username: username, createDate: createDate)
        
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
                    self.activityIndicator.stopAnimating()
                    self.apiPostError()
                }
            }

            guard let data = data, let response = response as? HTTPURLResponse else {
                print("no data or no response")
                return
            }

            if response.statusCode == 200 {
                let json = String(data: data, encoding: .utf8)!
                print(json)
                
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
                        let likepostidArray: [Int] = []
                        userDefaults.setValue(likepostidArray, forKey: "likepostid")
                        // ログイン！
                        userDefaults.setValue(true, forKeyPath: "loginrecord")
                    }
                    
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                        self.apiPostSuccess()
                    }
                }
                
            } else {
                DispatchQueue.main.async {
                    // レスポンスのステータスコードが200でない場合などはサーバサイドエラー
                    print("サーバエラー ステータスコード: \(response.statusCode)")
                    self.activityIndicator.stopAnimating()
                    self.apiPostError()
                }
            }
        }
        task.resume()
    }
    
    func apiPostSuccess() {
        let storyBoard = UIStoryboard(name: "SignUpOk", bundle: nil)
        let nextVC = storyBoard.instantiateInitialViewController()
        
        navigationController?.pushViewController(nextVC!, animated: false)
    }
    
    func apiPostError() {
        let storyBoard = UIStoryboard(name: "SignUpNo", bundle: nil)
        let nextVC = storyBoard.instantiateInitialViewController()
        
        navigationController?.pushViewController(nextVC!, animated: false)
    }
}
