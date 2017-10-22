//
//  SettingTableViewController.swift
//  Babysnap
//
//  Created by ExtYabecchi on 2017/06/23.
//  Copyright © 2017年 ExtYabecchi. All rights reserved.
//

import Foundation
import UIKit

class SettingTableViewController: UITableViewController {

    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var autoSaveSwitch: UISwitch!
    @IBOutlet weak var soundLoopSwitch: UISwitch!
    
    override func viewWillAppear(_ animated: Bool) {
        if let settingData = RealmHelper.objects(type: Setting.self)?.first {
            autoSaveSwitch.isOn = settingData.autoSave
            soundLoopSwitch.isOn = settingData.soundloop
        }
    }
    
    override func tableView(_ table: UITableView,didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == 2  else { return }
        
        var linkAccount: String
        switch indexPath.row {
        case 0:
            linkAccount = "TWITTER_ACCOUNT"
        case 1:
            linkAccount = "INSTAGRAM_ACCOUNT"
        default:
            linkAccount = ""
        }

        guard let path = Bundle.main.path(forResource: "Info", ofType: "plist"),
            let value = NSDictionary(contentsOfFile: path)?.value(forKey: linkAccount) as AnyObject?,
            let url = URL(string: value as! String) else {
                return
        }
        
        if UIApplication.shared.canOpenURL(url){
            UIApplication.shared.openURL(url)
        }
    }
    
    @IBAction func switchAutoSave(_ sender: UISwitch) {
        if let data = RealmHelper.objects(type: Setting.self)?.first {
            data.update {
                data.autoSave = sender.isOn
            }
        }
    }
    
    @IBAction func switchSoundloop(_ sender: UISwitch) {
        if let data = RealmHelper.objects(type: Setting.self)?.first {
            data.update {
                data.soundloop = sender.isOn
            }
        }
    }
    
    
}
