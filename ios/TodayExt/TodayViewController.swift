//
//  TodayViewController.swift
//  TodayExt
//
//  Created by Nickolay Truhin on 07.02.2020.
//  Copyright © 2020 The Chromium Authors. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
    @IBOutlet var tableView: UITableView!
    @IBOutlet var testLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        let prefs = UserDefaults.init(suiteName: "group.coolone.ranepatimetable.data")
        
        debugPrint("keys: \(prefs!.dictionaryRepresentation().keys)")
        
        testLabel.text = prefs?.string(forKey: "flutter.theme_accent") ?? "nil"
        
        completionHandler(NCUpdateResult.newData)
    }
}
