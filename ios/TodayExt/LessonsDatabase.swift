//
//  LessonsDatabase.swift
//  TodayExt
//
//  Created by Nickolay Truhin on 07.02.2020.
//  Copyright © 2020 The Chromium Authors. All rights reserved.
//

import Foundation
import SQLite

class LessonsDatabase {
    static let db: Connection = try! Connection(URL.storeURL(for: "group.coolone.ranepatimetable.data", databaseName: "timetable").path)
    
    static let table = Table("lessons")
    
    static func getAll() throws -> [TimelineModel] {
        var lessons = [TimelineModel]()
        let midnight = Calendar.current.date(byAdding: .day, value: 1, to:
            Calendar(identifier: .gregorian).startOfDay(for: Date()))!
        
        for data in try self.db.prepare(table
            .filter(TimelineModel.TableKeys.date == Int(midnight.timeIntervalSince1970 * 1000))
            ) {
//                let model = TimelineModel.init(data)
//                debugPrint("\(model.date) and \(midnight)")
                lessons.append(TimelineModel.init(data))
        }
    
        return lessons
    }
}

struct TimelineModel {
    
    let date: Date
    let lesson: LessonModel
    let teacher: TeacherModel
    let group: String
    let room: RoomModel
    let start: TimeModel
    let finish: TimeModel
    let first, last: Bool
    let mergeBottom, mergeTop: Bool
    
    init(_ data: Row) {
        date = Date(timeIntervalSince1970: Double(data[TableKeys.date] / 1000))
        lesson = LessonModel.init(data)
        teacher = TeacherModel.init(data)
        room = RoomModel.init(data)
        start = TimeModel.init(data, prefix: "start")
        finish = TimeModel.init(data, prefix: "finish")
        group = data[TableKeys.group]
        mergeTop = data[TableKeys.mergeTop]
        mergeBottom = data[TableKeys.mergeBottom]
        first = data[TableKeys.first]
        last = data[TableKeys.last]
    }
    
    class TableKeys {
        static let
            date = Expression<Int>("date"),
            group = Expression<String>("group"),
            first = Expression<Bool>("first"),
            last = Expression<Bool>("last"),
            mergeTop = Expression<Bool>("mergeTop"),
            mergeBottom = Expression<Bool>("mergeBottom")
    }
}

struct LessonModel {
    let title: String
    let fullTitle: String
    let iconCodePoint: Int
    let actionTitle: String
    
    init(_ data: Row) {
        title = data[TableKeys.title]
        fullTitle = data[TableKeys.fullTitle]
        iconCodePoint = data[TableKeys.iconCodePoint]
        actionTitle = data[TableKeys.actionTitle]
    }
    
    class TableKeys {
        static let
            title = Expression<String>("lesson_title"),
            fullTitle = Expression<String>("lesson_fullTitle"),
            iconCodePoint = Expression<Int>("lesson_iconCodePoint"),
            actionTitle = Expression<String>("lesson_action_title")
    }
}

struct TeacherModel {
    let name: String
    let surname: String
    let patronymic: String
    
    init(_ data: Row) {
        name = data[TableKeys.name]
        surname = data[TableKeys.surname]
        patronymic = data[TableKeys.patronymic]
    }
    
    func format() -> String {
        return "\(surname) \(name.prefix(1)). \(patronymic.prefix(1))."
    }
    
    class TableKeys {
        static let
            name = Expression<String>("teacher_name"),
            surname = Expression<String>("teacher_surname"),
            patronymic = Expression<String>("teacher_patronymic")
    }
}

struct RoomModel {
    let number: String
    let location: String
    
    init(_ data: Row) {
        number = data[TableKeys.number]
        location = data[TableKeys.location]
    }
    
    func formatNumber() -> String {
        switch RoomLocationStyle.fromUserDefaults() {
        case .Text:
            let prefix: String
            
            switch location {
            case Location.studyHostel:
                prefix = "СО-"
            case Location.hotel:
                prefix = "П8-"
            default:
                prefix = ""
            }
            
            return prefix + number
        case .Icon:
            return number
        }
    }
    
    func formatLocation() -> String {
        var icon: FontIcon
        switch location {
        case Location.studyHostel:
            icon = FontIcon.studyHostel
        case Location.hotel:
            icon = FontIcon.hotel
        default:
            icon = FontIcon.academy
        }
        return icon.toStringIcon()
    }
    
    class Location {
        static let
            studyHostel = "StudyHostel",
            hotel = "Hotel"
    }
    
    class TableKeys {
        static let
            number = Expression<String>("room_number"),
            location = Expression<String>("room_location")
    }
}

struct TimeModel {
    let hour: Int
    let minute: Int

    init(_ data: Row, prefix: String) {
        hour = data[Expression<Int>(prefix + "_hour")]
        minute = data[Expression<Int>(prefix + "_minute")]
    }
    
    func format() -> String {
        return "\(String(format: "%02d", hour)):\(String(format: "%02d", minute))"
    }
}
