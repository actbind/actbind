//
//  SignUpOkViewController.swift
//  Actbind
//
//  Created by 柿本　海斗 on 2020/12/17.
//

import UIKit

final class SignUpOkViewController: UIViewController {
    @IBOutlet weak var signUpOkTitleLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var startButtonRight: NSLayoutConstraint!
    @IBOutlet weak var startButtonLeft: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()

        signUpOkTitleLabel.text = "actbindheyoukoso".localized()

        startButton.setTitle("hajimeru".localized(), for: .normal)

        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    @IBAction func startButtonTouchDown(_ sender: Any) {
        UIButton().uiButtonTapOn(item: startButton, itemRight: startButtonRight, itemLeft: startButtonLeft)
    }

    @IBAction func startButtonTouchDragOutside(_ sender: Any) {
        UIButton().uiButtonTapOff(item: startButton, itemRight: startButtonRight, itemLeft: startButtonLeft)
    }

    @IBAction func startButtonTouchUpInside(_ sender: Any) {
        UISelectionFeedbackGenerator().selectionChanged()
        
        UIButton().uiButtonTapOff(item: startButton, itemRight: startButtonRight, itemLeft: startButtonLeft)
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let nextVC = storyBoard.instantiateInitialViewController()
        
        present(nextVC!, animated: false) {}
    }
}
