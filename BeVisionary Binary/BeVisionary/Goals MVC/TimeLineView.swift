//
//  TimeLineView.swift
//  BeVisionary
//
//  Created by Ivan Mikhnenkov on 15.04.2018.
//  Copyright © 2018 Ivan Mikhnenkov. All rights reserved.
//

import UIKit

class TimeLineView: UIView {
    var allTimePointsNames = [String]()
    
    var todayDateNeedsTimePointPeriodsToPassToReachEnd: CGFloat = 0.5
    
    var indicatorLabelText = "October 16"
    
    var timePointPeriodPartFromBeginningToClosestTimePointDate: CGFloat! = 0.5 {
        didSet {
            setNeedsDisplay()
            updateTimePointLabels()
            addTodayDateIndicator(with: todayDateNeedsTimePointPeriodsToPassToReachEnd)
        }
    }
    
    // Font size which is being used by all of the time line view subview labels
    private var labelFontSize: CGFloat {
        return bounds.height * 0.23 
    }
    
    // Font which is being used by all of the time line view subview labels
    private var labelFont: UIFont {
        return UIFont.systemFont(ofSize: labelFontSize)
    }
    
    private let indicatorLabelTextColor = UIColor.appRed
    
    private let editionalTimePointsNumber = 6
    
    private let balanceRotation: CGAffineTransform = CGAffineTransform(rotationAngle: CGFloat(5.0.degreesToRadians))
    
    private var timeLineLength: CGFloat {
        return bounds.maxX
    }
    
    private var beginningTimePointDatePositionOnX: CGFloat {
        return timeLineLength * 0.25
    }
    
    private var endTimePointDatePositionOnX: CGFloat {
        return timeLineLength * 0.75
    }
    
    private var timeLineMainPathWidth: CGFloat {
        return bounds.height * 0.1
    }
    
    private var timeLineConstantY: CGFloat {
        return bounds.minY + timeLineMainPathWidth * 0.5
    }
    
    private var timeLineBeginningX: CGFloat {
        return bounds.minX
    }
    
    private func timePointSegmentLength() -> CGFloat {
        return timeLineLength * 0.5 / (CGFloat(actualTimePointsNumber - 1) + timePointPeriodPartFromBeginningToClosestTimePointDate)
    }
    
    private var actualTimePointsNumber: Int {
        return allTimePointsNames.count - editionalTimePointsNumber
    }
    
    
    private let timeLineColor =  UIColor.appNavi
    
    
    private var timePointMarkWidth: CGFloat {
        return timeLineMainPathWidth
    }
    
    private var timePointMarkLength: CGFloat {
        return timeLineMainPathWidth * 1.3
    }
    
    private var todayDateIndicitorSize: CGSize {
        return CGSize(width: timeLineLength * 0.014, height: self.bounds.height * 0.75)
    }
    
