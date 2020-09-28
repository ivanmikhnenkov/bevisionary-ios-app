//
//  GoalNameAndColorSettingViewController.swift
//  BeVisionary
//
//  Created by Ivan Mikhnenkov on 15.04.2018.
//  Copyright © 2018 Ivan Mikhnenkov. All rights reserved.
//

import UIKit
import Foundation

class GoalNameAndColorSettingViewController: UIViewController, UITextFieldDelegate {

    // If nil - new goal is being created
    var identifierOfGoalBeingUpdated: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNameAndColorIfUpdating()
        
        self.view.isOpaque = false
        self.view.backgroundColor = AppearenceSettings.notContentViewBackgroundColor
        
        configureContentView()
        
        addColorButton()
        configureSetButton()
        addCancelButton()

        configureTextField()
    }
    
    
    private var goalName: String?
    private var goalColor: UIColor?
    
    // In the case when goal identifier is transmitted by parent VC, which means existing goal is being updated, instead of new one being created, - sets name and color which would be displayed by text field and color button accordingly
    private func setNameAndColorIfUpdating() {
        if identifierOfGoalBeingUpdated != nil {
            if let goalBeingUpdated = Goal.uploadGoalWith(identifier: identifierOfGoalBeingUpdated!, in: context) {
                goalName = goalBeingUpdated.name!
                goalColor = UIColor(hex: goalBeingUpdated.colorAsHex!)
            }
        }
    }
    
    // - MARK: Content view
    
    private var contentViewFrame: CGRect {
        let rootViewFrame = self.view.frame
        return CGRect(x: rootViewFrame.width * ((1 - LayoutSettings.contentViewWidthModally) / 2),
                      y: rootViewFrame.height * ((1 - LayoutSettings.contentViewHeightModally) / 2),
                      width: rootViewFrame.width * LayoutSettings.contentViewWidthModally,
                      height: rootViewFrame.height * LayoutSettings.contentViewHeightModally)
    }
    
    private var contentView: UIView!
    
    private func configureContentView() {
        contentView = UIView(frame: contentViewFrame)
        contentView.backgroundColor = AppearenceSettings.contentViewBackgroundColor
        contentView.layer.cornerRadius = contentViewFrame.width * LayoutSettings.cornerRadiusToContentViewWidth
        contentView.layer.masksToBounds = true
        self.view.addSubview(contentView)
    }
    
    // MARK: - Goal name and color input
    
    private var goalNameTextField: UITextField!
    
    private func configureTextField() {
        goalNameTextField = UITextField(frame: CGRect(x: 0, y: 0, width: contentView.bounds.width, height: contentView.bounds.height * LayoutSettings.textFieldHeightPart))
        goalNameTextField.font = UIFont.systemFont(ofSize: goalNameTextField.bounds.height * 0.3)
        goalNameTextField.placeholder = TextUsedInInterface.goalNameTextfieldPlaceholder
        goalNameTextField.autocorrectionType = .no
        goalNameTextField.textAlignment = .center
        goalNameTextField.borderStyle = .none
        goalNameTextField.adjustsFontSizeToFitWidth = true
        goalNameTextField.delegate = self
        
        contentView.addSubview(goalNameTextField)
        
        if goalName != nil {
            goalNameTextField.text = goalName!
            setButton.isEnabled = true
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        setButton.isEnabled = false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        goalName = textField.text
        if goalName != nil {
            if goalName!.containsMeaningfulText() && Goal.isGoalNameFree(goalName!, beingCheckedGoalidentifier: identifierOfGoalBeingUpdated, in: context) && goalName! != String.defaultThemeName {
                setButton.isEnabled = true
            }
        }
    }
    
    // Sets limit of max goal name length
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 50
        let currentString: NSString = textField.text! as NSString
        let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
    }
    
    /// Adds configured color button
    private func addColorButton() {
        let changeGoalColorButton = UIButton(frame: CGRect(x: 0,
                                                     y: contentView.bounds.maxY * 0.2,
                                                     width: contentView.bounds.maxX,
                                                     height: contentView.bounds.height * LayoutSettings.goalColorButtonHeightPart))
        if goalColor != nil {
            changeGoalColorButton.backgroundColor = goalColor!
        } else {
            changeGoalColorButton.backgroundColor = UIColor.generateThemeColor()
            goalColor = changeGoalColorButton.backgroundColor
        }
        
        changeGoalColorButton.setTitle(TextUsedInInterface.changeGoalColorButtonTitle, for: .normal)
        changeGoalColorButton.titleLabel?.tintColor = .white
        changeGoalColorButton.titleLabel?.textAlignment = .center
        changeGoalColorButton.titleLabel?.font = UIFont.systemFont(ofSize: changeGoalColorButton.bounds.height * 0.1)
        
        changeGoalColorButton.addTarget(self, action: #selector(goalColorButtonIsPressed(sender:)), for: .touchUpInside)
        changeGoalColorButton.titleLabel?.adjustsFontSizeToFitWidth = true
        contentView.addSubview(changeGoalColorButton)
    }
    
    // What happens when user taps goal color button
    @objc private func goalColorButtonIsPressed(sender: UIButton) {
        sender.backgroundColor = UIColor.generateThemeColor()
        goalColor = sender.backgroundColor
    }
    
    // MARK: - Action buttons
    
    /// Adds cancel button to a first poistion
    private func addCancelButton() {
        let cancelButton =  UIButton(frame: CGRect(x: 0,
                                                   y: contentView.bounds.maxY * (1 - LayoutSettings.actionButtonsHeightPart),
                                                   width: contentView.bounds.maxX * LayoutSettings.actionButtonsWidthPart,
                                                   height: contentView.bounds.maxY * LayoutSettings.actionButtonsHeightPart))
        cancelButton.setTitle(TextUsedInInterface.cancelButtonTitle, for: .normal)
        cancelButton.setTitleColor(AppearenceSettings.actionButtonEnabledFontColor, for: .normal)
        cancelButton.titleLabel?.font = .systemFont(ofSize: cancelButton.bounds.height * LayoutSettings.actionButtonFontSizeToHeight)
        
        cancelButton.addTarget(self, action: #selector(cancelButtonIsPressed), for: .touchUpInside)
        cancelButton.titleLabel?.adjustsFontSizeToFitWidth = true
        contentView.addSubview(cancelButton)
    }
    
    /// Dismisses view which is being shown by current controller
    @objc private func cancelButtonIsPressed() {
        dismiss(animated: true, completion: nil)
    }
    
    /// Variable is implemented in comparison to cancel button because it's needed to be disabled and enabled depending on text field text
    private var setButton: UIButton!
    
    /// Configures set button to be on a second position
    private func configureSetButton() {
        setButton = UIButton(frame: CGRect(x: contentView.bounds.maxX * LayoutSettings.actionButtonsWidthPart,
                                          y: contentView.bounds.maxY * (1 - LayoutSettings.actionButtonsHeightPart),
                                          width: contentView.bounds.maxX * LayoutSettings.actionButtonsWidthPart,
                                          height: contentView.bounds.maxY * LayoutSettings.actionButtonsHeightPart))
        
        if identifierOfGoalBeingUpdated == nil {
            setButton.setTitle(TextUsedInInterface.setButtonTitleGoalCreationCase, for: .normal)
        } else {
            setButton.setTitle(TextUsedInInterface.setButtonTitleGoalEditingCase, for: .normal)
        }
        setButton.setTitleColor(AppearenceSettings.actionButtonEnabledFontColor, for: .normal)
        setButton.setTitleColor(AppearenceSettings.actionButtonDisabledFontColor, for: .disabled)
        setButton.titleLabel?.font = .systemFont(ofSize: setButton.bounds.height * LayoutSettings.actionButtonFontSizeToHeight)
        setButton.isEnabled = false
        setButton.addTarget(self, action: #selector(setButtonIsPressed), for: .touchUpInside)
        setButton.titleLabel?.adjustsFontSizeToFitWidth = true
        contentView.addSubview(setButton)
    }
    
    @objc private func setButtonIsPressed() {
        if let goalsVC = (self.presentingViewController as! CustomTabBarController).viewControllers![0] as? GoalsViewController {
            if identifierOfGoalBeingUpdated == nil {
                if let newGoal = Goal.createNewGoal(name: goalName!,
                                                    color: goalColor!,
                                                    from: TimeLineModel.defaultTimeLineBeginningDate(),
                                                    to: TimeLineModel.defaultTimeLineEndDate(),
                                                    number: Goal.newGoalNumber(in: context),
                                                    identifier: Date().description,
                                                    in: context) {
                    goalsVC.currentlyDisplayedGoal = newGoal
                    goalsVC.activateGoalEndDateEditingMode()
                }
            } else {
                let goalBeingUpdated = Goal.uploadGoalWith(identifier: identifierOfGoalBeingUpdated!, in: context)
                _ = goalBeingUpdated?.updateGoalNameAndColor(newName: goalName!, newColor: goalColor!, in: context)
                goalsVC.currentlyDisplayedGoal = goalBeingUpdated
            }
            dismiss(animated: true, completion: nil)
        }
    }

    
    // MARK: - Interface settings
    
    private struct LayoutSettings {
        static let contentViewWidthModally: CGFloat = 0.6
        static let contentViewHeightModally: CGFloat = 0.6
        
        static let cornerRadiusToContentViewWidth: CGFloat = 0.05
        
        static let textFieldHeightPart: CGFloat = 0.2
        static let goalColorButtonHeightPart: CGFloat = 0.6
        static let actionButtonsHeightPart: CGFloat = 0.2
        static let actionButtonsWidthPart: CGFloat = 0.5
        static let actionButtonFontSizeToHeight: CGFloat = 0.25
    }
    
    private struct AppearenceSettings {
        static let notContentViewBackgroundColor: UIColor = UIColor.nonContentPopoverBackgroundColor
        static let contentViewBackgroundColor: UIColor = UIColor.systemBackgroundColor
        static let goalColorButtonTitleColor: UIColor = .white
        static let actionButtonEnabledFontColor: UIColor = UIColor.systemEnabledTitleColor
        static let actionButtonDisabledFontColor: UIColor = UIColor.systemDisabledTitleColor
    }
    
    private struct TextUsedInInterface {
        static let goalNameTextfieldPlaceholder = LocalizedString("GoalNameAndColorSettingVC; goalNameTextfieldPlaceholder")
        static let changeGoalColorButtonTitle = LocalizedString("GoalNameAndColorSettingVC; changeGoalColorButtonTitle")
        static let cancelButtonTitle = LocalizedString("GoalNameAndColorSettingVC; cancelButtonTitle")
        static let setButtonTitleGoalCreationCase = LocalizedString("GoalNameAndColorSettingVC; setButtonTitleGoalCreationCase")
        static let setButtonTitleGoalEditingCase = LocalizedString("GoalNameAndColorSettingVC; setButtonTitleGoalEditingCase")
        
    }
}


