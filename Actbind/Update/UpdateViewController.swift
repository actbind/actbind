//
//  UpdateViewController.swift
//  Actbind
//
//  Created by 柿本　海斗 on 2020/12/17.
//

import UIKit

final class UpdateViewController: UIViewController {
    let userDefaults = UserDefaults(suiteName: "group.com.actbind")

    @IBOutlet weak var updateLabel: UILabel!
    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var updateButtonRight: NSLayoutConstraint!
    @IBOutlet weak var updateButtonLeft: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()

        updateLabel.text = "atarasiiba-jyonnni".localized()

        updateButton.backgroundColor = UIColor(named: "Blue")

        updateButton.setTitle("appude-to".localized(), for: .normal)
    }

    @IBAction func updateButtonTouchDown(_ sender: Any) {
        UIButton().uiButtonTapOn(item: updateButton, itemRight: updateButtonRight, itemLeft: updateButtonLeft)
    }

    @IBAction func updateButtonTouchDragOutside(_ sender: Any) {
        UIButton().uiButtonTapOff(item: updateButton, itemRight: updateButtonRight, itemLeft: updateButtonLeft)
    }

    @IBAction func updateButtonTouchUpInside(_ sender: Any) {
        UISelectionFeedbackGenerator().selectionChanged()
        
        UIButton().uiButtonTapOff(item: updateButton, itemRight: updateButtonRight, itemLeft: updateButtonLeft)

        // TestFlightアプリのURL
        let url = URL(string: "https://apps.apple.com/app/actbind/id1579280491")!

        // URLを開けるかをチェックする
        if UIApplication.shared.canOpenURL(url) {
            // URLを開く
            UIApplication.shared.open(url, options: [:]) { success in
                if success {
                    print("Launching \(url) was successful")
                }
            }
        }
    }
}
