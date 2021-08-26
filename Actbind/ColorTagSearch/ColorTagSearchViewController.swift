//
//  ColorTagSearchViewController.swift
//  Actbind
//
//  Created by 柿本海斗 on 2021/07/21.
//

import UIKit

final class ColorTagSearchViewController: UIViewController, UIGestureRecognizerDelegate {
    let userDefaults = UserDefaults(suiteName: "group.com.actbind")
    let api = KeyManager().getValue(key: "API") as? String
    
    struct Posts: Codable {
        let userId: Int
        let postId: Int
        let caption: String
        let postimageUrl: String
        let deleteDate: String
        let color: String
        let createDate: String
    }

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
    static var allPosts: [Posts] = []
    
    var color = ""
    
    @IBOutlet weak var navigationBarTitle: UINavigationItem!
    @IBOutlet weak var collectionView: UICollectionView!
    let refreshControl = UIRefreshControl()
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var errorViewBottom: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
        ColorTagSearchViewController.allUsers = []
        ColorTagSearchViewController.allPosts = []
        
        collectionView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(ColorTagSearchViewController.refresh(sender:)), for: .valueChanged)
        
        if color == "Red" {
            navigationBarTitle.title = "red".localized()
        } else if color == "Orange" {
            navigationBarTitle.title = "orange".localized()
        } else if color == "Yellow" {
            navigationBarTitle.title = "yellow".localized()
        } else if color == "Green" {
            navigationBarTitle.title = "green".localized()
        } else if color == "Blue" {
            navigationBarTitle.title = "blue".localized()
        } else {
            navigationBarTitle.title = "purple".localized()
        }
        
        if let userDefaults = userDefaults {
            let myColor = userDefaults.string(forKey: "mycolor")

            if myColor == "Original" {
                backButton.tintColor = UIColor(named: "BlackWhite")
            } else {
                backButton.tintColor = UIColor(named: myColor!)
            }
        }
        
        errorViewBottom.constant = -60
        
        setup()
        apiUser()
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
        
        collectionView.reloadData()
    }
    
    @objc func refresh(sender: UIRefreshControl) {
        // ここに通信処理などデータフェッチの処理を書く
        apiUser()
    }
    
    func setup() {
        // UICollectionViewCellのマージン等の設定
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: (UIScreen.main.bounds.width - 40) / 3 - 6,
                                     height: (UIScreen.main.bounds.width - 40) / 3 - 6)
        flowLayout.minimumInteritemSpacing = 8
        flowLayout.minimumLineSpacing = 8
        flowLayout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)

        collectionView.collectionViewLayout = flowLayout
    }
    
    func apiUser() {
        let url = URL(string: api! + "user")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST" // Postリクエストを送る(このコードがないとGetリクエストになる)
        request.addValue("application/json", forHTTPHeaderField: "content-type")
        // request.addValue("", forHTTPHeaderField: "authorization") //APIKey
        
        // 構造体を作成
        struct User: Codable {
            let OperationType: String
        }
        
        let encoder = JSONEncoder()
        
        let body = User(OperationType: "SCAN")
        
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
                if let allUsers = try? decoder.decode([Users].self, from: data) {
                    DispatchQueue.main.async {
                        ColorTagSearchViewController.allUsers = allUsers
                        print(allUsers)
                        print(allUsers.count)
                        self.apiPost()
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
    
    func apiPost() {
        let url = URL(string: api! + "post")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST" // Postリクエストを送る(このコードがないとGetリクエストになる)
        request.addValue("application/json", forHTTPHeaderField: "content-type")
        // request.addValue("", forHTTPHeaderField: "authorization") //APIKey
        
        // 構造体を作成
        struct Post: Codable {
            let OperationType: String
            let color: String
        }
        
        let encoder = JSONEncoder()
        
        let body = Post(OperationType: "COLORTAGSCAN", color: color)
        print(body)
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
                if let allPosts = try? decoder.decode([Posts].self, from: data) {
                    DispatchQueue.main.async {
                        ColorTagSearchViewController.allPosts = allPosts
                        print(allPosts)
                        print(allPosts.count)
                        self.refreshControl.endRefreshing()
                        self.collectionView.reloadData()
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
    
    @IBAction func backButtonAction(_ sender: Any) {
        UISelectionFeedbackGenerator().selectionChanged()
        
        navigationController?.popViewController(animated: true)
    }
}

// extensionは何かを追加していく ViewControllerというクラスの中にUITableViewDataSource機能を追加していく
extension ColorTagSearchViewController: UICollectionViewDataSource {
    // 一つのtableviewの中に何個のセルが必要か
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // postの中を自動的に数える　　　postの分だけcellを作る
        ColorTagSearchViewController.allPosts.count
    }
    
    // tavleviewの中で使われているセルの特定
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellImage = collectionView.dequeueReusableCell(withReuseIdentifier: "postCell", for: indexPath) as! ColorTagSearchCollectionViewCell
        
        // ここからの内容がセルに反映される
        // 順番にcellの方のpostに送っていく
        cellImage.post = ColorTagSearchViewController.allPosts[indexPath.row]
        cellImage.delegate = self
        // ここまで
        return cellImage
    }
    
    func goPostSpotlight(userId: Int, postId: Int, color: String) {
        let storyBoard = UIStoryboard(name: "PostSpotlight", bundle: nil)
        let nextVC = storyBoard.instantiateInitialViewController()
        let vc = (nextVC as? PostSpotlightViewController)
        
        vc!.userId = userId
        vc!.postId = postId
        vc!.color = color
        
        navigationController?.pushViewController(nextVC!, animated: true)
    }
}
