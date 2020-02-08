//
//  LessonPainter.swift
//  TodayExt
//
//  Created by Nickolay Truhin on 07.02.2020.
//  Copyright © 2020 The Chromium Authors. All rights reserved.
//

import UIKit

class TimelinePainter: UIView {
    var lesson: String?
    
    func drawRRect(
        _ ctx: CGContext,
        rect: CGRect,
        cornerRadius: CGFloat,
        fillColor: UIColor
    )
    {
        ctx.saveGState()

        let clipPath: CGPath = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius).cgPath

        ctx.addPath(clipPath)
        ctx.setFillColor(fillColor.cgColor)

        ctx.closePath()
        ctx.fillPath()
        ctx.restoreGState()
    }
    
    static let rectMargins = 8.0,
        iconSize = 15.0,
        circleRadius = 23.0,
        rectCornersRadius = 10.0,
        circleMargin = 5.0,
        circleRadiusAdd = 3;
    
    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else {
            return
        }
        
        let bgColor = UIColor.init(rgbStr: Prefs.THEME_BACKGROUND.fromUserDefaults() as! String)
        
        drawRRect(
            ctx,
            rect: CGRect(
                x: TimelinePainter.rectMargins, y: TimelinePainter.rectMargins,
                width: Double(frame.width) - TimelinePainter.rectMargins * 2,
                height: 80.0
            ),
            cornerRadius: 10,
            fillColor: traitCollection.userInterfaceStyle == .light
                ? bgColor
                : bgColor.withAlphaComponent(0.2)
        )
        
        ctx.strokePath()
    }
}
