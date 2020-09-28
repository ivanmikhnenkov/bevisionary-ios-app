//
//  CommentPageViewController.swift
//  BeVisionary
//
//  Created by Ivan Mikhnenkov on 15.04.2018.
//  Copyright © 2018 Ivan Mikhnenkov. All rights reserved.
//

import UIKit

class CommentPageViewController: UIViewController, UITextViewDelegate {
    
    var pageDateUserCommentsOn: Date!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.isOpaque = false
        self.view.backgroundColor = AppearenceSettings.nonContentViewBackground
        rootView = self.view
        setupUI()

        /// Set notification center to notifies when keyboard appears and disappears
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustCommentTextViewForKeyboard), name: Notification.Name.UIKeyboardWillHide, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustCommentTextViewForKeyboard), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
        
        
    }
    
    // MARK: - Interface setup
    
    private var rootView: UIView!
    
    private var contentView: UIView!
    private var commentTextView: UITextView!
    private var saveCommentButton: UIButton!
    
    private func setupUI() {
        addContentView()
        addCommentTextView()
        addCancelButton()
        addSaveCommentButton()
    }
    
    private func addContentView() {
        contentView = UIView(frame: LayoutSettings.contentViewFrameIn(viewBounds: rootView.bounds))
        contentView.backgroundColor = AppearenceSettings.contentViewBackgroundColor
        contentView.layer.cornerRadius = contentView.bounds.width * LayoutSettings.cornerRadiusToContentViewWidth
        contentView.layer.masksToBounds = true
        self.view.addSubview(contentView)
    }
    
    private func addCommentTextView() {
        commentTextView = UITextView(frame: LayoutSettings.commentTextViewFrameIn(viewBounds: contentView.bounds))
        commentTextView.delegate = self
        commentTextView.isEditable = true
        commentTextView.layer.borderWidth = AppearenceSettings.borderWidth
        commentTextView.layer.borderColor = AppearenceSettings.borderColor
        commentTextView.font = UIFont.systemFont(ofSize: contentView.bounds.height * AppearenceSettings.commentTextFontSizeToHeight)
        commentTextView.becomeFirstResponder()
        contentView.addSubview(commentTextView)
    }
    
    private func addCancelButton() {
        let cancelButton = UIButton(frame: LayoutSettings.cancelButtonFrameIn(viewBounds: contentView.bounds))
        cancelButton.setTitle(TextsUsedInInterface.cancelButtonTitle, for: .normal)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: cancelButton.bounds.height * AppearenceSettings.buttonFontSizeToHeight)
        cancelButton.setTitleColor(AppearenceSettings.enabledButtonTextColor, for: .normal)
        cancelButton.isEnabled = true
        cancelButton.addTarget(self, action: #selector(cancelButtonIsPressed), for: .touchUpInside)
        cancelButton.backgroundColor = AppearenceSettings.contentViewBackgroundColor
        cancelButton.titleLabel?.adjustsFontSizeToFitWidth = true
        contentView.addSubview(cancelButton)
    }
    
    private func addSaveCommentButton() {
        saveCommentButton = UIButton(frame: LayoutSettings.saveCommentButtonFrameIn(viewBounds: contentView.bounds))
        saveCommentButton.setTitle(TextsUsedInInterface.saveCommentButtonTitle, for: .normal)
        saveCommentButton.setTitleColor(AppearenceSettings.disabledButtonTextColor, for: .normal)
        saveCommentButton.titleLabel?.font = UIFont.systemFont(ofSize: saveCommentButton.bounds.height * AppearenceSettings.buttonFontSizeToHeight)
        saveCommentButton.isEnabled = false
        saveCommentButton.addTarget(self, action: #selector(saveCommentButtonIsPressed(sender:)), for: .touchUpInside)
        saveCommentButton.backgroundColor = AppearenceSettings.contentViewBackgroundColor
        saveCommentButton.titleLabel?.adjustsFontSizeToFitWidth = true
        contentView.addSubview(saveCommentButton)
    }
    
    private struct LayoutSettings {
        private static let contentViewWidthPart: CGFloat = 0.6
        private static let contentViewHeightPart: CGFloat = 0.8
        static let cornerRadiusToContentViewWidth: CGFloat = 0.05
        
        private static let commentTextViewWidthPart: CGFloat = 0.9
        private static let commentTextViewHeightPart: CGFloat = 0.8
        private static let buttonsHeightPart: CGFloat = 0.15
        private static let buttonsWidthPart: CGFloat = 0.5
        
        static func contentViewFrameIn(viewBounds: CGRect) -> CGRect {
            return CGRect(x: viewBounds.width * (1 - contentViewWidthPart) / 2,
                          y: viewBounds.height * (1 - contentViewHeightPart) / 2,
                          width: viewBounds.width * contentViewWidthPart,
                          height: viewBounds.height * contentViewHeightPart)
        }
        
        static func commentTextViewFrameIn(viewBounds: CGRect) -> CGRect {
            return CGRect(x: viewBounds.width * (1 - commentTextViewWidthPart) / 2,
                          y: viewBounds.height * (1 - commentTextViewHeightPart - buttonsHeightPart),
                          width: viewBounds.width * commentTextViewWidthPart,
                          height: viewBounds.height * commentTextViewHeightPart)
        }
        
        static func cancelButtonFrameIn(viewBounds: CGRect) -> CGRect {
            return CGRect(x: viewBounds.width * buttonsWidthPart * 0,
                          y: viewBounds.height * (1 - buttonsHeightPart),
                          width: viewBounds.width * buttonsWidthPart,
                          height: viewBounds.height * buttonsHeightPart)
        }
        
        static func saveCommentButtonFrameIn(viewBounds: CGRect) -> CGRect {
            return CGRect(x: viewBounds.width * buttonsWidthPart * 1,
                          y: viewBounds.height * (1 - buttonsHeightPart),
                          width: viewBounds.width * buttonsWidthPart,
                          height: viewBounds.height * buttonsHeightPart)
        }
    }
    
    private struct AppearenceSettings {
        static let nonContentViewBackground = UIColor.nonContentPopoverBackgroundColor
        static let contentViewBackgroundColor = UIColor.systemBackgroundColor
        
        static let enabledButtonTextColor = UIColor.systemEnabledTitleColor
        static let disabledButtonTextColor = UIColor.systemDisabledTitleColor
        static let buttonBackgroundColor = UIColor.systemBackgroundColor
        
        static let buttonFontSizeToHeight: CGFloat = 0.25
        
        static let borderWidth: CGFloat = CGFloat.adaptiveThinBorderSize()
        static let borderColor = UIColor.systemEnabledTitleColor.cgColor
        
        static let commentTextFontSizeToHeight: CGFloat = 0.03
        static let commentHeaderColor = UIColor(hex: "000448")!
    }
    
    private struct TextsUsedInInterface {
        static let cancelButtonTitle = LocalizedString("CommentPageVC; cancelButtonTitle")
        static let saveCommentButtonTitle = LocalizedString("CommentPageVC; saveCommentButtonTitle")
    }
    
    
    // MARK: - Text view managing (Text view auto scrolling if keyboard overlaps)
    
    /// Adjusts main text view to be not overlapped by keyboard
    @objc func adjustCommentTextViewForKeyboard(respondingTo notification: Notification) {
        let userInfo = notification.userInfo!
        
        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == Notification.Name.UIKeyboardWillHide {
            commentTextView.contentInset = UIEdgeInsets.zero
        } else {
            commentTextView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - (view.bounds.height - contentView.bounds.height) / 2 - (contentView.bounds.height - commentTextView.bounds.height) / 2, right: 0)
        }
        
        commentTextView.scrollIndicatorInsets = commentTextView.contentInset
        
        let selectedRange = commentTextView.selectedRange
        commentTextView.scrollRangeToVisible(selectedRange)
    }
    
    /// Enable and disable saveCommentButton depending on the text in commentTextView
    func textViewDidEndEditing(_ textView: UITextView) {
        if commentText.containsMeaningfulText() {
            enableSaveCommentButton()
        } else {
            disableSaveCommentButton()
        }
    }
    
    // MARK: - Controller
    
    @objc private func saveCommentButtonIsPressed(sender: UIButton) {
        /// Change commentedPage by adding comment
        if let commentedPage = Page.uploadPage(datedBy: pageDateUserCommentsOn, excludeTodayDatedPage: true, in: context) {
            Page.createOrUpdatePage(containing: (commentedPage.attributedText)! + fullCommentAttributedText(), datedBy: commentedPage.date!, excludeTodayDatedPage: true, in: context)
        }
        delegate.updateCurrentlyDisplayedPage()
        dismiss(animated: true, completion: nil)
    }
    
    /// Dismiss the commentPageVC without any changes
    @objc private func cancelButtonIsPressed() {
        dismiss(animated: true, completion: nil)
    }
    
    
    /// Configure saveCommentButton to be enabled
    private func enableSaveCommentButton() {
        saveCommentButton.isEnabled = true
        saveCommentButton.setTitleColor(AppearenceSettings.enabledButtonTextColor, for: .normal)
    }
    
    /// Configure saveCommentButton to be disabled
    private func disableSaveCommentButton() {
        saveCommentButton.isEnabled = false
        saveCommentButton.setTitleColor(AppearenceSettings.disabledButtonTextColor, for: .normal)
    }
    
    // MARK: - Model
    
    /// Current text of commentTextView
    private var commentText: String {
        get {
            return commentTextView.text
        }
        set {
            commentTextView.text = commentText
        }
    }
    
    /// Returns final complete consisting of header and main body of NSAttributedString type
    private func fullCommentAttributedText() -> NSAttributedString {
        return commentHeader().formatCommentHeader(color: AppearenceSettings.commentHeaderColor, in: commentTextView.bounds) + commentText.formatMainBody()
    }
    
    /// Returns comment header in String type
    private func commentHeader() -> String {
        let todayDateComponents = Date.todayDateFormatted().getDateComponents()
        return String.dateAsText(month: todayDateComponents.month!, day: todayDateComponents.day!, year: todayDateComponents.year!)
    }
    
    // Is set by presenting view controller
    var delegate: CommentPageViewControllerDelegate!
}

protocol CommentPageViewControllerDelegate {
    func updateCurrentlyDisplayedPage() -> Void
}