    private var todayDateIndicitorXPosition: CGFloat {
        return beginningTimePointDatePositionOnX
    }
    
    
    /// Returns main line of time line view
    private func timeLineMainPath() -> UIBezierPath {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: timeLineBeginningX, y: timeLineConstantY))
        path.addLine(to: CGPoint(x: timeLineBeginningX + timeLineLength, y: timeLineConstantY))
        path.lineWidth = timeLineMainPathWidth
        return path
    }
    
    /// Returns a short time point mark for input position in time line view
    private func timePointMarkPath(positioned x: CGFloat) -> UIBezierPath {
    
        let timePointMarkPath = UIBezierPath()
        let startPoint = CGPoint(x: timeLineBeginningX + x, y: timeLineConstantY)
        let endPoint = CGPoint(x: startPoint.x, y: startPoint.y + timePointMarkLength)

        timePointMarkPath.move(to: startPoint)
        timePointMarkPath.addLine(to: endPoint)
        timePointMarkPath.lineWidth = timePointMarkWidth

        return timePointMarkPath
    }

    /// Returns all short time point marks for time line view based on input conditions
    private func allTimePointMarks() -> [UIBezierPath] {
        var timePointMarks = [UIBezierPath]()
        
        for timePointOrder in 0..<(allTimePointsNames.count - editionalTimePointsNumber / 2) {
            let timePointMark = timePointMarkPath(positioned: endTimePointDatePositionOnX - timePointSegmentLength() * CGFloat(timePointOrder))
            timePointMarks.append(timePointMark)
        }
        
        for timePointOrder in (allTimePointsNames.count - editionalTimePointsNumber / 2)..<allTimePointsNames.count {
            let timePointMark = timePointMarkPath(positioned: endTimePointDatePositionOnX + timePointSegmentLength() * CGFloat(timePointOrder + 1 - (allTimePointsNames.count - editionalTimePointsNumber / 2)))
            timePointMarks.append(timePointMark)
        }
        
        return timePointMarks
    }
    
    /// Update time point labels to be actual
    private func updateTimePointLabels() {
        // Delete all labels that are subsviews of this instance of TimeLineView except today date indicator
        for subview in self.subviews {
            if subview is UILabel {
                if (subview as! UILabel).textColor != indicatorLabelTextColor {
                    subview.removeFromSuperview()
                }
            }
        }
        
        let labelWidth = timePointSegmentLength() * 0.95
        let labelHeight = labelFontSize * 1.5
        
        for timePointOrder in 0..<(allTimePointsNames.count - editionalTimePointsNumber / 2) {
            
            let timePointLabel = UILabel(frame: CGRect(x: endTimePointDatePositionOnX - timePointSegmentLength() * CGFloat(timePointOrder) - labelWidth / 2,
                                                       y: timeLineConstantY + timePointMarkLength,
                                                       width: labelWidth,
                                                       height: labelHeight))
            timePointLabel.adjustsFontSizeToFitWidth = true
            timePointLabel.text = allTimePointsNames[(allTimePointsNames.count - 1 - editionalTimePointsNumber / 2) - timePointOrder]
            timePointLabel.textAlignment = .center
            timePointLabel.font = labelFont
            self.addSubview(timePointLabel)
        }
        
        
        for timePointOrder in (allTimePointsNames.count - editionalTimePointsNumber / 2)..<allTimePointsNames.count {
            let timePointLabel = UILabel(frame: CGRect(x: endTimePointDatePositionOnX + timePointSegmentLength() * CGFloat(timePointOrder + 1 - (allTimePointsNames.count - editionalTimePointsNumber / 2)) - labelWidth / 2,
                                                       y: timeLineConstantY + timePointMarkLength,
                                                       width: labelWidth,
                                                       height: labelHeight))
            timePointLabel.adjustsFontSizeToFitWidth = true
            timePointLabel.text = allTimePointsNames[timePointOrder]
            timePointLabel.textAlignment = .center
            timePointLabel.font = labelFont
            self.addSubview(timePointLabel)
        }
    }
    
    
    /// Adds today date indicator as a subview to time line view: both an arrow and date label below an arrow
    private func addTodayDateIndicator(with x: CGFloat) {
        for subview in self.subviews {
            if subview is UIImageView {
                subview.removeFromSuperview()
            } else if subview is UILabel {
                if (subview as! UILabel).textColor == indicatorLabelTextColor {
                    subview.removeFromSuperview()
                }
            }
        }
        
        
        let todayDateIndicatorImageView = UIImageView(frame: CGRect(x: endTimePointDatePositionOnX - x * timePointSegmentLength() - todayDateIndicitorSize.width * 0.6,
                                                                    y: timeLineConstantY,
                                                                    width: todayDateIndicitorSize.width,
                                                                    height: todayDateIndicitorSize.height))
        todayDateIndicatorImageView.image = #imageLiteral(resourceName: "Today Date Indicator")
        todayDateIndicatorImageView.transform = balanceRotation
        self.addSubview(todayDateIndicatorImageView)
        
        let labelHeight = labelFontSize * 1.5
        
        let indicatorLabelFrame = CGRect(x: todayDateIndicatorImageView.frame.minX - todayDateIndicatorImageView.bounds.width * 4.5,
                                         y: todayDateIndicatorImageView.frame.maxY,
                                         width: todayDateIndicatorImageView.bounds.width * 10,
                                         height: labelHeight)
        
        let indicatorLabel = UILabel(frame: indicatorLabelFrame)
        indicatorLabel.adjustsFontSizeToFitWidth = true
        indicatorLabel.text = indicatorLabelText
        indicatorLabel.textColor = indicatorLabelTextColor
        indicatorLabel.textAlignment = .center
        indicatorLabel.font = labelFont
        indicatorLabel.transform = balanceRotation
        self.addSubview(indicatorLabel)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        timeLineColor.set()
        timeLineMainPath().stroke()
        for timePointMark in allTimePointMarks() {
            timePointMark.stroke()
        }
        
    }
}
