//
//  OfferSubscriptionView.swift
//  BeVisionary
//
//  Created by Ivan Mikhnenkov on 03.05.2018.
//  Copyright © 2018 Ivan Mikhnenkov. All rights reserved.
//

import UIKit
import StoreKit

class OfferSubscriptionViewController: UIViewController, IAPHandlerDelegate {
    
    /// Offer subscription mode which is set when receipt is checking OR according to network connection
    var offeredSubscriptionMode: IAPHandler.OfferSubscriptionMode = .noProductFound {
        didSet {
            updateSubscriptionButtonTitle()
        }
    }
    
    var subscriptionName: String = "" {
        didSet {
            updateSubscriptionButtonTitle()
        }
    }
    
    var pricePerMonthPhrase: String = "" {
        didSet {
           updateSubscriptionButtonTitle()
        }
    }
    
    // Updates subscription button title according to current offer subscription mode
    private func updateSubscriptionButtonTitle() {
        switch offeredSubscriptionMode {
        case .introductoryPrice: setIntroductoryPrice()
        case .standardPrice: setStandardPrice()
        case .noProductFound: setNoProductFound()
        }
    }
    
    private func setIntroductoryPrice() {
        subscriptionButtonAttributedTitle = customizedButtonTitle(
            fullText: "\(subscriptionName) - \(TextUsedInInterface.freeMonthTrialPhrase)\n\(TextUsedInInterface.thenWordWithSpace)\(pricePerMonthPhrase)",
            mainFontToHeight: ButtonsAppearance.subscribeButtonMainFontToHeight,
            subFontToHeight: ButtonsAppearance.subscribeButtonSubFontToHeight,
            superText: "\(subscriptionName) - \(TextUsedInInterface.freeMonthTrialPhrase)\n",
            subText: "\(TextUsedInInterface.thenWordWithSpace)\(pricePerMonthPhrase)",
            button: subscriptionButton)
    }
    
    private func setStandardPrice() {
        subscriptionButtonAttributedTitle = customizedButtonTitle(fullText: "\(subscriptionName) - \(pricePerMonthPhrase)", mainFontToHeight: ButtonsAppearance.subscribeButtonMainFontToHeight, button: subscriptionButton)
    }
    
    private func setNoProductFound() {
        subscriptionButtonAttributedTitle = customizedButtonTitle(fullText: TextUsedInInterface.noProductFoundPhrase, mainFontToHeight: ButtonsAppearance.subscribeButtonMainFontToHeight, button: subscriptionButton)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.isOpaque = true
        setupBackground()
        setupInterface()
    }
    
    /// Sets an inspiring image with drawn buttons shapes to be a background
    private func setupBackground() {
        let backgroundImageView = UIImageView(frame: view.bounds)
        backgroundImageView.image = #imageLiteral(resourceName: "OfferSubscriptionUI.Background").withRenderingMode(.alwaysOriginal)
        view.addSubview(backgroundImageView)
    }
    
    /// Sets buying and restoring subscription buttons and subscription terms text view
    private func setupInterface() {
        setupSubscriptionButton()
        setupRestoreSubscriptionButton()
        setupSubscriptionTermsTextView()
        setupPrivacyPolicyLinkButton()
        setupTermsOfUseLinkButton()
    }
    
