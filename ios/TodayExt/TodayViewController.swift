//
//  TodayViewController.swift
//  TodayExt
//
//  Created by Nickolay Truhin on 07.02.2020.
//  Copyright © 2020 The Chromium Authors. All rights reserved.
//

import UIKit
import NotificationCenter
import SQLite

class TodayViewController: UIViewController, NCWidgetProviding {
    @IBOutlet var tableView: UITableView!
    
    var data = [TimelineModel]()
    
    var messageView: TitleLabel = {
        var labelView = TitleLabel()
        labelView.translatesAutoresizingMaskIntoConstraints = false
        
        let color = Prefs.THEME_TEXT_PRIMARY.fromUserDefaults() as? String ?? "ff0000ff"
        labelView.textColor = UIColor(rgbStr: color)
        return labelView
    }()
    
    var messageIconView: TitleLabel = {
        var labelView = TitleLabel()
        labelView.translatesAutoresizingMaskIntoConstraints = false
        
        let color = Prefs.THEME_PRIMARY.fromUserDefaults() as? String ?? "ff0000ff"
        labelView.textColor = UIColor(rgbStr: color)
        labelView.font = UIFont.init(name: "TimetableIcons", size: 50)
        return labelView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        var dbExist = false
        
        do {
            try data = LessonsDatabase.getAll()
            
            dbExist = true
        } catch {}
        
        if dbExist {
            if data.isEmpty {
                let icon: FontIcon
                switch SearchItemTypeId.fromUserDefaults() {
                case .Group:
                    icon = FontIcon.beer
                case .Teacher:
                    icon = FontIcon.confetti
                }
                buildMessage(text: NSLocalizedString("freeDay", comment: ""), icon: icon)
            } else {
                tableView.delegate = self
                tableView.dataSource = self
                
                tableView.register(CustomCell.self, forCellReuseIdentifier: "custom")
                
                self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
            }
        } else {
            buildMessage(text: NSLocalizedString("noCache", comment: ""), icon: FontIcon.unknownLesson)
        }
    }
    
    func buildMessage(text: String, icon: FontIcon) {
        view.addSubview(messageIconView)
        messageIconView.text = icon.toStringIcon()
        messageIconView.textAlignment = .center
        messageIconView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        messageIconView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        messageIconView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20).isActive = true
        
        view.addSubview(messageView)
        messageView.text = text
        messageView.textAlignment = .center
        messageView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        messageView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        messageView.topAnchor.constraint(equalTo: messageIconView.bottomAnchor, constant: 10).isActive = true
    }

    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {

        if activeDisplayMode == NCWidgetDisplayMode.compact {
            //compact
            self.preferredContentSize = maxSize
        } else {
            //extended
            self.preferredContentSize = CGSize(width: maxSize.width, height: CGFloat(data.count * 88 + Int(TimelinePainter.rectMargins)))
        }
    }
}

extension TodayViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "custom") as! CustomCell
        cell.model = data[indexPath.row]
        return cell
    }
}

public extension URL {

    /// Returns a URL for the given app group and database pointing to the sqlite database.
    static func storeURL(for appGroup: String, databaseName: String) -> URL {
        guard let fileContainer = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup) else {
            fatalError("Shared file container could not be created.")
        }

        return fileContainer.appendingPathComponent("\(databaseName).db")
    }
}
