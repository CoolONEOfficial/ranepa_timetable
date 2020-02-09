//
//  LessonPainter.swift
//  TodayExt
//
//  Created by Nickolay Truhin on 07.02.2020.
//  Copyright © 2020 The Chromium Authors. All rights reserved.
//

import UIKit

class TimelinePainter: UIView {
    var model: TimelineModel?
    
    func drawPath(
        _ ctx: CGContext,
        path: CGPath,
        fillColor: UIColor
    ) {
        ctx.saveGState()
        
        ctx.addPath(path)
        ctx.setFillColor(fillColor.cgColor)

        ctx.closePath()
        ctx.fillPath()
        ctx.restoreGState()
    }
    
    func drawRRect(
        _ ctx: CGContext,
        rect: CGRect,
        cornerRadius: CGFloat,
        fillColor: UIColor
    )
    {
        drawPath(ctx, path: UIBezierPath(
            roundedRect: rect,
            cornerRadius: cornerRadius
        ).cgPath, fillColor: fillColor)
    }
    
    func drawArc(
        _ ctx: CGContext,
        center: CGPoint,
        radius: CGFloat,
        startAngle: CGFloat,
        endAngle: CGFloat,
        fillColor: UIColor,
        clockwise: Bool
    ) {
        drawPath(ctx, path: UIBezierPath(
            arcCenter: center,
            radius: radius,
            startAngle: startAngle.toRadians(),
            endAngle: endAngle.toRadians(),
            clockwise: clockwise
        ).cgPath, fillColor: fillColor)
    }
    
    func drawCircle(
        _ ctx: CGContext,
        center: CGPoint,
        radius: Int,
        fillColor: UIColor
    ) {
        ctx.setFillColor(fillColor.cgColor)
        ctx.fillEllipse(in: CGRect(
            x: center.x - CGFloat(radius),
            y: center.y - CGFloat(radius),
            width: CGFloat(radius * 2),
            height: CGFloat(radius * 2)
        ))
    }
    
    static let rectMargins = 8.0,
        iconSize = 15.0,
        circleRadius = 23.0,
        rectCornersRadius = 10.0,
        circleMargin = 5.0,
        circleRadiusAdd = 3.0;
    
    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext(), let model = model else {
            return
        }
        
        let bgColor = UIColor.init(rgbStr: Prefs.THEME_BACKGROUND.fromUserDefaults() as! String)
        let accentColor = UIColor.init(rgbStr: Prefs.THEME_ACCENT.fromUserDefaults() as! String)
        
        if model.mergeTop {
            ctx.setFillColor(bgColor.withAlphaComponent(0.5).cgColor)
            ctx.fill(CGRect(
                x: TimelinePainter.rectCornersRadius * 2,
                y: 0,
                width: Double(frame.width) - TimelinePainter.rectCornersRadius * 4,
                height: TimelinePainter.rectMargins
            ))
        }
        
        drawRRect(
            ctx,
            rect: CGRect(
                x: TimelinePainter.rectMargins, y: TimelinePainter.rectMargins,
                width: Double(frame.width) - TimelinePainter.rectMargins * 2,
                height: 80.0
            ),
            cornerRadius: 10,
            fillColor: bgColor.withAlphaComponent(
                traitCollection.userInterfaceStyle == .light
                    ? 0.4
                    : 0.2
            )
        )
        
        let circleOffset = CGPoint(
            x: TimelinePainter.rectMargins * 2 + TimelinePainter.circleRadius + 68,
            y: (Double(frame.height) + TimelinePainter.rectMargins) / 2
        )
        
        ctx.setFillColor(accentColor.cgColor)
        if !(model.first && model.last) {
            if model.first || !model.last {
                ctx.fill(CGRect(
                    x: circleOffset.x - CGFloat(TimelinePainter.circleRadius),
                    y: circleOffset.y,
                    width: CGFloat(TimelinePainter.circleRadius * 2),
                    height: frame.height - circleOffset.y
                ))
            }
            
            if model.last || !model.first {
                ctx.fill(CGRect(
                    x: circleOffset.x - CGFloat(TimelinePainter.circleRadius),
                    y: 0,
                    width: CGFloat(TimelinePainter.circleRadius * 2),
                    height: frame.height - circleOffset.y + CGFloat(TimelinePainter.rectMargins)
                ))
            }
            
            if model.first || model.last {
                drawArc(
                    ctx,
                    center: CGPoint(
                        x: circleOffset.x,
                        y: circleOffset.y
                    ),
                    radius: CGFloat(TimelinePainter.circleRadius),
                    startAngle: CGFloat(0),
                    endAngle: CGFloat(180),
                    fillColor: accentColor,
                    clockwise: model.last
                )
            }
        } else {
            drawCircle(
                ctx,
                center: circleOffset,
                radius: Int(TimelinePainter.circleRadius + TimelinePainter.circleRadiusAdd),
                fillColor: accentColor
            )
        }

        ctx.strokePath()
    }
}

extension CGFloat {
  func toRadians() -> CGFloat {
    return self * CGFloat(M_PI) / 180.0
  }
}
