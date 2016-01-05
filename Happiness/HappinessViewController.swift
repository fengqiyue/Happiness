//
//  HappinessViewController.swift
//  Happiness
//
//  Created by 张旭 on 15/12/24.
//  Copyright © 2015年 cheri. All rights reserved.
//

import UIKit



class HappinessViewController: UIViewController, FaceViewDataSource {
      
    @IBOutlet weak var faceView: FaceView! {
        didSet{
            faceView.dataSource = self
            faceView.addGestureRecognizer(UIPinchGestureRecognizer(target: faceView, action: "scale:"))
            faceView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: "changeHappiness:"))
        }
    }
    
    var happiness:Int = 50 { // 0 = very sad, 100 = very happy
        didSet{
            happiness = min(max(happiness,0), 100)
            updateUI()
        }
    }
    
    private struct Constants {
        static let HappinessGestureScale:CGFloat = 4
    }
    
    @IBAction func changeHappiness(gesture: UIPanGestureRecognizer) {
        switch gesture.state{
        case .Ended:fallthrough
        case .Changed:
            let translation = gesture.translationInView(faceView)
            let happinessChange = -Int(translation.y / Constants.HappinessGestureScale)
            if happinessChange != 0 {
                happiness += happinessChange
                gesture.setTranslation(CGPointZero, inView: faceView)  //重置以保证是增量变化
            }
        default:break
        }
    }
    
    @IBAction func valueChanged(sender: UISlider) {   //一个拖拽条控制微笑的弧度
        self.happiness = Int(sender.value)
    }
    
    private func updateUI() {
        faceView.setNeedsDisplay()
    }
    
    func smilinessForFaceView(sender: FaceView) -> Double? {
        return Double(happiness-50)/50.0
    }
    
    

}
