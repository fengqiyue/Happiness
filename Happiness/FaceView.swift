//
//  FaceView.swift
//  Happiness
//
//  Created by 张旭 on 15/12/24.
//  Copyright © 2015年 cheri. All rights reserved.
//

import UIKit

protocol FaceViewDataSource:class {   //作为数据源的代理
    func smilinessForFaceView(sender:FaceView) -> Double?
}

@IBDesignable 
class FaceView: UIView {
    @IBInspectable
    var linewidth:CGFloat = 3 {didSet {setNeedsDisplay()}} //线宽被改变时，重新绘制
    @IBInspectable 
    var scale:CGFloat = 0.90
    @IBInspectable
    var color:UIColor = UIColor.blueColor() {didSet {setNeedsDisplay()}}
    
    var faceCenter:CGPoint {
        return convertPoint(center, fromView: superview)
    }
    var faceRadius:CGFloat {
        return min(bounds.size.width, bounds.size.height) / 2 * scale
    }
    
    weak var dataSource:FaceViewDataSource?  //dataSource 指向的任何对象都不会被一直存在内存里
    
    func scale(gesture:UIPinchGestureRecognizer) {       //缩放手势
        if gesture.state == .Changed {
            scale *= gesture.scale
            gesture.scale = 1
            self.setNeedsDisplay()
        }
    }

    override func drawRect(rect: CGRect) {
        let facePath = UIBezierPath(arcCenter: faceCenter, radius: faceRadius, startAngle: 0, endAngle: CGFloat(2 * M_PI), clockwise: true)
        facePath.lineWidth = linewidth
        color.set()
        facePath.stroke()
        
        bezierPathForEye(.Left).stroke()
        bezierPathForEye(.Right).stroke()
        
        print("dataSource?.smilinessForFaceView(self) = \(dataSource?.smilinessForFaceView(self))")
        
        let smiliness = dataSource?.smilinessForFaceView(self) ?? 0.0 //若左边为 nil， 则用右边的值
        
        let smilePath = bezierPathForSmile(smiliness)
        smilePath.stroke()
    }
    
    private struct Scaling {
        static let FaceRadiusToEyeRadiusRatio: CGFloat = 10
        static let FaceRadiusToEyeOffsetRatio: CGFloat = 3
        static let FaceRadiusToEyeSeparationRatio: CGFloat = 1.5
        static let FaceRadiusToMounthWidthRatio: CGFloat = 1
        static let FaceRadiusToMounthHeightRatio: CGFloat = 3
        static let FaceRadiusToMounthOffsetRatio: CGFloat = 3
    }
    
    private enum Eye { case Left, Right }
    
    private func bezierPathForEye(whichEye:Eye) -> UIBezierPath
    {
        let eyeRadius = faceRadius / Scaling.FaceRadiusToEyeRadiusRatio
        let eyeVerticalOffset = faceRadius / Scaling.FaceRadiusToEyeOffsetRatio
        let eyeHorizontalSeparation = faceRadius / Scaling.FaceRadiusToEyeSeparationRatio
        
        var eyeCenter = faceCenter
        eyeCenter.y -= eyeVerticalOffset
        switch whichEye {
        case .Left: eyeCenter.x -= eyeHorizontalSeparation / 2
        case .Right: eyeCenter.x += eyeHorizontalSeparation / 2
        }

        
        let path = UIBezierPath(arcCenter: eyeCenter, radius: eyeRadius, startAngle: 0, endAngle: CGFloat(2*M_PI), clockwise: true)
        path.lineWidth = linewidth
        return path
    }
    
    private func bezierPathForSmile(fractionOfMaxSmile:Double) -> UIBezierPath {
        
        let mouthWidth = faceRadius / Scaling.FaceRadiusToMounthWidthRatio
        let mouthHeight = faceRadius / Scaling.FaceRadiusToMounthHeightRatio
        let mouthVerticalOffset = faceRadius / Scaling.FaceRadiusToMounthOffsetRatio
        
        let smileHeight = CGFloat(max(min(fractionOfMaxSmile, 1), -1)) * mouthHeight

        
        let start = CGPoint(x:faceCenter.x - mouthWidth / 2, y:faceCenter.y + mouthVerticalOffset)
        let end = CGPoint(x: start.x + mouthWidth, y: start.y)
        let cp1 = CGPoint(x: start.x + mouthWidth / 3, y: start.y + smileHeight)
        let cp2 = CGPoint(x: end.x - mouthWidth / 3, y: cp1.y)

        
        let path = UIBezierPath()
        path.moveToPoint(start)
        path.addCurveToPoint(end, controlPoint1: cp1, controlPoint2: cp2)
        return path
    }
}
