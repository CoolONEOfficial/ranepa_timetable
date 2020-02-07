//
//  TodayViewController.swift
//  TodayExt
//
//  Created by Nickolay Truhin on 07.02.2020.
//  Copyright © 2020 The Chromium Authors. All rights reserved.
//

import UIKit
import NotificationCenter

struct CustomCellData {
    let lesson: String?
}

class TodayViewController: UIViewController, NCWidgetProviding {
    @IBOutlet var tableView: UITableView!

    var data = [CustomCellData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        tableView.delegate = self
        tableView.dataSource = self
        
        data = [
            CustomCellData.init(lesson: "dfsdf"),
            CustomCellData.init(lesson: "nn"),
            CustomCellData.init(lesson: "657567"),
            CustomCellData.init(lesson: "dfsdf"),
            CustomCellData.init(lesson: "dfsdf"),
            CustomCellData.init(lesson: "dfsdf")
        ]
        
        tableView.register(CustomCell.self, forCellReuseIdentifier: "custom")
    }

    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
//        let prefs = UserDefaults.init(suiteName: "group.coolone.ranepatimetable.data")
//
//        debugPrint("keys: \(prefs!.dictionaryRepresentation().keys)")
        
        completionHandler(NCUpdateResult.newData)
    }
}

extension TodayViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "custom") as! CustomCell
        cell.lesson = data[indexPath.row].lesson
        return cell
    }
}
