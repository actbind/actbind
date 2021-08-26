//
//  ProfileViewController.swift
//  Actbind
//
//  Created by 柿本海斗 on 2021/03/02.
//

import AudioToolbox
import UIKit

final class MyProfileViewController: UIViewController, UIGestureRecognizerDelegate {
    let userDefaults = UserDefaults(suiteName: "group.com.actbind")
    let api = KeyManager().getValue(key: "API") as? String
    
    struct MyPosts: Codable {
        let userId: Int
        let postId: Int
        let caption: String
        let postimageUrl: String
        let deleteDate: String
        let color: String
        let createDate: String
    }
    
    static var allMyPosts: [MyPosts] = []
    
    var userId = 0
    
    @IBOutlet weak var navigationBarTitle: UINavigationItem!
    @IBOutlet weak var profileMenuButton: UIBarButtonItem!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    let refreshControl = UIRefreshControl()
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var errorViewBottom: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
        MyProfileViewController.allMyPosts = []
        
        if let userDefaults = userDefaults {
            let myColor = userDefaults.string(forKey: "mycolor")
            let username = userDefaults.string(forKey: "username")
            navigationBarTitle.title = "@" + username!

            if myColor == "Original" {
                profileMenuButton.tintColor = UIColor(named: "BlackWhite")
                backButton.tintColor = UIColor(named: "BlackWhite")
            } else {
                profileMenuButton.tintColor = UIColor(named: myColor!)
                backButton.tintColor = UIColor(named: myColor!)
            }
        }
        
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(MyProfileViewController.refresh(sender:)), for: .valueChanged)
        
        errorViewBottom.constant = -60
        
        if userId == 0 {
            if let userDefaults = userDefaults {
                let userId = userDefaults.integer(forKey: "userid")
                
                apiMyPost(userId: userId)
            }
        } else {
            apiMyPost(userId: userId)
        }
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
    
    @IBAction func profileEditButtonTouchUpInside(_ sender: Any) {
        let storyBoard = UIStoryboard(name: "ProfileEdit", bundle: nil)
        let nextVC = storyBoard.instantiateInitialViewController()
        
        navigationController?.pushViewController(nextVC!, animated: true)
    }
    
    @IBAction func profileMenuButtonTouchUpInside(_ sender: Any) {
        UISelectionFeedbackGenerator().selectionChanged()
        
        let profileEditTitle = "purofi-ruwohennsyuu".localized()
        let cancelTitle = "kyannseru".localized()

        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        let profileEditButton = UIAlertAction(title: profileEditTitle, style: .default, handler: { _ in
            let storyBoard = UIStoryboard(name: "ProfileEdit", bundle: nil)
            let nextVC = storyBoard.instantiateInitialViewController()
            
            self.navigationController?.pushViewController(nextVC!, animated: true)
        })
        let cancelButton = UIAlertAction(title: cancelTitle, style: .cancel, handler: nil)
        
        alertController.view.tintColor = UIColor(named: "BlackWhite")
        alertController.addAction(profileEditButton)
        alertController.addAction(cancelButton)

        alertController.popoverPresentationController?.sourceView = view
        let screenSize = UIScreen.main.bounds
        // ここで表示位置を調整
        // xは画面中央、yは画面下部になる様に指定
        alertController.popoverPresentationController?.sourceRect = CGRect(x: screenSize.size.width / 2, y: screenSize.size.height, width: 0, height: 0)

        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        UISelectionFeedbackGenerator().selectionChanged()
        
        navigationController?.popViewController(animated: true)
    }
    
    @objc func refresh(sender: UIRefreshControl) {
        // ここに通信処理などデータフェッチの処理を書く
        if let userDefaults = userDefaults {
            let userId = userDefaults.integer(forKey: "userid")
            
            apiMyPost(userId: userId)
        }
    }
    
    func apiMyPost(userId: Int) {
        let url = URL(string: api! + "post")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST" // Postリクエストを送る(このコードがないとGetリクエストになる)
        request.addValue("application/json", forHTTPHeaderField: "content-type")
        // request.addValue("", forHTTPHeaderField: "authorization") //APIKey
        
        // 構造体を作成
        struct MyPost: Codable {
            let OperationType: String
            let userId: Int
        }
        
        let encoder = JSONEncoder()
        
        let body = MyPost(OperationType: "MYPOSTSCAN", userId: userId)
            
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
                    self.refreshControl.endRefreshing()
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
                if let allMyPosts = try? decoder.decode([MyPosts].self, from: data) {
                    DispatchQueue.main.async {
                        MyProfileViewController.allMyPosts = allMyPosts
                        print(allMyPosts)
                        print(allMyPosts.count)
                        self.refreshControl.endRefreshing()
                        self.tableView.reloadData()
                    }
                    
                } else {
                    print("Unable parse JSON response")
                }
                
            } else {
                DispatchQueue.main.async {
                    // レスポンスのステータスコードが200でない場合などはサーバサイドエラー
                    print("サーバエラー ステータスコード: \(response.statusCode)")
                    self.refreshControl.endRefreshing()
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
extension MyProfileViewController: UITableViewDataSource {
    // tableviewの中に何個のセクションを追加するか
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    // 一つのtableviewの中に何個のセルが必要か
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if MyProfileViewController.allMyPosts.count == 0 {
            return Profile.allProfile.count + MyProfileNoPost.allNoPost.count
        } else {
            return Profile.allProfile.count + MyProfileViewController.allMyPosts.count
        }
    }
    
    // tavleviewの中で使われているセルの特定
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let profileCell = tableView.dequeueReusableCell(withIdentifier: "profileCell", for: indexPath) as! MyProfileTableViewCell
            
            // ここからの内容がセルに反映される
            // 順番にcellの方のpostに送っていく
            profileCell.profile = Profile.allProfile[indexPath.row]
            profileCell.delegate = self
            // ここまで
            return profileCell
        } else {
            if MyProfileViewController.allMyPosts.count == 0 {
                let noPostCell = tableView.dequeueReusableCell(withIdentifier: "noPostCell", for: indexPath) as! MyProfileNoPostTableViewCell
                 
                // ここからの内容がセルに反映される
                // 順番にcellの方のpostに送っていく
                noPostCell.noPost = MyProfileNoPost.allNoPost[indexPath.row - 1]
                // ここまで
                return noPostCell
            } else {
                let profilePostCell = tableView.dequeueReusableCell(withIdentifier: "profilePostCell", for: indexPath) as! MyProfilePostTableViewCell
                 
                // ここからの内容がセルに反映される
                // 順番にcellの方のpostに送っていく
                profilePostCell.myPost = MyProfileViewController.allMyPosts[indexPath.row - 1]
                profilePostCell.delegate = self
                // ここまで
                return profilePostCell
            }
        }
    }
    
    func goWeb(website: String) {
        let storyBoard = UIStoryboard(name: "Web", bundle: nil)
        let nextVC = storyBoard.instantiateInitialViewController()
        let nav = (nextVC as? UINavigationController)
        let vc = (nav?.topViewController as! WebViewController)
        
        // 値の設定
        vc.weburl = website
        
        present(nextVC!, animated: true) {}
    }
    
    func apiLikePost(userId: Int, postId: Int) {
        let url = URL(string: api! + "like")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST" // Postリクエストを送る(このコードがないとGetリクエストになる)
        request.addValue("application/json", forHTTPHeaderField: "content-type")
        // request.addValue("", forHTTPHeaderField: "authorization") //APIKey
        
        // 構造体を作成
        struct Like: Codable {
            let OperationType: String
            let userId: Int
            let postId: Int
        }
        
        let encoder = JSONEncoder()
        
        let body = Like(OperationType: "PUT", userId: userId, postId: postId)
        
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
                
                if let userDefaults = self.userDefaults {
                    var likepostidArray: [Int] = userDefaults.array(forKey: "likepostid") as! [Int]
                
                    likepostidArray.append(postId)
                    // 配列の保存
                    userDefaults.setValue(likepostidArray, forKey: "likepostid")
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
    
    func apiLikeIdGet(userId: Int, postId: Int) {
        let url = URL(string: api! + "like")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST" // Postリクエストを送る(このコードがないとGetリクエストになる)
        request.addValue("application/json", forHTTPHeaderField: "content-type")
        // request.addValue("", forHTTPHeaderField: "authorization") //APIKey
        
        // 構造体を作成
        struct Like: Codable {
            let OperationType: String
            let userId: Int
            let postId: Int
        }
        
        let encoder = JSONEncoder()
        
        let body = Like(OperationType: "GETLIKEID", userId: userId, postId: postId)
        
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
                
                struct LikeId: Codable {
                    let likeId: Int
                }
                
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let decoded: [LikeId] = try! decoder.decode([LikeId].self, from: data)
                for likeId in decoded {
                    print(likeId)
                
                    self.apiLikeDelete(likeId: likeId.likeId, postId: postId)
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
    
    func apiLikeDelete(likeId: Int, postId: Int) {
        let url = URL(string: api! + "like")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST" // Postリクエストを送る(このコードがないとGetリクエストになる)
        request.addValue("application/json", forHTTPHeaderField: "content-type")
        // request.addValue("", forHTTPHeaderField: "authorization") //APIKey
        
        // 構造体を作成
        struct Like: Codable {
            let OperationType: String
            let likeId: Int
        }
        
        let encoder = JSONEncoder()
        
        let body = Like(OperationType: "DELETE", likeId: likeId)
        
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
                
                if let userDefaults = self.userDefaults {
                    var likepostidArray: [Int] = userDefaults.array(forKey: "likepostid") as! [Int]
                
                    likepostidArray.removeAll(where: { $0 == postId })
                    // 配列の保存
                    userDefaults.setValue(likepostidArray, forKey: "likepostid")
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
    
    func goColorTagSearch(color: String) {
        let storyBoard = UIStoryboard(name: "ColorTagSearch", bundle: nil)
        let nextVC = storyBoard.instantiateInitialViewController()
        let vc = (nextVC as? ColorTagSearchViewController)
        
        vc!.color = color
        
        navigationController?.pushViewController(nextVC!, animated: true)
    }
    
    func reportPost(postId: Int) {
        let monndaitoukouhoukokuTitle = "houkoku".localized()
        let cancelTitle = "kyannseru".localized()

        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        let monndaitoukouhoukokuButton = UIAlertAction(title: monndaitoukouhoukokuTitle, style: .destructive, handler: { _ in
            let storyBoard = UIStoryboard(name: "ReportPost", bundle: nil)
            let nextVC = storyBoard.instantiateInitialViewController()
            let nav = (nextVC as? UINavigationController)
            let vc = (nav?.topViewController as! ReportPostViewController)
            
            // 値の設定
            vc.postId = postId
            
            self.present(nextVC!, animated: true) {}
        })
        let cancelButton = UIAlertAction(title: cancelTitle, style: .cancel, handler: nil)
        
        alertController.view.tintColor = UIColor(named: "BlackWhite")
        alertController.addAction(monndaitoukouhoukokuButton)
        alertController.addAction(cancelButton)

        alertController.popoverPresentationController?.sourceView = view
        let screenSize = UIScreen.main.bounds
        // ここで表示位置を調整
        // xは画面中央、yは画面下部になる様に指定
        alertController.popoverPresentationController?.sourceRect = CGRect(x: screenSize.size.width / 2, y: screenSize.size.height, width: 0, height: 0)

        present(alertController, animated: true, completion: nil)
    }
    
    func deletePost(postId: Int, deleteIndex: Int) {
        let deletePostTitle = "sakujyo".localized()
        let cancelTitle = "kyannseru".localized()

        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        let deletePostButton = UIAlertAction(title: deletePostTitle, style: .destructive, handler: { _ in
            self.deletePostCheck(postId: postId, deleteIndex: deleteIndex)
        })
        let cancelButton = UIAlertAction(title: cancelTitle, style: .cancel, handler: nil)
        
        alertController.view.tintColor = UIColor(named: "BlackWhite")
        alertController.addAction(deletePostButton)
        alertController.addAction(cancelButton)

        alertController.popoverPresentationController?.sourceView = view
        let screenSize = UIScreen.main.bounds
        // ここで表示位置を調整
        // xは画面中央、yは画面下部になる様に指定
        alertController.popoverPresentationController?.sourceRect = CGRect(x: screenSize.size.width / 2, y: screenSize.size.height, width: 0, height: 0)

        present(alertController, animated: true, completion: nil)
    }
    
    func deletePostCheck(postId: Int, deleteIndex: Int) {
        let alertTitle = "toukousakujyo".localized()
        let deleteTitle = "sakujyo".localized()
        let cancelTitle = "kyannseru".localized()
           
        let alertController = UIAlertController(title: alertTitle, message: nil, preferredStyle: .alert)
        
        let deleteButton = UIAlertAction(title: deleteTitle, style: .destructive, handler: { _ in
            self.apiDeletePost(postId: postId, deleteIndex: deleteIndex)
        })

        let cancelButton = UIAlertAction(title: cancelTitle, style: .cancel, handler: nil)

        alertController.view.tintColor = UIColor(named: "BlackWhite")
        alertController.addAction(deleteButton)
        alertController.addAction(cancelButton)

        present(alertController, animated: true, completion: nil)
    }
    
    func apiDeletePost(postId: Int, deleteIndex: Int) {
        let url = URL(string: api! + "post")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST" // Postリクエストを送る(このコードがないとGetリクエストになる)
        request.addValue("application/json", forHTTPHeaderField: "content-type")
        // request.addValue("", forHTTPHeaderField: "authorization") //APIKey
        
        // 構造体を作成
        struct Delete: Codable {
            let OperationType: String
            let postId: Int
        }
        
        let encoder = JSONEncoder()
        
        let body = Delete(OperationType: "DELETE", postId: postId)
        
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
                    self.refreshControl.endRefreshing()
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
                
                MyProfileViewController.allMyPosts.remove(at: deleteIndex)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            } else {
                DispatchQueue.main.async {
                    // レスポンスのステータスコードが200でない場合などはサーバサイドエラー
                    print("サーバエラー ステータスコード: \(response.statusCode)")
                    self.refreshControl.endRefreshing()
                    self.apiError()
                }
            }
        }
        task.resume()
    }
    
    func goMyProfile(_ userId: Int) {
        let storyBoard = UIStoryboard(name: "MyProfile", bundle: nil)
        let nextVC = storyBoard.instantiateInitialViewController()
        let vc = (nextVC as? MyProfileViewController)
        
        vc!.userId = userId
        
        navigationController?.pushViewController(nextVC!, animated: true)
    }
    
    func goImageSpotlight(_ postImageUrlString: String) {
        let storyBoard = UIStoryboard(name: "ImageSpotlight", bundle: nil)
        let nextVC = storyBoard.instantiateInitialViewController()
        let vc = (nextVC as? ImageSpotlightViewController)
        
        vc!.postImageUrlString = postImageUrlString
        
        present(nextVC!, animated: true) {}
    }
}
