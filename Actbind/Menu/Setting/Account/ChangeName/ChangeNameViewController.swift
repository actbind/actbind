//
//  ChangeNameViewController.swift
//  Actbind
//
//  Created by 柿本　海斗 on 2020/12/02.
//

import UIKit

final class ChangeNameViewController: UIViewController, UIGestureRecognizerDelegate {
    let userDefaults = UserDefaults(suiteName: "group.com.actbind")
    
    @IBOutlet weak var navigationBarTitle: UINavigationItem!
    @IBOutlet weak var nameExplanationLabel: UILabel!
    @IBOutlet weak var name1TextField: UITextField!
    @IBOutlet weak var name2TextField: UITextField!
    @IBOutlet weak var confirmationButton: UIButton!
    @IBOutlet weak var confirmationButtonRight: NSLayoutConstraint!
    @IBOutlet weak var confirmationButtonLeft: NSLayoutConstraint!
    @IBOutlet weak var backButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
        navigationBarTitle.title = "namae".localized()

        if let userDefaults = userDefaults {
            let myColor = userDefaults.string(forKey: "mycolor")
            let name1 = userDefaults.string(forKey: "name1")
            let name2 = userDefaults.string(forKey: "name2")

            if myColor == "Original" {
                backButton.tintColor = UIColor(named: "BlackWhite")
                confirmationButton.backgroundColor = UIColor(named: "Blue")
                name1TextField.tintColor = UIColor(named: "Blue")
                name2TextField.tintColor = UIColor(named: "Blue")
            } else {
                backButton.tintColor = UIColor(named: myColor!)
                confirmationButton.backgroundColor = UIColor(named: myColor!)
                name1TextField.tintColor = UIColor(named: myColor!)
                name2TextField.tintColor = UIColor(named: myColor!)
            }

            name1TextField.text = name1

            name2TextField.text = name2
        }
        
        backButton.image = UIImage(named: "back")

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
        
        confirmationButton.setTitle("kakuninn".localized(), for: .normal)
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

    @IBAction func name1TextFieldDidEndOnExit(_ sender: Any) {}

    @IBAction func name1TextFieldEditingChanged(_ sender: Any) {
        name1TextField.text = name1TextField.text!.stringCharacterSetRemove(characterSet: .whitespaces)
        
        if let userDefaults = userDefaults {
            let myColor = userDefaults.string(forKey: "mycolor")

            // name1TextFieldが入力されていない時
            if name1TextField.text == "" {
                confirmationButton.isEnabled = false
                confirmationButton.setTitleColor(UIColor(named: "EnabledButtonText"), for: .normal)
                confirmationButton.backgroundColor = UIColor(named: "EnabledButton")
                // name2TextFieldが入力されていない時
            } else if name2TextField.text == "" {
                confirmationButton.isEnabled = false
                confirmationButton.setTitleColor(UIColor(named: "EnabledButtonText"), for: .normal)
                confirmationButton.backgroundColor = UIColor(named: "EnabledButton")
            } else {
                if myColor == "Original" {
                    confirmationButton.isEnabled = true
                    confirmationButton.setTitleColor(UIColor(named: "White"), for: .normal)
                    confirmationButton.backgroundColor = UIColor(named: "Blue")
                } else {
                    confirmationButton.isEnabled = true
                    confirmationButton.setTitleColor(UIColor(named: "White"), for: .normal)
                    confirmationButton.backgroundColor = UIColor(named: myColor!)
                }
            }
        }
    }

    @IBAction func name1TextFieldEditingDidBegin(_ sender: Any) {
        if let userDefaults = userDefaults {
            let myColor = userDefaults.string(forKey: "mycolor")
            
            if myColor == "Original" || myColor == "Blue" {
                name1TextField.layer.borderColor = UIColor.systemBlue.cgColor
            } else if myColor == "Red" {
                name1TextField.layer.borderColor = UIColor.systemRed.cgColor
            } else if myColor == "Orange" {
                name1TextField.layer.borderColor = UIColor.systemOrange.cgColor
            } else if myColor == "Yellow" {
                name1TextField.layer.borderColor = UIColor.systemYellow.cgColor
            } else if myColor == "Green" {
                name1TextField.layer.borderColor = UIColor.systemGreen.cgColor
            } else {
                name1TextField.layer.borderColor = UIColor.systemPurple.cgColor
            }
        }
    }

    @IBAction func name1TextFieldEditingDidEnd(_ sender: Any) {
        name1TextField.layer.borderColor = UIColor.lightGray.cgColor
    }

    @IBAction func name2TextFieldDidEndOnExit(_ sender: Any) {}
    
