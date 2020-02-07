//
//  CustomCell.swift
//  TodayExt
//
//  Created by Nickolay Truhin on 06.02.2020.
//  Copyright © 2020 The Chromium Authors. All rights reserved.
//

import UIKit

enum PrefsIds {
  case LAST_UPDATE,
      ROOM_LOCATION_STYLE,
      WIDGET_TRANSLUCENT,
      THEME_PRIMARY,
      THEME_ACCENT,
      THEME_TEXT_PRIMARY,
      THEME_TEXT_ACCENT,
      THEME_BACKGROUND,
      THEME_BRIGHTNESS,
      BEFORE_ALARM_CLOCK,
      END_CACHE,
      SEARCH_ITEM_PREFIX,
      ITEM_TYPE,
      ITEM_ID,
      ITEM_TITLE,
      SITE_API,
      OPTIMIZED_LESSON_TITLES,
    DAY_STYLE;
    
    func toString() -> String {
        var str: String
        switch self {
        case .LAST_UPDATE:
            str = "last_update"
        case .ROOM_LOCATION_STYLE:
            str = "room_location_style"
        case .WIDGET_TRANSLUCENT:
            str = "widget_translucent"
        case .THEME_PRIMARY:
            str = "theme_primary"
        case .THEME_ACCENT:
            str = "theme_accent"
        case .THEME_TEXT_PRIMARY:
            str = "theme_text_primary"
        case .THEME_TEXT_ACCENT:
            str = "theme_text_accent"
        case .THEME_BACKGROUND:
            str = "theme_background"
        case .THEME_BRIGHTNESS:
            str = "theme_brightness"
        case .BEFORE_ALARM_CLOCK:
            str = "before_alarm_clock"
        case .END_CACHE:
            str = "end_cache"
        case .SEARCH_ITEM_PREFIX:
            str = "primary_search_item_"
        case .ITEM_TYPE:
            str = "type"
        case .ITEM_ID:
            str = "id"
        case .ITEM_TITLE:
            str = "title"
        case .SITE_API:
            str = "site_api"
        case .OPTIMIZED_LESSON_TITLES:
            str = "optimized_lesson_titles"
        case .DAY_STYLE:
            str = "day_style"
        }
        
        return "flutter." + str
    }
}

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
        textView.text = "dfsfd"
        var df = UserDefaults(suiteName: "group.coolone.ranepatimetable.data")!.dictionaryRepresentation().keys
        debugPrint(df)
        textView.textColor = UIColor(rgb: UserDefaults(suiteName: "group.coolone.ranepatimetable.data")!
            .integer(forKey: PrefsIds.THEME_ACCENT.toString()))
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
            lessonView.lesson = lesson
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
