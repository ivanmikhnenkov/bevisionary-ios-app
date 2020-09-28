//
//  GoalView.swift
//  BeVisionary
//
//  Created by Ivan Mikhnenkov on 15.04.2018.
//  Copyright © 2018 Ivan Mikhnenkov. All rights reserved.
//

import UIKit

class GoalView: UIView {
    
    var color: UIColor? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var name: String? {
        didSet {
            addGoalNameLabel()
        }
    }
    
    private func goalViewPath() -> UIBezierPath {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: bounds.minX, y: bounds.minY))
        path.addLine(to: CGPoint(x: bounds.minX, y: bounds.height))
        path.addLine(to: CGPoint(x: bounds.maxX, y: bounds.height))
        path.addLine(to: CGPoint(x: bounds.maxX, y: bounds.minY))
        path.addLine(to: CGPoint(x: bounds.minX, y: bounds.minY))
        return path
    }
    
    private func addGoalNameLabel() {
        let goalNameLabel = UILabel()
        goalNameLabel.frame = CGRect(x: frame.width * 0.1,
                                     y: frame.height * 0.15,
                                     width: frame.width * 0.8,
                                     height: frame.maxY * 0.55)
        goalNameLabel.textColor = .white
        goalNameLabel.font = UIFont.appFontOfSize(bounds.maxY / 15)
        goalNameLabel.textAlignment = .center
        goalNameLabel.numberOfLines = 0
        goalNameLabel.text = name!
        self.addSubview(goalNameLabel)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        color?.set()
        goalViewPath().fill()
    }
    
    override init(frame:CGRect) {
        super.init(frame:frame)
        self.isOpaque = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
