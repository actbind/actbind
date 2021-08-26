//
//  SignUpNameViewController.swift
//  Actbind
//
//  Created by 柿本　海斗 on 2020/12/17.
//

import UIKit

final class SignUpNameViewController: UIViewController {
    @IBOutlet weak var signUpNameTitleLabel: UILabel!
    @IBOutlet weak var nameExplanationLabel: UILabel!
    @IBOutlet weak var name1TextField: UITextField!
    @IBOutlet weak var name2TextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var nextButtonRight: NSLayoutConstraint!
    @IBOutlet weak var nextButtonLeft: NSLayoutConstraint!
    @IBOutlet weak var haveAccountButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()

        signUpNameTitleLabel.text = "namaewonyuuryoku".localized()

        nameExplanationLabel.text = "namaesetumei".localized()

        if "language".localized() == "Arabic" || "language".localized() == "Chinese, Sim" || "language".localized() == "Chinese, Tra" || "language".localized() == "Hebrew" || "language".localized() == "Hungarian" || "language".localized() == "Japanese" || "language".localized() == "Korean" {
            name1TextField.textContentType = .familyName
            name2TextField.textContentType = .givenName
        } else {
            name1TextField.textContentType = .givenName
            name2TextField.textContentType = .familyName
        }

        name1TextField.uiTextFieldSetting(placeholder: "namae1".localized())

        name2TextField.uiTextFieldSetting(placeholder: "namae2".localized())

        nextButton.setTitle("tugihe".localized(), for: .normal)

        let attributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 12.0)]
        haveAccountButton.setTitleTextAttributes(attributes, for: UIControl.State.normal)
        haveAccountButton.title = "akaunntowoomotinokata".localized()
    }

    // キーボード以外をタップでキーボードが閉じる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

    // 完了キーをタップでキーボードが閉じる
    @IBAction func name1TextFieldDidEndOnExit(_ sender: Any) {}

    @IBAction func name1TextFieldEditingChanged(_ sender: Any) {
        name1TextField.text = name1TextField.text!.stringCharacterSetRemove(characterSet: .whitespaces)
        
        // name1TextFieldが入力されていない時
        if name1TextField.text == "" {
            nextButton.isEnabled = false
            nextButton.setTitleColor(UIColor(named: "EnabledButtonText"), for: .normal)
            nextButton.backgroundColor = UIColor(named: "EnabledButton")
            // name2TextFieldが入力されていない時
        } else if name2TextField.text == "" {
            nextButton.isEnabled = false
            nextButton.setTitleColor(UIColor(named: "EnabledButtonText"), for: .normal)
            nextButton.backgroundColor = UIColor(named: "EnabledButton")
            // name1TextFieldとname2TextFieldが入力されている時
        } else {
            nextButton.isEnabled = true
            nextButton.setTitleColor(UIColor(named: "White"), for: .normal)
            nextButton.backgroundColor = UIColor(named: "Blue")
        }
    }

    @IBAction func name1TextFieldEditingDidBegin(_ sender: Any) {
        name1TextField.layer.borderColor = UIColor.systemBlue.cgColor
    }

    @IBAction func name1TextFieldEditingDidEnd(_ sender: Any) {
        name1TextField.layer.borderColor = UIColor.lightGray.cgColor
    }

    // 完了キーをタップでキーボードが閉じる
    @IBAction func name2TextFieldDidEndOnExit(_ sender: Any) {}

    @IBAction func name2TextFieldEditingChanged(_ sender: Any) {
        name2TextField.text = name2TextField.text!.stringCharacterSetRemove(characterSet: .whitespaces)
        
        // name1TextFieldが入力されていない時
        if name1TextField.text == "" {
            nextButton.isEnabled = false
            nextButton.setTitleColor(UIColor(named: "EnabledButtonText"), for: .normal)
            nextButton.backgroundColor = UIColor(named: "EnabledButton")
            // name2TextFieldが入力されていない時
        } else if name2TextField.text == "" {
            nextButton.isEnabled = false
            nextButton.setTitleColor(UIColor(named: "EnabledButtonText"), for: .normal)
            nextButton.backgroundColor = UIColor(named: "EnabledButton")
            // name1TextFieldとname2TextFieldが入力されている時
        } else {
            nextButton.isEnabled = true
            nextButton.setTitleColor(UIColor(named: "White"), for: .normal)
            nextButton.backgroundColor = UIColor(named: "Blue")
        }
    }

    @IBAction func name2TextFieldEditingDidBegin(_ sender: Any) {
        name2TextField.layer.borderColor = UIColor.systemBlue.cgColor
    }

    @IBAction func name2TextFieldEditingDidEnd(_ sender: Any) {
        name2TextField.layer.borderColor = UIColor.lightGray.cgColor
    }

    @IBAction func nextButtonTouchDown(_ sender: Any) {
        UIButton().uiButtonTapOn(item: nextButton, itemRight: nextButtonRight, itemLeft: nextButtonLeft)
    }

    @IBAction func nextButtonTouchDragOutside(_ sender: Any) {
        UIButton().uiButtonTapOff(item: nextButton, itemRight: nextButtonRight, itemLeft: nextButtonLeft)
    }

    @IBAction func nextButtonTouchUpInside(_ sender: Any) {
        UISelectionFeedbackGenerator().selectionChanged()
        
        UIButton().uiButtonTapOff(item: nextButton, itemRight: nextButtonRight, itemLeft: nextButtonLeft)

        view.endEditing(true)

        let storyBoard = UIStoryboard(name: "SignUpMailAddress", bundle: nil)
        let nextVC = storyBoard.instantiateInitialViewController()
        let vc = (nextVC as? SignUpMailAddressViewController)
        
        let name1TextFieldNotwhitespaces = name1TextField.text!.stringCharacterSetRemove(characterSet: .whitespaces)
        let name2TextFieldNotwhitespaces = name2TextField.text!.stringCharacterSetRemove(characterSet: .whitespaces)
        // 値の設定
        vc!.name1 = name1TextFieldNotwhitespaces
        vc!.name2 = name2TextFieldNotwhitespaces
        
        navigationController?.pushViewController(nextVC!, animated: true)
    }

    @IBAction func haveAccountButton(_ sender: Any) {
        UISelectionFeedbackGenerator().selectionChanged()
        
        dismiss(animated: true, completion: nil)
    }
}
