//
//  HomeViewController.swift
//  Actbind
//
//  Created by 柿本　海斗 on 2020/11/28.
//

import AudioToolbox
import CoreLocation
import UIKit

var scrollSwitch = "off"

final class HomeViewController: UIViewController, CLLocationManagerDelegate {
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
    
    var userId = 0
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var logoButton: UIButton!
    @IBOutlet weak var searchButton: UIBarButtonItem!
    let refreshControl = UIRefreshControl()
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var errorViewBottom: NSLayoutConstraint!
    
    private var isLoaded: Bool = false

    var locationManager: CLLocationManager!
    // 測位精度
    let locationAccuracy: [Double] = [
        kCLLocationAccuracyBestForNavigation,
        kCLLocationAccuracyBest,
        kCLLocationAccuracyNearestTenMeters,
        kCLLocationAccuracyHundredMeters,
        kCLLocationAccuracyKilometer,
        kCLLocationAccuracyThreeKilometers
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        HomeViewController.allUsers = []
        HomeViewController.allPosts = []
        
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(HomeViewController.refresh(sender:)), for: .valueChanged)
        
        if let userDefaults = userDefaults {
            let myColor = userDefaults.string(forKey: "mycolor")

            if myColor == "Original" {
                searchButton.tintColor = UIColor(named: "BlackWhite")
            } else {
                searchButton.tintColor = UIColor(named: myColor!)
            }
        }
        // locationManager初期化
        locationManager = CLLocationManager()

        // ユーザーの使用許可を確認
        locationManager.requestWhenInUseAuthorization()
                
        // 使用許可に対するステータス
        let status = CLLocationManager.authorizationStatus()
         
        if status == .authorizedWhenInUse {
            // delegateを設定
            locationManager.delegate = self
         
            // 測位精度の設定
            locationManager.desiredAccuracy = locationAccuracy[1]
                    
            // アップデートする距離半径(m)
            locationManager.distanceFilter = 10000
         
            // 位置情報の取得を開始
            locationManager.startUpdatingLocation()
        }
        
        errorViewBottom.constant = -60
        
        apiUser()
    }
    
    // 画面に表示される直前に呼ばれます。
    // viewDidLoadとは異なり毎回呼び出されます。
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if toHomeView == "on" {
            let UINavigationController = tabBarController?.viewControllers?[0]
            tabBarController?.selectedViewController = UINavigationController
            toHomeView = "off"
        }
        
        if scrollSwitch == "on" {
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            scrollSwitch = "off"
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        isLoaded = true
    }

    @IBAction func logoButtonTouchUpInside(_ sender: Any) {
        UISelectionFeedbackGenerator().selectionChanged()
        
        // セルのトップ
        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
    }
    
    @IBAction func searchButtonAction(_ sender: Any) {
        UISelectionFeedbackGenerator().selectionChanged()
        
        let storyBoard = UIStoryboard(name: "Search", bundle: nil)
        let nextVC = storyBoard.instantiateInitialViewController()
        
        navigationController?.pushViewController(nextVC!, animated: true)
    }
    
    @objc func refresh(sender: UIRefreshControl) {
        // ここに通信処理などデータフェッチの処理を書く
        apiUser()
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation])
    {
        // 最初のデータ
        let location = locations.first
     
        // 緯度
        let latitude = location?.coordinate.latitude
        // 経度
        let longitude = location?.coordinate.longitude
        
        UserDefaults.standard.set(latitude, forKey: "latitude")
        UserDefaults.standard.set(longitude, forKey: "longitude")
     
        // 位置情報の取得を停止
        locationManager.stopUpdatingLocation()
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
                        HomeViewController.allUsers = allUsers
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
        }
        
        let encoder = JSONEncoder()
        
        let body = Post(OperationType: "SCAN")
        
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
                        HomeViewController.allPosts = allPosts
                        print(allPosts)
                        print(allPosts.count)
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

extension HomeViewController: MainViewControllerProtocol {
    func onTapScrollToTop() {
        // 一番上に移動
        if isLoaded {
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
    }
}

// extensionは何かを追加していく ViewControllerというクラスの中にUITableViewDataSource機能を追加していく
extension HomeViewController: UITableViewDataSource {
    // tableviewの中に何個のセクションを追加するか
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    // 一つのtableviewの中に何個のセルが必要か
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // postの中を自動的に数える　　　postの分だけcellを作る
        Welcome.allWelcome.count + HomeViewController.allPosts.count
    }
    
    // tavleviewの中で使われているセルの特定
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == HomeViewController.allPosts.count {
            let welcomeCell = tableView.dequeueReusableCell(withIdentifier: "welcomeCell", for: indexPath) as! WelcomeTableViewCell
            
            // ここからの内容がセルに反映される
            // 順番にcellの方のpostに送っていく
            if HomeViewController.allPosts.count == 0 {
                welcomeCell.welcome = Welcome.allWelcome[indexPath.row]
            } else {
                welcomeCell.welcome = Welcome.allWelcome[indexPath.row - HomeViewController.allPosts.count]
            }
            welcomeCell.cellNumber()
            // ここまで
            return welcomeCell
        } else {
            let cellImage = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! PostTableViewCell
        
            // ここからの内容がセルに反映される
            // 順番にcellの方のpostに送っていく
            cellImage.post = HomeViewController.allPosts[indexPath.row]
            cellImage.cellNumber(indexPath: indexPath)
            cellImage.indexNumber = indexPath.row
            cellImage.delegate = self
            // ここまで
            return cellImage
        }
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
                
                HomeViewController.allPosts.remove(at: deleteIndex)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
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
    
    func goImageSpotlight(_ postImageUrlString: String) {
        let storyBoard = UIStoryboard(name: "ImageSpotlight", bundle: nil)
        let nextVC = storyBoard.instantiateInitialViewController()
        let vc = (nextVC as? ImageSpotlightViewController)
        
        vc!.postImageUrlString = postImageUrlString
        
        present(nextVC!, animated: true) {}
    }
}
