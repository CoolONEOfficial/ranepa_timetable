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

class TitleLabel: UILabel {
    override func draw(_ rect: CGRect) {
        super.drawText(in: rect.insetBy(dx: 5, dy: 0))
    }
}

public enum FontIcon: UInt32 {
    case studyHostel = 0xe802,
        hotel = 0xe801,
        academy = 0xe81b,
        beer = 0xe838,
        confetti = 0xe839,
        unknownLesson = 0xe826
    
    func toStringIcon() -> String {
        return FontIcon.intToStringIcon(self.rawValue)
    }
    
    static func intToStringIcon(_ int: UInt32) -> String {
        var rawIcon = int
        let xPtr = withUnsafeMutablePointer(to: &rawIcon, { $0 })
        return String(bytesNoCopy: xPtr, length:MemoryLayout<UInt32>.size, encoding: String.Encoding.utf32LittleEndian, freeWhenDone: false)!
    }
}

class CustomCell: UITableViewCell {
    var model: TimelineModel?
    
    var painterView: TimelinePainter = {
        var painterView = TimelinePainter()
        painterView.translatesAutoresizingMaskIntoConstraints = false
        return painterView
    }()
    
    var painterContentView: UIView = {
        var contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        return contentView
    }()
    
    var startView: UILabel = {
        var labelView = UILabel()
        labelView.translatesAutoresizingMaskIntoConstraints = false
        
        let color = Prefs.THEME_TEXT_PRIMARY.fromUserDefaults() as? String ?? "ff0000ff"
        debugPrint("theme primary: \(color)")
        labelView.textColor = UIColor(rgbStr: color)
        labelView.font = labelView.font.withSize(20)
        return labelView
    }()
    
    var finishView: UILabel = {
        var labelView = UILabel()
        labelView.translatesAutoresizingMaskIntoConstraints = false

        let color = Prefs.THEME_TEXT_PRIMARY.fromUserDefaults() as? String ?? "ff0000ff"
        labelView.textColor = UIColor(rgbStr: color)
        labelView.font = labelView.font.withSize(14)
        return labelView
    }()

    var locationView: UILabel = {
        var labelView = UILabel()
        labelView.translatesAutoresizingMaskIntoConstraints = false

        let color = Prefs.THEME_TEXT_PRIMARY.fromUserDefaults() as? String ?? "ff0000ff"
        labelView.textColor = UIColor(rgbStr: color)
        labelView.font = labelView.font.withSize(14)
        return labelView
    }()
    
    var locationIconView: UILabel = {
        var labelView = UILabel()
        labelView.translatesAutoresizingMaskIntoConstraints = false

        let color = Prefs.THEME_TEXT_PRIMARY.fromUserDefaults() as? String ?? "ff0000ff"
        labelView.textColor = UIColor(rgbStr: color)
        labelView.font = UIFont.init(name: "TimetableIcons", size: 20)
        return labelView
    }()
    
    var iconView: UILabel = {
        var labelView = UILabel()
        labelView.translatesAutoresizingMaskIntoConstraints = false
        
        let color = Prefs.THEME_TEXT_ACCENT.fromUserDefaults() as? String ?? "ff0000ff"
        labelView.textColor = UIColor(rgbStr: color)
        labelView.font = UIFont.init(name: "TimetableIcons", size: 20)
        return labelView
    }()
    
    var lessonTypeView: TitleLabel = {
        var labelView = TitleLabel()
        labelView.translatesAutoresizingMaskIntoConstraints = false
        
        let color = Prefs.THEME_TEXT_PRIMARY.fromUserDefaults() as? String ?? "ff0000ff"
        labelView.textColor = UIColor(rgbStr: color)
        labelView.font = labelView.font.withSize(14)
        return labelView
    }()
    
    var teacherGroupView: TitleLabel = {
        var labelView = TitleLabel()
        labelView.translatesAutoresizingMaskIntoConstraints = false
        
        let color = Prefs.THEME_TEXT_PRIMARY.fromUserDefaults() as? String ?? "ff0000ff"
        labelView.textColor = UIColor(rgbStr: color)
        labelView.font = labelView.font.withSize(14)
        return labelView
    }()
    
    var titleView: TitleLabel = {
        var labelView = TitleLabel()
        labelView.translatesAutoresizingMaskIntoConstraints = false
        
        let color = Prefs.THEME_TEXT_PRIMARY.fromUserDefaults() as? String ?? "ff0000ff"
        labelView.textColor = UIColor(rgbStr: color)
        labelView.lineBreakMode = .byWordWrapping
        labelView.numberOfLines = 0
        return labelView
    }()
    
    static let innerPadding = 4.0,
        leftContentWidth = CGFloat(68 - innerPadding);
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.addSubview(painterView)
        painterView.backgroundColor = UIColor(white: 1, alpha: 0)
        painterView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        painterView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        painterView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        painterView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true

