//
//  LessonPainter.swift
//  TodayExt
//
//  Created by Nickolay Truhin on 07.02.2020.
//  Copyright © 2020 The Chromium Authors. All rights reserved.
//

import UIKit

class LessonPainter: UIView {
    var lesson: String?
    
    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else {
            return
        }
        
        ctx.move(to: CGPoint(x: 0, y: 0))
        ctx.addLine(to: CGPoint(x: 100, y: 100))
        
        ctx.addRect(CGRect(x: 10, y: 10, width: 10, height: 10))
        
        ctx.strokePath()
    }
}