    @IBAction func name2TextFieldEditingChanged(_ sender: Any) {
        name2TextField.text = name2TextField.text!.stringCharacterSetRemove(characterSet: .whitespaces)
        
        if let userDefaults = userDefaults {
            let myColor = userDefaults.string(forKey: "mycolor")

            // name1TextFieldが入力されていない時
            if name1TextField.text == "" {
                confirmationButton.isEnabled = false
                confirmationButton.setTitleColor(UIColor(named: "EnabledButtonText"), for: .normal)
                confirmationButton.backgroundColor = UIColor(named: "EnabledButton")
                // name2TextFieldが入力されていない時
            } else if name2TextField.text == "" {
                confirmationButton.isEnabled = false
                confirmationButton.setTitleColor(UIColor(named: "EnabledButtonText"), for: .normal)
                confirmationButton.backgroundColor = UIColor(named: "EnabledButton")
            } else {
                if myColor == "Original" {
                    confirmationButton.isEnabled = true
                    confirmationButton.setTitleColor(UIColor(named: "White"), for: .normal)
                    confirmationButton.backgroundColor = UIColor(named: "Blue")
                } else {
                    confirmationButton.isEnabled = true
                    confirmationButton.setTitleColor(UIColor(named: "White"), for: .normal)
                    confirmationButton.backgroundColor = UIColor(named: myColor!)
                }
            }
        }
    }

    @IBAction func name2TextFieldEditingDidBegin(_ sender: Any) {
        if let userDefaults = userDefaults {
            let myColor = userDefaults.string(forKey: "mycolor")
            
            if myColor == "Original" || myColor == "Blue" {
                name2TextField.layer.borderColor = UIColor.systemBlue.cgColor
            } else if myColor == "Red" {
                name2TextField.layer.borderColor = UIColor.systemRed.cgColor
            } else if myColor == "Orange" {
                name2TextField.layer.borderColor = UIColor.systemOrange.cgColor
            } else if myColor == "Yellow" {
                name2TextField.layer.borderColor = UIColor.systemYellow.cgColor
            } else if myColor == "Green" {
                name2TextField.layer.borderColor = UIColor.systemGreen.cgColor
            } else {
                name2TextField.layer.borderColor = UIColor.systemPurple.cgColor
            }
        }
    }

    @IBAction func name2TextFieldEditingDidEnd(_ sender: Any) {
        name2TextField.layer.borderColor = UIColor.lightGray.cgColor
    }

    @IBAction func confirmationButtonTouchDown(_ sender: Any) {
        UIButton().uiButtonTapOn(item: confirmationButton, itemRight: confirmationButtonRight, itemLeft: confirmationButtonLeft)
    }
    
    @IBAction func confirmationButtonTouchDragOutside(_ sender: Any) {
        UIButton().uiButtonTapOff(item: confirmationButton, itemRight: confirmationButtonRight, itemLeft: confirmationButtonLeft)
    }
    
    @IBAction func confirmationButtonTouchUpInside(_ sender: Any) {
        UISelectionFeedbackGenerator().selectionChanged()
        
        UIButton().uiButtonTapOff(item: confirmationButton, itemRight: confirmationButtonRight, itemLeft: confirmationButtonLeft)
        
        name1TextField.endEditing(true)
        name2TextField.endEditing(true)

        let name1TextFieldNotwhitespaces = name1TextField.text!.stringCharacterSetRemove(characterSet: .whitespaces)
        let name2TextFieldNotwhitespaces = name2TextField.text!.stringCharacterSetRemove(characterSet: .whitespaces)

        if let userDefaults = userDefaults {
            let name1 = userDefaults.string(forKey: "name1")
            let name2 = userDefaults.string(forKey: "name2")
        
            if name1TextFieldNotwhitespaces == name1 {
                if name2TextFieldNotwhitespaces == name2 {
                    navigationController?.popViewController(animated: true)
                } else {
                    let storyBoard = UIStoryboard(name: "SaveNewInformation", bundle: nil)
                    let nextVC = storyBoard.instantiateInitialViewController()
                    let vc = (nextVC as? SaveNewInformationViewController)
                    
                    let name1TextFieldNotwhitespaces = name1TextField.text!.stringCharacterSetRemove(characterSet: .whitespaces)
                    let name2TextFieldNotwhitespaces = name2TextField.text!.stringCharacterSetRemove(characterSet: .whitespaces)
                    
                    // 値の設定
                    vc!.name1 = name1TextFieldNotwhitespaces
                    vc!.name2 = name2TextFieldNotwhitespaces
                    
                    navigationController?.pushViewController(nextVC!, animated: true)
                }
            } else {
                let storyBoard = UIStoryboard(name: "SaveNewInformation", bundle: nil)
                let nextVC = storyBoard.instantiateInitialViewController()
                let vc = (nextVC as? SaveNewInformationViewController)
                
                let name1TextFieldNotwhitespaces = name1TextField.text!.stringCharacterSetRemove(characterSet: .whitespaces)
                let name2TextFieldNotwhitespaces = name2TextField.text!.stringCharacterSetRemove(characterSet: .whitespaces)
                
                // 値の設定
                vc!.name1 = name1TextFieldNotwhitespaces
                vc!.name2 = name2TextFieldNotwhitespaces
                
                navigationController?.pushViewController(nextVC!, animated: true)
            }
        }
    }

    @IBAction func backBottonAction(_ sender: Any) {
        UISelectionFeedbackGenerator().selectionChanged()
        
        navigationController?.popViewController(animated: true)
    }
}