        self.addSubview(painterContentView)
        painterContentView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: CGFloat(TimelinePainter.rectMargins * 2)).isActive = true
        painterContentView.topAnchor.constraint(equalTo: self.topAnchor, constant: CGFloat(TimelinePainter.rectMargins * 2)).isActive = true
        painterContentView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -CGFloat(TimelinePainter.rectMargins)).isActive = true
        painterContentView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -CGFloat(TimelinePainter.rectMargins * 2)).isActive = true

        painterContentView.addSubview(startView)
        startView.textAlignment = .center
        startView.leftAnchor.constraint(equalTo: painterContentView.leftAnchor).isActive = true
        startView.topAnchor.constraint(equalTo: painterContentView.topAnchor).isActive = true
        startView.addConstraint(NSLayoutConstraint(item: startView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: CustomCell.leftContentWidth))

        painterContentView.addSubview(finishView)
        finishView.textAlignment = .center
        finishView.leftAnchor.constraint(equalTo: startView.leftAnchor).isActive = true
        finishView.rightAnchor.constraint(equalTo: startView.rightAnchor).isActive = true
        finishView.topAnchor.constraint(equalTo: startView.bottomAnchor).isActive = true
        
        painterContentView.addSubview(locationView)
        locationView.textAlignment = .left
        locationView.topAnchor.constraint(equalTo: finishView.bottomAnchor, constant: 5).isActive = true
        
        switch RoomLocationStyle.fromUserDefaults() {
        case .Text:
            locationView.textAlignment = .center
            
            locationView.leftAnchor.constraint(equalTo: startView.leftAnchor).isActive = true
            locationView.rightAnchor.constraint(equalTo: startView.rightAnchor).isActive = true
        case .Icon:
            locationView.textAlignment = .left
            painterContentView.addSubview(locationIconView)
            
            locationIconView.leftAnchor.constraint(equalTo: startView.leftAnchor).isActive = true
            locationIconView.topAnchor.constraint(equalTo: finishView.bottomAnchor, constant: 2).isActive = true
            locationView.leftAnchor.constraint(equalTo: locationIconView.rightAnchor, constant: 5).isActive = true
        }
        
        painterContentView.addSubview(iconView)
        iconView.textAlignment = .center
        iconView.addConstraint(NSLayoutConstraint(item: iconView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 54))
        iconView.leftAnchor.constraint(equalTo: startView.rightAnchor).isActive = true
        iconView.topAnchor.constraint(equalTo: painterContentView.topAnchor).isActive = true
        iconView.bottomAnchor.constraint(equalTo: painterContentView.bottomAnchor).isActive = true
     
        painterContentView.addSubview(lessonTypeView)
        lessonTypeView.leftAnchor.constraint(equalTo: iconView.rightAnchor).isActive = true
        lessonTypeView.topAnchor.constraint(equalTo: painterContentView.topAnchor).isActive = true
        
        painterContentView.addSubview(teacherGroupView)
        teacherGroupView.textAlignment = .right
        teacherGroupView.leftAnchor.constraint(equalTo: lessonTypeView.rightAnchor).isActive = true
        teacherGroupView.topAnchor.constraint(equalTo: painterContentView.topAnchor).isActive = true
        teacherGroupView.rightAnchor.constraint(equalTo: painterContentView.rightAnchor).isActive = true
        
        teacherGroupView.widthAnchor.constraint(equalTo: lessonTypeView.widthAnchor, multiplier: 1.0).isActive = true
        
        painterContentView.addSubview(titleView)
        titleView.leftAnchor.constraint(equalTo: iconView.rightAnchor).isActive = true
        titleView.topAnchor.constraint(equalTo: lessonTypeView.bottomAnchor).isActive = true
        titleView.bottomAnchor.constraint(equalTo: painterContentView.bottomAnchor).isActive = true
        titleView.rightAnchor.constraint(equalTo: painterContentView.rightAnchor).isActive = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let model = model {
            painterView.model = model
            startView.text = model.start.format()
            finishView.text = model.finish.format()
            locationView.text = model.room.formatNumber()
            locationIconView.text = model.room.formatLocation()
            lessonTypeView.text = model.lesson.actionTitle
            switch SearchItemTypeId.fromUserDefaults() {
            case .Group:
                teacherGroupView.text = model.teacher.format()
            case .Teacher:
                teacherGroupView.text = model.group
            }
            
            titleView.text = Prefs.OPTIMIZED_LESSON_TITLES.fromUserDefaults() as? Bool ?? true
                ? model.lesson.title
                : model.lesson.fullTitle
            if titleView.text!.count > 30 {
                titleView.font = titleView.font.withSize(14)
                titleView.textAlignment = .center
            }
            iconView.text = FontIcon.intToStringIcon(UInt32(model.lesson.iconCodePoint))
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
