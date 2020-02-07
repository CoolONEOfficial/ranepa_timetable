//
//  CustomCell.swift
//  TodayExt
//
//  Created by Nickolay Truhin on 06.02.2020.
//  Copyright © 2020 The Chromium Authors. All rights reserved.
//

import UIKit

extension UIColor {
   convenience init(red: Int, green: Int, blue: Int) {
       assert(red >= 0 && red <= 255, "Invalid red component")
       assert(green >= 0 && green <= 255, "Invalid green component")
       assert(blue >= 0 && blue <= 255, "Invalid blue component")

       self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
   }

   convenience init(rgb: Int) {
       self.init(
           red: (rgb >> 16) & 0xFF,
           green: (rgb >> 8) & 0xFF,
           blue: rgb & 0xFF
       )
   }
    
    convenience init(rgbStr: String) {
        self.init(
            rgb: Int(rgbStr, radix: 16)!
        )
    }
}

class CustomCell: UITableViewCell {
    var lesson: String?
    
    var lessonView: LessonPainter = {
        var painter = LessonPainter()
        painter.translatesAutoresizingMaskIntoConstraints = false
        return painter
    }()
    
    var textView: UITextView = {
        var textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        let pres = UserDefaults(suiteName: "group.coolone.ranepatimetable.data")!.dictionaryRepresentation()
        debugPrint("keys: \(pres.keys)")
        debugPrint("key: \(PrefsIds.THEME_PRIMARY.toString())")
        debugPrint("theme primary: \(UserDefaults(suiteName: "group.coolone.ranepatimetable.data")!.string(forKey: PrefsIds.THEME_PRIMARY.toString())!)")
        textView.textColor = UIColor(rgbStr: UserDefaults(suiteName: "group.coolone.ranepatimetable.data")!
            .string(forKey: PrefsIds.THEME_PRIMARY.toString())!)
        return textView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.addSubview(lessonView)

        lessonView.backgroundColor = UIColor(white: 1, alpha: 0)

        lessonView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        lessonView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        lessonView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        lessonView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true

        self.addSubview(textView)
        textView.backgroundColor = UIColor(white: 1, alpha: 0)
        textView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        textView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        textView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        textView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let lesson = lesson {
            textView.text = lesson
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
