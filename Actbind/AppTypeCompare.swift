//
//  AppTypeCompare.swift
//  Actbind
//
//  Created by 柿本海斗 on 2021/08/25.
//

import Foundation

enum AppTypeCompareType {
    case release
    case beta
    case error
}

enum AppTypeCompare {
    static func toAppStoreVersion(completion: @escaping (AppTypeCompareType) -> Void) {
        guard let url = URL(string: "https://itunes.apple.com/lookup?id=1579280491") else {
            completion(.error)

            return
        }

        let request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 60)
        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, _, _ in
            guard let data = data else {
                completion(.error)

                return
            }

            do {
                let jsonData = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                guard let storeVersion = ((jsonData?["results"] as? [Any])?.first as? [String: Any])?["version"] as? String,
                      let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
                else {
                    completion(.error)

                    return
                }

                switch storeVersion.compare(appVersion, options: .numeric) {
                case .orderedAscending:
                    // appVersion > storeVersion
                    completion(.beta)
                case .orderedSame, .orderedDescending:
                    // storeVersion >= appVersion
                    completion(.release)
                }
            } catch {
                completion(.error)
            }
        })

        task.resume()
    }
}
