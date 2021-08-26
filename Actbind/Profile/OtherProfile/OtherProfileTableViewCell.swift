//
//  OtherProfileTableViewCell.swift
//  Actbind
//
//  Created by 柿本海斗 on 2021/07/03.
//

import Nuke
import UIKit

final class OtherProfileTableViewCell: UITableViewCell {
    let userDefaults = UserDefaults(suiteName: "group.com.actbind")
    
    var delegate: OtherProfileViewController?
    
    @IBOutlet weak var userProfileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var bioLabelTop: NSLayoutConstraint!
    @IBOutlet weak var websiteButton: UIButton!
    @IBOutlet weak var websiteButtonTop: NSLayoutConstraint!
    @IBOutlet weak var websiteButtonHeight: NSLayoutConstraint!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var followButtonRight: NSLayoutConstraint!
    @IBOutlet weak var followButtonLeft: NSLayoutConstraint!
    
    // ダミーのAPI
    var user: OtherProfileViewController.OtherUsers? {
        // didSet:表示された時にpostから情報を取ってきてUIを勝手にを更新する
        didSet {
            // 画面が表示された時に発動する
            updateUI()
        }
    }
    
    // private:このファイル内でしか使えないfuncの時
    private func updateUI() {
        if let userDefaults = userDefaults {
            let myColor = userDefaults.string(forKey: "mycolor")
            if myColor == "Original" {
                websiteButton.setTitleColor(UIColor(named: "Blue"), for: .normal)
                // followButton.backgroundColor = UIColor(named: "Blue")
            } else {
                websiteButton.setTitleColor(UIColor(named: myColor!), for: .normal)
                // followButton.backgroundColor = UIColor(named: myColor!)
            }
    
            if user!.profileimageUrl == "Default" {
                userProfileImage.image = UIImage(named: "defaultProfileImage")
            } else {
                let profileImageUrlString = "https://www.actbind.com/" + user!.userName + "/profile-image/" + user!.profileimageUrl
                let userProfileImageURL = URL(string: profileImageUrlString)!
                Nuke.loadImage(with: userProfileImageURL, into: userProfileImage)
            }
            
            userProfileImage.cornerAll(value: 0, fulcrum: "width")
            let name1 = user!.name1
            let name2 = user!.name2
            let name = name1 + " " + name2
            let website = user!.website
            let displayWebsite = String(website.dropFirst(8))
            
            nameLabel.text = name
            bioLabel.text = user!.bio
            
            websiteButton.setTitle(displayWebsite, for: .normal)
        }
        
        // followButton.setTitle("foro-".localized(), for: .normal)
        
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
    
    @IBAction func followButtonTouchDown(_ sender: Any) {
        UIButton().uiButtonTapOn(item: followButton, itemRight: followButtonRight, itemLeft: followButtonLeft)
    }
    
    @IBAction func followButtonTouchDragOutside(_ sender: Any) {
        UIButton().uiButtonTapOff(item: followButton, itemRight: followButtonRight, itemLeft: followButtonLeft)
    }
    
    @IBAction func followButtonTouchUpInside(_ sender: Any) {
        UISelectionFeedbackGenerator().selectionChanged()
        
        UIButton().uiButtonTapOff(item: followButton, itemRight: followButtonRight, itemLeft: followButtonLeft)
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
