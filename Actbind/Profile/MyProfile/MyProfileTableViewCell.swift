//
//  ProfileTableViewCell.swift
//  Actbind
//
//  Created by 柿本海斗 on 2021/03/02.
//

import Nuke
import UIKit

final class MyProfileTableViewCell: UITableViewCell {
    let userDefaults = UserDefaults(suiteName: "group.com.actbind")
    
    var delegate: MyProfileViewController?
    
    @IBOutlet weak var userProfileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var bioLabelTop: NSLayoutConstraint!
    @IBOutlet weak var websiteButton: UIButton!
    @IBOutlet weak var websiteButtonTop: NSLayoutConstraint!
    @IBOutlet weak var websiteButtonHeight: NSLayoutConstraint!
    @IBOutlet weak var profileEditButton: UIButton!
    @IBOutlet weak var profileEditButtonRight: NSLayoutConstraint!
    @IBOutlet weak var profileEditButtonLeft: NSLayoutConstraint!
    
    // ダミーのAPI
    var profile: Profile! {
        // didSet:表示された時にpostから情報を取ってきてUIを勝手にを更新する
        didSet {
            // 画面が表示された時に発動する
            updateUI()
        }
    }
    
    // private:このファイル内でしか使えないfuncの時
    private func updateUI() {
        if let userDefaults = userDefaults {
            let userName = userDefaults.string(forKey: "username")!
            let myColor = userDefaults.string(forKey: "mycolor")
            if myColor == "Original" {
                websiteButton.setTitleColor(UIColor(named: "Blue"), for: .normal)
                profileEditButton.backgroundColor = UIColor(named: "Blue")
            } else {
                websiteButton.setTitleColor(UIColor(named: myColor!), for: .normal)
                profileEditButton.backgroundColor = UIColor(named: myColor!)
            }
            
            let name1 = userDefaults.string(forKey: "name1")
            let name2 = userDefaults.string(forKey: "name2")
            let bio = userDefaults.string(forKey: "bio")
            let website = userDefaults.string(forKey: "website")
            let displayWebsite = String(website!.dropFirst(8))
            
            let profileimage = userDefaults.string(forKey: "profileimage")
            if profileimage == "Default" {
                userProfileImage.image = UIImage(named: "defaultProfileImage")
            } else {
                let profileImageUrlString = "https://www.actbind.com/" + userName + "/profile-image/" + profileimage!
                let userProfileImageURL = URL(string: profileImageUrlString)!
                Nuke.loadImage(with: userProfileImageURL, into: userProfileImage)
            }
            
            userProfileImage.cornerAll(value: 0, fulcrum: "width")
            nameLabel.text = name1! + " " + name2!
            bioLabel.text = bio
            websiteButton.setTitle(displayWebsite, for: .normal)
        }
        
        profileEditButton.setTitle("purofi-ruwohennsyuu".localized(), for: .normal)
        
        if bioLabel.text == "" {
            bioLabelTop.constant = 0
        } else {
            bioLabelTop.constant = 8
        }
        
        if websiteButton.currentTitle == "" {
            websiteButtonHeight.constant = 0
            websiteButtonTop.constant = 0
        } else {
            websiteButtonHeight.constant = 15
            websiteButtonTop.constant = 8
        }
    }
    
    @IBAction func websiteButtonTouchDown(_ sender: Any) {
        if let userDefaults = userDefaults {
            let myColor = userDefaults.string(forKey: "mycolor")

            if myColor == "Original" {
                websiteButton.backgroundColor = UIColor(named: "BlueHalf")
            } else if myColor == "Red" {
                websiteButton.backgroundColor = UIColor(named: "RedHalf")
            } else if myColor == "Orange" {
                websiteButton.backgroundColor = UIColor(named: "OrangeHalf")
            } else if myColor == "Yellow" {
                websiteButton.backgroundColor = UIColor(named: "YellowHalf")
            } else if myColor == "Green" {
                websiteButton.backgroundColor = UIColor(named: "GreenHalf")
            } else if myColor == "Blue" {
                websiteButton.backgroundColor = UIColor(named: "BlueHalf")
            } else {
                websiteButton.backgroundColor = UIColor(named: "PurpleHalf")
            }
        }
    }
    
    @IBAction func websiteButtonTouchDragOutside(_ sender: Any) {
        websiteButton.backgroundColor = UIColor.clear
    }
    
    @IBAction func websiteButtonTouchUpInside(_ sender: Any) {
        UISelectionFeedbackGenerator().selectionChanged()
        
        websiteButton.backgroundColor = UIColor.clear
        
        delegate?.goWeb(website: "https://" + websiteButton.currentTitle!)
    }
    
    @IBAction func profileEditButtonTouchDown(_ sender: Any) {
        UIButton().uiButtonTapOn(item: profileEditButton, itemRight: profileEditButtonRight, itemLeft: profileEditButtonLeft)
    }
    
    @IBAction func profileEditButtonTouchDragOutside(_ sender: Any) {
        UIButton().uiButtonTapOff(item: profileEditButton, itemRight: profileEditButtonRight, itemLeft: profileEditButtonLeft)
    }
    
    @IBAction func profileEditButtonTouchUpInside(_ sender: Any) {
        UISelectionFeedbackGenerator().selectionChanged()
        
        UIButton().uiButtonTapOff(item: profileEditButton, itemRight: profileEditButtonRight, itemLeft: profileEditButtonLeft)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
