//
//  GoalEditingOptionsViewController.swift
//  BeVisionary
//
//  Created by Ivan Mikhnenkov on 15.04.2018.
//  Copyright © 2018 Ivan Mikhnenkov. All rights reserved.
//

import UIKit

class GoalEditingOptionsViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.isOpaque = false
        self.view.backgroundColor = AppearenceSettings.notContentViewBackgroundColor
        
        configureContentView()
        addHeaderLabel()
        addNameAndColorEditingButton()
        addTimePeriodEditingButton()
        addCancelButton()
    }
    
    // - MARK: Content view
    
    private var contentView: UIView!
    
    private var contentViewFrame: CGRect {
        let rootViewBounds = self.view.bounds
        return CGRect(x: rootViewBounds.width * ((1 - LayoutSettings.contentViewWidthModally) / 2),
                      y: rootViewBounds.height * ((1 - LayoutSettings.contentViewHeightModally) / 2),
                      width: rootViewBounds.width * LayoutSettings.contentViewWidthModally,
                      height: rootViewBounds.height * LayoutSettings.contentViewHeightModally)
    }
    
    private func configureContentView() {
        contentView = UIView(frame: contentViewFrame)
        contentView.backgroundColor = AppearenceSettings.contentViewBackgroundColor
        contentView.layer.cornerRadius = contentViewFrame.width * LayoutSettings.cornerRadiusToContentViewWidth
        contentView.layer.masksToBounds = true
        self.view.addSubview(contentView)
    }
    
    
    
    private func addHeaderLabel() {
        let headerLabel = UILabel(frame: CGRect(x: 0, y: 0, width: contentView.bounds.width, height: contentView.bounds.height * LayoutSettings.actionButtonsHeightPart))
        headerLabel.backgroundColor = AppearenceSettings.contentViewBackgroundColor
        headerLabel.text = TextUsedInInterface.headerLabelText
        headerLabel.textColor = AppearenceSettings.actionButtonEnabledFontColor
        headerLabel.textAlignment = .center
        headerLabel.font = UIFont.systemFont(ofSize: headerLabel.bounds.height * LayoutSettings.headerFontSizeToHeight,
                                             weight: UIFont.Weight(rawValue: 0.5))
        headerLabel.adjustsFontSizeToFitWidth = true
        contentView.addSubview(headerLabel)
    }
    
    private func addNameAndColorEditingButton() {
        let nameAndColorEditingButton = editingOptionButtonWith(name: TextUsedInInterface.nameAndColorEditingButtonTitle, order: 1)
        nameAndColorEditingButton.addTarget(self, action: #selector(nameAndColorButtonWasPressed), for: .touchUpInside)
        nameAndColorEditingButton.titleLabel?.adjustsFontSizeToFitWidth = true
        contentView.addSubview(nameAndColorEditingButton)
    }
    
    private func addTimePeriodEditingButton() {
        let timePeriodEditingButton = editingOptionButtonWith(name: TextUsedInInterface.timePeriodEditingButtonTitle, order: 2)
        timePeriodEditingButton.addTarget(self, action: #selector(timePeriodButtonWasPressed), for: .touchUpInside)
        timePeriodEditingButton.titleLabel?.adjustsFontSizeToFitWidth = true
        contentView.addSubview(timePeriodEditingButton)
    }
    
    private func addCancelButton() {
        let cancelButton = editingOptionButtonWith(name: TextUsedInInterface.cancelButtonTitle, order: 3)
        cancelButton.addTarget(self, action: #selector(cancelButtonWasPressed), for: .touchUpInside)
        cancelButton.titleLabel?.adjustsFontSizeToFitWidth = true
        contentView.addSubview(cancelButton)
    }
    
    @objc private func nameAndColorButtonWasPressed() {
        if let goalsVC = (self.presentingViewController as! CustomTabBarController).viewControllers![0] as? GoalsViewController {
            dismiss(animated: true, completion: {
                if let updatedGoalIdentifier = goalsVC.currentlyDisplayedGoal?.identifier {
                    goalsVC.presentGoalNameAndColorSettingVC(goalIdentiferIfUpdating: updatedGoalIdentifier)
                }
            })
        }
    }
    
    @objc private func timePeriodButtonWasPressed() {
        if let goalsVC = (self.presentingViewController as! CustomTabBarController).viewControllers![0] as? GoalsViewController {
            dismiss(animated: true, completion: {
                goalsVC.activateGoalEndDateEditingMode()
            })
        }
    }
    
    @objc private func cancelButtonWasPressed() {
        dismiss(animated: true, completion: nil)
    }
    
    /// Pattern merhod that returns editing button for current view controller
    /// - Parameters:
    ///   - name: Text for title
    ///   - order: Order of button (from 1 to 3 in current interface)
    /// - Returns: Button that needs to be added with target
    private func editingOptionButtonWith(name: String, order: Int) -> UIButton {
        let button = UIButton(frame: CGRect(x: contentView.bounds.minX,
                                            y: contentView.bounds.height * LayoutSettings.actionButtonsHeightPart * CGFloat(order),
                                            width: contentView.bounds.width,
                                            height: contentView.bounds.height * LayoutSettings.actionButtonsHeightPart))
        button.setTitle(name, for: .normal)
        button.setTitleColor(AppearenceSettings.actionButtonEnabledFontColor, for: .normal)
        
        if order % 2 == 1 {
            button.layer.borderWidth = AppearenceSettings.borderWidth
            button.layer.borderColor = AppearenceSettings.borderColor
        }
        button.titleLabel?.font = UIFont.systemFont(ofSize: button.bounds.height * LayoutSettings.actionButtonFontSizeToHeight)
        return button
    }
    
    private struct LayoutSettings {
        static let contentViewWidthModally: CGFloat = 0.4
        static let contentViewHeightModally: CGFloat = 0.4
        static let cornerRadiusToContentViewWidth: CGFloat = 0.05
        
        static let actionButtonsHeightPart: CGFloat = 0.25
        static let actionButtonsWidthPart: CGFloat = 1
        static let actionButtonFontSizeToHeight: CGFloat = 0.25
        static let headerFontSizeToHeight: CGFloat = 0.3
    }
    
    private struct AppearenceSettings {
        static let notContentViewBackgroundColor = UIColor.nonContentPopoverBackgroundColor
        static let contentViewBackgroundColor = UIColor.systemBackgroundColor
        
        static let actionButtonEnabledFontColor = UIColor.systemEnabledTitleColor
        
        static let borderWidth: CGFloat = CGFloat.adaptiveThinBorderSize()
        static let borderColor = UIColor.systemEnabledTitleColor.cgColor
    }
    
    private struct TextUsedInInterface {
        static let headerLabelText = LocalizedString("GoalEditingOptionsVC; headerLabelText")
        static let nameAndColorEditingButtonTitle = LocalizedString("GoalEditingOptionsVC; nameAndColorEditingButtonTitle")
        static let timePeriodEditingButtonTitle = LocalizedString("GoalEditingOptionsVC; timePeriodEditingButtonTitle")
        static let cancelButtonTitle = LocalizedString("GoalEditingOptionsVC; cancelButtonTitle")
    }
}

