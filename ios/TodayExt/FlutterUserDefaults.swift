//
//  FlutterUserDefaults.swift
//  TodayExt
//
//  Created by Nickolay Truhin on 07.02.2020.
//  Copyright © 2020 The Chromium Authors. All rights reserved.
//

import Foundation

enum Prefs {
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

    func fromUserDefaults() -> String? {
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

        return FlutterUserDefaults.userDefaults.string(forKey: "flutter.\(str)")
    }
}

class FlutterUserDefaults {
    static private var userDefaultsInstance: UserDefaults?
    
    static var userDefaults: UserDefaults {
        get {
            if userDefaultsInstance == nil {
                userDefaultsInstance = UserDefaults.init(suiteName: "group.coolone.ranepatimetable.data")
            }
            return self.userDefaultsInstance!
        }
    }
}
