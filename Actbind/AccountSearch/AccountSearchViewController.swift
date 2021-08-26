//
//  SearchingViewController.swift
//  Actbind
//
//  Created by 柿本海斗 on 2021/07/22.
//

import UIKit

final class AccountSearchViewController: UIViewController, UISearchBarDelegate, UIGestureRecognizerDelegate {
    let userDefaults = UserDefaults(suiteName: "group.com.actbind")
    let api = KeyManager().getValue(key: "API") as? String
    
    struct Users: Codable {
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
    
    static var allUsers: [Users] = []
    
    var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var errorViewBottom: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
        navigationItem.hidesBackButton = true
        
        errorViewBottom.constant = -60
        
        setupSearchBar()
    }
    
    // 画面に表示される直前に呼ばれます。
    // viewDidLoadとは異なり毎回呼び出されます。
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if toHomeView == "on" {
            navigationController?.popToRootViewController(animated: true)
            
            let UINavigationController = tabBarController?.viewControllers?[0]
            tabBarController?.selectedViewController = UINavigationController
        }
        
        tableView.reloadData()
    }
    
    func setupSearchBar() {
        if let navigationBarFrame = navigationController?.navigationBar.bounds {
            let searchBar = UISearchBar(frame: navigationBarFrame)
            searchBar.delegate = self
            searchBar.placeholder = "akaunntokensaku".localized()
            if let userDefaults = userDefaults {
                let myColor = userDefaults.string(forKey: "mycolor")

                if myColor == "Original" {
                    searchBar.tintColor = UIColor(named: "Blue")
                } else {
                    searchBar.tintColor = UIColor(named: myColor!)
                }
            }
            searchBar.showsCancelButton = true
            searchBar.becomeFirstResponder()
            
            searchBar.keyboardType = UIKeyboardType.default
            navigationItem.titleView = searchBar
            navigationItem.titleView?.frame = searchBar.frame
            self.searchBar = searchBar
        }
    }
    
    // 検索ボタンが押されたとき
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.alwaysShowCancelButton()
        
        if searchBar.text!.count >= 5, searchBar.text!.count <= 30 {
            // ユーザーネームが正しい時
            if UserNameViewController.isValidAccountName(searchBar.text!) {
                // ユーザーネームが数字だけでない時
                if !OnlyNumberViewController.isValidOnlyNumber(searchBar.text!) {
                    // ユーザーネームがアンダーバーだけでない時
                    if !OnlyUnderbarViewController.isValidOnlyUnderbar(searchBar.text!) {
                        // 入力された文字の大文字を小文字に
                        let userNameMini = searchBar.text!.lowercased()
                        let userNameMiniNotwhitespaces = userNameMini.stringCharacterSetRemove(characterSet: .whitespaces)
                        
                        searchBar.text = userNameMiniNotwhitespaces
                        
                        apiUser(userName: userNameMiniNotwhitespaces)
                        // ユーザーネームがアンダーバーだけの時
                    } else {
                        errorLabel.text = "yu-za-ne-muera-".localized()
                        errorView.errorViewTransition(value: 80)
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.error)
                    }
                    // ユーザーネームが数字だけの時
                } else {
                    errorLabel.text = "yu-za-ne-muera-".localized()
                    errorView.errorViewTransition(value: 80)
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.error)
                }
                // ユーザーネームが正しくない時
            } else {
                errorLabel.text = "yu-za-ne-muera-".localized()
                errorView.errorViewTransition(value: 80)
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.error)
            }
        } else {
            errorLabel.text = "yu-za-ne-muera-".localized()
            errorView.errorViewTransition(value: 80)
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
        }
    }
    
    // キャンセルボタンが押されたとき
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        navigationController?.popViewController(animated: true)
    }
    
    func apiUser(userName: String) {
        let url = URL(string: api! + "user")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST" // Postリクエストを送る(このコードがないとGetリクエストになる)
        request.addValue("application/json", forHTTPHeaderField: "content-type")
        // request.addValue("", forHTTPHeaderField: "authorization") //APIKey
        
        // 構造体を作成
        struct User: Codable {
            let OperationType: String
            let userName: String
        }
        
        let encoder = JSONEncoder()
        
        let body = User(OperationType: "USERNAMESEARCH", userName: userName)
        
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
                
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                if let allUsers = try? decoder.decode([Users].self, from: data) {
                    DispatchQueue.main.async {
                        AccountSearchViewController.allUsers = allUsers
                        self.tableView.reloadData()
                    }
                    
                } else {
                    print("Unable parse JSON response")
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
    
    func apiError() {
        errorLabel.text = "era-".localized()
        errorView.errorViewTransition(value: 80)
        
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
}

// extensionは何かを追加していく ViewControllerというクラスの中にUITableViewDataSource機能を追加していく
extension AccountSearchViewController: UITableViewDataSource {
    // tableviewの中に何個のセクションを追加するか
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    // 一つのtableviewの中に何個のセルが必要か
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        AccountSearchViewController.allUsers.count
    }
    
    // tavleviewの中で使われているセルの特定
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let accountCell = tableView.dequeueReusableCell(withIdentifier: "accountCell", for: indexPath) as! AccountSearchTableViewCell
                 
        // ここからの内容がセルに反映される
        // 順番にcellの方のpostに送っていく
        accountCell.user = AccountSearchViewController.allUsers[indexPath.row]
        accountCell.delegate = self
        // ここまで
        return accountCell
    }
    
    func goMyProfile(_ userId: Int) {
        let storyBoard = UIStoryboard(name: "MyProfile", bundle: nil)
        let nextVC = storyBoard.instantiateInitialViewController()
        let vc = (nextVC as? MyProfileViewController)
        
        vc!.userId = userId
        
        navigationController?.pushViewController(nextVC!, animated: true)
    }
    
    func goOtherProfile(_ userId: Int, userName: String) {
        let storyBoard = UIStoryboard(name: "OtherProfile", bundle: nil)
        let nextVC = storyBoard.instantiateInitialViewController()
        let vc = (nextVC as? OtherProfileViewController)
        
        vc!.userId = userId
        vc!.userName = userName
        
        navigationController?.pushViewController(nextVC!, animated: true)
    }
}

extension UISearchBar {
    func alwaysShowCancelButton() {
        for subview in subviews {
            for ss in subview.subviews {
                for s in ss.subviews {
                    enableCancel(with: s)
                }
            }
        }
    }

    private func enableCancel(with view: UIView) {
        if NSStringFromClass(type(of: view)).contains("UINavigationButton") {
            (view as! UIButton).isEnabled = true
        }
    }
}
