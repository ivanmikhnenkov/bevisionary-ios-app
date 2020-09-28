//
//  ImpressionsViewController.swift
//  BeVisionary
//
//  Created by Ivan Mikhnenkov on 15.04.2018.
//  Copyright © 2018 Ivan Mikhnenkov. All rights reserved.
//

import UIKit
import StoreKit

class ImpressionsViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Deletes goals which time periods are not actual anymore
        Goal.deleteGoalsWithEndedTimePeriods()
        
        /// Set notification center to notifies when keyboard appears and disappears
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustTextViewForKeyboard), name: Notification.Name.UIKeyboardWillHide, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustTextViewForKeyboard), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Sets the reference to this view controller in order to update avaialable themes immideately when user subscribes
        impressionsVC = self
        updateInterfaceAccordingToCurrentImpressionsStorage()
    }
    
    
    func updateInterfaceAccordingToCurrentImpressionsStorage() {
        // Impressions MVC data base updating in order to provide as responsive and smart app behavior as possible
        ImpressionsDataModel.defaultImpressionsStorageUpdating()
        
        // Set current content view frame to be frame of impressionsView which is Interface Builder Outlet without any initially correct layout parameters
        contentView.frame = CGRect.contentViewFrameOf(viewController: self)
        
        // Set appropriate adaptable frames and text parameters to main text view which is Interface Builder Outlet without any initially correct layout and text parameters
        configureMainTextView()
        
        updateCurrentThemeButtons()
        contentView.themeButtons = currentThemeButtons
        contentView.layoutIfNeeded()
    }
    
    // MARK: - User Interface Building
    
    @IBOutlet weak var contentView: ImpressionsView!
    
    // MARK: Main text view configuring
    
    @IBOutlet weak var mainTextView: UITextView!
    
    private func configureMainTextView() {
        // Make text view to fit every device screen and leave space for theme buttons
        mainTextView.frame = mainTextViewFrameIn(superviewBounds: contentView.bounds)
        mainTextView.text = currentRecords[currentTheme]
        // Sets font of adaptable size - system font size OR bigger if textview width is quite large
        mainTextView.font = UIFont.systemFont(ofSize: max(mainTextView.bounds.width / 32, UIFont.systemFontSize))
        mainTextView.textAlignment = .natural
    }
    
    /// Used in ImpressionsViewController to set adaptable frame to mainTextView
    private func mainTextViewFrameIn(superviewBounds bounds: CGRect) -> CGRect {
        let indent = bounds.width / 100
        return CGRect(x: bounds.width / 5 + indent,
                      y: bounds.minY,
                      width: bounds.width * 3 / 5 - indent * 2, height: bounds.height)
    }
    
    /// Adjusts main text view to be not overlapped by keyboard
    @objc func adjustTextViewForKeyboard(respondigTo notification: Notification) {
        let userInfo = notification.userInfo!
        
        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == Notification.Name.UIKeyboardWillHide {
            mainTextView.contentInset = UIEdgeInsets.zero
        } else {
            mainTextView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height, right: 0)
        }
        
        mainTextView.scrollIndicatorInsets = mainTextView.contentInset
        
        let selectedRange = mainTextView.selectedRange
        mainTextView.scrollRangeToVisible(selectedRange)
    }
    
    // MARK: Theme buttons building
    
    private var currentThemeButtons = [UIButton]()
    
    // Create theme buttons based on current theme button info which processed core data goals info and add theme to currentThemeButtons property
    private func updateCurrentThemeButtons() {
        
        let buttonsInfo = ImpressionsDataModel.getButtonsBuildingInfoSortedByNumber()
        
        // Return 'true' if button with certain number shuld be on the left side OR 'false' if on the right side
        func isLeftSideButton(numbered number: Int) -> Bool {
            if number % 2 == 0 {
                return true
            } else {
                return false
            }
        }
        
        let leftButtonsNumber = (buttonsInfo.count % 2 == 0) ? (buttonsInfo.count / 2) : ((buttonsInfo.count / 2) + 1)
        let rightButtonsNumber = buttonsInfo.count - leftButtonsNumber
        
        let leftButtonHeight = contentView.bounds.height / CGFloat(leftButtonsNumber)
        let rightButtonHeight = contentView.bounds.height / CGFloat(rightButtonsNumber)
        
        
        // Full theme button configuring
        func configureThemeButton(_ themeButton: UIButton, with buttonInfo: ImpressionsDataModel.ButtonBuildingInfo, buttonsNumber: Int) {
            if isLeftSideButton(numbered: buttonInfo.number) {
                // Set button frame for left button
                themeButton.frame = CGRect(x: 0,
                                           y: contentView.bounds.minY + leftButtonHeight * CGFloat((buttonInfo.number / 2)),
                                           width: contentView.bounds.width / 5,
                                           height: leftButtonHeight)
            } else {
                // Set button frame for right button
                themeButton.frame = CGRect(x: contentView.bounds.width * 4 / 5,
                                           y: contentView.bounds.minY + rightButtonHeight * CGFloat((buttonInfo.number / 2)),
                                           width: contentView.bounds.width / 5,
                                           height: rightButtonHeight)
            }
            
            themeButton.backgroundColor = buttonInfo.color
            themeButton.setTitle(buttonInfo.name, for: .normal)
            themeButton.configureThemeButtonTitleLabel(buttonsNumber: buttonsNumber)
            
            if themeButton.currentTitle == currentTheme {
                // Set button to be chosen according to the current theme when Impressions interface appears
                currentlySelectedThemeButton = themeButton
                themeButton.setSelectedBackgroundColor()
            } else {
                // Unchosen button visual view
                themeButton.setUnselectedButtonBackgroundColor()
            }

            themeButton.titleLabel?.numberOfLines = 6
            themeButton.addTarget(self, action: #selector(themeButtonIsTapped(sender:)), for: .touchUpInside)
        }
        
        currentThemeButtons.removeAll()
        
        for buttonInfo in ImpressionsDataModel.getButtonsBuildingInfoSortedByNumber() {
            let themeButton = UIButton()
            configureThemeButton(themeButton, with: buttonInfo, buttonsNumber: buttonsInfo.count)
            currentThemeButtons.append(themeButton)
        }
    }
    
    
    // MARK: - Impressions Controller
    
    private var currentlySelectedThemeButton: UIButton?
    
    @objc func themeButtonIsTapped(sender: UIButton) {
        // Make previosly chosen theme button visually unselected
        currentlySelectedThemeButton?.setUnselectedButtonBackgroundColor()
        // Update currently chosen button
        currentlySelectedThemeButton = sender
        // Make currently chosen theme button visually selected
        currentlySelectedThemeButton?.setSelectedBackgroundColor()
        
        themeWasChanged(to: (currentlySelectedThemeButton?.currentTitle)!)
    }
    
    
    // Theme that is currently chosen and today session last theme by default
    private var currentTheme: String {
        get {
            return ImpressionsDataModel.todaySessionLastTheme()
        }
        set {
            ImpressionsDataModel.updateTodaySessionLastTheme(with: newValue)
        }
    }
    
    // Current text is displayed by main text view
    private var currentlyDisplayedText: String {
        get {
            return mainTextView.text
        }
        set {
            mainTextView.text = newValue
        }
    }
    
    // Today records that are saved in storage (get) and set new today records to storage (set)
    private var currentRecords: [String: String] {
        get {
            return ImpressionsDataModel.getTodayRecords()
        }
        set {
            ImpressionsDataModel.updateTodayRecords(with: newValue)
        }
    }
    
    // Save previous theme text, update current theme, upload current text
    private func themeWasChanged(to newTheme: String) {
        currentRecords.updateValue(currentlyDisplayedText, forKey: currentTheme)
        currentTheme = newTheme
        currentlyDisplayedText = currentRecords[currentTheme]!
    }
    
    
    // MARK: - Save last theme text to today records AND page which is compiled based on today records to Core Data.
    
    // Method is called within viewWillDisappear in ImpressionsViewController, applicationWillTerminate and applicationWillResignActive in AppDelegate
    func defaultPreparationBeforeClosingTheInterface() {
        // Save text updating for theme that was chosen by user last time
        currentRecords.updateValue(currentlyDisplayedText, forKey: currentTheme)
        
        /// Updates impressions storage in order to avoid the nil founding error when default saving because of disacordance of themes with impressions being stored in storage and newly available themes which are uploaded
        ImpressionsDataModel.defaultImpressionsStorageUpdating()
        
        // Create, update or delete page dated by today depending on today records
        ImpressionsDataModel.updateTodayPageInCoreDateAccordingToTodayRecords()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        defaultPreparationBeforeClosingTheInterface()
    }
}