    private func setupSubscriptionButton() {
        subscriptionButton.frame = InterfaceLayout.subscriptionButtonFrame(in: view)
        subscriptionButton.backgroundColor = ButtonsAppearance.matBackground
        subscriptionButton.isEnabled = true
        updateSubscriptionButtonTitle()
        subscriptionButton.addTarget(self, action: #selector(subscribe), for: .touchUpInside)
        view.addSubview(subscriptionButton)
    }
    
    private func setupRestoreSubscriptionButton() {
        let restoreSubscriptionButton = UIButton(frame: InterfaceLayout.restoreSubscriptionButtonFrame(in: view))
        restoreSubscriptionButton.backgroundColor = ButtonsAppearance.matBackground
        restoreSubscriptionButton.isEnabled = true
        restoreSubscriptionButton.setAttributedTitle(customizedButtonTitle(fullText: TextUsedInInterface.restoreSubscriptionPhrase, mainFontToHeight: ButtonsAppearance.restoreButtonFontSizeToHeight, button: restoreSubscriptionButton), for: .normal)
        restoreSubscriptionButton.addTarget(self, action: #selector(restoreSubscription), for: .touchUpInside)
        view.addSubview(restoreSubscriptionButton)
    }
    
    private func setupSubscriptionTermsTextView() {
        let subscriptionTermsTextView = UITextView(frame: InterfaceLayout.subscriptionTermsTextViewFrame(in: view))
        subscriptionTermsTextView.backgroundColor = ButtonsAppearance.clearBackground
        subscriptionTermsTextView.textColor = ButtonsAppearance.textColor
        subscriptionTermsTextView.isEditable = false
        subscriptionTermsTextView.isSelectable = false
        subscriptionTermsTextView.textAlignment = .left
        subscriptionTermsTextView.text = LocalizedString("OfferSubscriptionVC; subscriptionTermsText")
        subscriptionTermsTextView.font = UIFont.systemFont(ofSize: subscriptionTermsTextView.bounds.width * 0.02)
        view.addSubview(subscriptionTermsTextView)
    }

    
    private func setupPrivacyPolicyLinkButton() {
        let openPrivacyPolicyButton = UIButton(frame: InterfaceLayout.openPrivacyPolicyButtonFrame(in: view))
        openPrivacyPolicyButton.backgroundColor = ButtonsAppearance.clearBackground
        openPrivacyPolicyButton.setAttributedTitle(customizedButtonTitle(fullText: TextUsedInInterface.privacyPolicyTitle,
                                                                         mainFontToHeight: ButtonsAppearance.linkButtonFontSizeToHeight,
                                                                         button: openPrivacyPolicyButton), for: .normal)
        openPrivacyPolicyButton.addTarget(self, action: #selector(openPrivacyPolicy), for: .touchUpInside)
        view.addSubview(openPrivacyPolicyButton)
    }
    
    private func setupTermsOfUseLinkButton() {
        let openTermsOfUseButton = UIButton(frame: InterfaceLayout.openTermsOfUseButtonFrame(in: view))
        openTermsOfUseButton.backgroundColor = ButtonsAppearance.clearBackground
        openTermsOfUseButton.setAttributedTitle(customizedButtonTitle(fullText: TextUsedInInterface.termsOfUseTitle,
                                                                      mainFontToHeight: ButtonsAppearance.linkButtonFontSizeToHeight,
                                                                      button: openTermsOfUseButton), for: .normal)
        
        openTermsOfUseButton.addTarget(self, action: #selector(openTermsOfUse), for: .touchUpInside)
        view.addSubview(openTermsOfUseButton)
    }

    
    @objc private func openPrivacyPolicy() {
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(URL(string: "https://bevisionaryapp.com/privacy-policy/")!, options: [:], completionHandler: nil)
        } else {
            // Fallback on earlier versions
            UIApplication.shared.openURL(URL(string: "https://bevisionaryapp.com/privacy-policy/")!)
        }
    }
    
    
    @objc private func openTermsOfUse() {
        if #available(iOS 10.0, *) { 
            UIApplication.shared.open(URL(string: "https://bevisionaryapp.com/terms-of-use/")!, options: [:], completionHandler: nil)
        } else {
            // Fallback on earlier versions
            UIApplication.shared.openURL(URL(string: "https://bevisionaryapp.com/terms-of-use/")!)
        }
    }
    
    // If either mainText or creditsText is nil, then it just sets button title, customized according to current interface design, else it sets main text and subtext, customized accordingly (for introductory price case)
    func customizedButtonTitle(fullText: String, mainFontToHeight: CGFloat, subFontToHeight: CGFloat? = nil, superText: String? = nil, subText: String? = nil, button: UIButton) -> NSAttributedString {
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        if superText != nil && subText != nil && subFontToHeight != nil {
            button.titleLabel!.numberOfLines = 2
            let mainFont = UIFont(name:"Avenir Next", size: button.bounds.height * mainFontToHeight)!
            let subFont = UIFont(name:"Avenir Next", size: button.bounds.height * subFontToHeight!)!
            let attributedString = NSMutableAttributedString(string: fullText, attributes: nil)

            let bigRange = (attributedString.string as NSString).range(of: superText!)
            let creditsRange = (attributedString.string as NSString).range(of: subText!)
            attributedString.setAttributes([NSAttributedStringKey.font: mainFont, NSAttributedStringKey.foregroundColor: ButtonsAppearance.buttonTitlesColor], range: bigRange)
            attributedString.setAttributes([NSAttributedStringKey.font: subFont, NSAttributedStringKey.foregroundColor: ButtonsAppearance.buttonTitlesColor], range: creditsRange)
            return attributedString
        } else {
            button.titleLabel!.numberOfLines = 1
            let mainFont = UIFont(name:"Avenir Next", size: button.bounds.height * mainFontToHeight)!
            let attributedString = NSMutableAttributedString(string: fullText, attributes: [NSAttributedStringKey.font: mainFont, NSAttributedStringKey.foregroundColor: ButtonsAppearance.buttonTitlesColor])
            return attributedString
        }
    }

    
    // MARK: - App Store Interaction
    
    /// Reference to subscribe button in order to change its text if needed
    private var subscriptionButton = UIButton()
    /// Adjusts size and weight of the particular text, so for free trial text is more than for price displaying text
    
    private var subscriptionButtonAttributedTitle: NSAttributedString = NSAttributedString(string: "") {
        didSet {
            subscriptionButton.setAttributedTitle(subscriptionButtonAttributedTitle, for: .normal)
        }
    }
    
    @objc private func subscribe() {
        IAPHandler.shared.requestPayment()
    }

    @objc private func restoreSubscription() {
        IAPHandler.shared.restoreSubscription()
    }
    

    /// Enables the full access to BeVisionary functionality to user. Is called when user subscribes to change the interface.
    func unblockGoalsInterface() {
        if let goalsVC = parent as? GoalsViewController {
            goalsVC.removeOfferSubscriptionViewController()
        }
    }
    
    
    private struct InterfaceLayout {
        private static let xBeginningPart: CGFloat = 0.2
        private static let yBeginningPart: CGFloat = 0.12
        private static let widthPart: CGFloat = 0.6
        private static let heightPart: CGFloat = 0.24
        private static let partBetweenElements: CGFloat = 0.05
        
        static func subscriptionButtonFrame(in view: UIView) -> CGRect {
            return CGRect(x: view.bounds.maxX * 0.05, y: view.bounds.maxY * yBeginningPart, width: view.bounds.maxX * 0.9, height: view.bounds.maxY * heightPart)
        }
        
        static func restoreSubscriptionButtonFrame(in view: UIView) -> CGRect {
            return CGRect(x: view.bounds.maxX * 0.2, y: view.bounds.maxY * (yBeginningPart + heightPart + partBetweenElements), width: view.bounds.maxX * 0.6, height: view.bounds.maxY * heightPart * 0.36)
        }
        
        static func subscriptionTermsTextViewFrame(in view: UIView) -> CGRect {
            return CGRect(x: view.bounds.maxX * 0.05, y: view.bounds.maxY * (yBeginningPart + heightPart * 1.36 + partBetweenElements * 2), width: view.bounds.width * 0.9, height: view.bounds.height * 0.24)
        }
        
        static func openPrivacyPolicyButtonFrame(in view: UIView) -> CGRect {
            return CGRect(x: 0.1 * view.bounds.width, y: 0.85 * view.bounds.height, width: view.bounds.width * 0.35, height: view.bounds.height * 0.05)
        }
        
        static func openTermsOfUseButtonFrame(in view: UIView) -> CGRect {
            return CGRect(x: 0.55 * view.bounds.width, y: 0.85 * view.bounds.height, width: view.bounds.width * 0.35, height: view.bounds.height * 0.05)
        }
    }
    
    private struct ButtonsAppearance {
        static let subscribeButtonMainFontToHeight: CGFloat = 0.22
        static let subscribeButtonSubFontToHeight: CGFloat = 0.12
        static let restoreButtonFontSizeToHeight: CGFloat = 0.4
        static let linkButtonFontSizeToHeight: CGFloat = 0.5
        
        static let font = UIFont(name: "Avenir next", size: 20)!
        static let buttonTitlesColor = UIColor(hex: "FCFFE1")!
        static let textColor = UIColor(hex: "FCFFE1")!.withAlphaComponent(0.7)

        
        static let matBackground = UIColor.white.withAlphaComponent(0.1)
        static let clearBackground = UIColor.clear
    }
    
    private struct TextUsedInInterface {
        static let freeMonthTrialPhrase = LocalizedString("OfferSubscriptionVC; subscriptionButtonTitleFreeTrial")
        static let thenWordWithSpace = LocalizedString("OfferSubscriptionVC; thenWord")
        static let noProductFoundPhrase = LocalizedString("OfferSubscriptionVC; subscriprionButtonTitleNoProductFound")
        static let restoreSubscriptionPhrase = LocalizedString("OfferSubscriptionVC; restoreButtonTitle")
        static let privacyPolicyTitle = LocalizedString("OfferSubscriptionVC; privacyPolicyTitle")
        static let termsOfUseTitle = LocalizedString("OfferSubscriptionVC; termsOfUseTitle")
    }
    
}


