//
//  Extensions.swift
//  BeVisionary
//
//  Created by Ivan Mikhnenkov on 15.04.2018.
//  Copyright © 2018 Ivan Mikhnenkov. All rights reserved.
//

import UIKit
import StoreKit

extension UIColor {
    /// Generates vivid and not intrusive colors
    static func generateThemeColor() -> UIColor {
        let hue : CGFloat = CGFloat(arc4random() % 360) / 360 // get full range from 0.0 to 1.0
        if hue > CGFloat(30) / 360 && hue < CGFloat(210) / 360 {
            // Light hue color group
            return UIColor(hue: hue, saturation: CGFloat(1), brightness: CGFloat(0.7), alpha: 1)
        } else {
            // Dark hue color group
            return UIColor(hue: hue, saturation: CGFloat(0.75), brightness: CGFloat(0.85), alpha: 1)
        }
    }

    /// Makes a color from hex inscription
    convenience init?(hex: String) {
        var hexNormalized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexNormalized = hexNormalized.replacingOccurrences(of: "#", with: "")
        
        // Helpers
        var rgb: UInt32 = 0
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 1.0
        let length = hexNormalized.count
        
        // Create Scanner
        Scanner(string: hexNormalized).scanHexInt32(&rgb)
        
        if length == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0
            
        } else if length == 8 {
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x000000FF) / 255.0
            
        } else {
            return nil
        }
        
        self.init(red: r, green: g, blue: b, alpha: a)
    }
    
    /// Mark a hex insription of color
    func toHex() -> String? {
        // Extract Components
        guard let components = cgColor.components, components.count >= 3 else {
            return nil
        }
        
        // Helpers
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        var a = Float(1.0)
        
        if components.count >= 4 {
            a = Float(components[3])
        }
        
        // Create Hex String
        let hex = String(format: "%02lX%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255), lroundf(a * 255))
        
        return hex
    }
    
    static let systemEnabledTitleColor = UIColor(hex: "009298")!
    static let systemDisabledTitleColor = UIColor.lightGray
    static let systemBackgroundColor = UIColor.white
    static let nonContentPopoverBackgroundColor = UIColor.black.withAlphaComponent(0.4)
    
    static let appStar = UIColor(hex: "FFEABF")!
    static let appRed = UIColor(hex: "E70000")!
    static let appNavi = UIColor(hex: "000070")!
    static let defaultThemeColor = UIColor(hex: "266EFF")!
}

// Used in Impressions interface building for theme buttons
extension UIButton {
    func setSelectedBackgroundColor() {
        self.backgroundColor = self.backgroundColor?.withAlphaComponent(1.0)
    }
    
    func setUnselectedButtonBackgroundColor() {
        self.backgroundColor = self.backgroundColor?.withAlphaComponent(0.35)
    }
    
    func configureThemeButtonTitleLabel(buttonsNumber: Int) {
        self.titleLabel?.textAlignment = .center
        self.titleLabel?.numberOfLines = 0
        self.titleLabel?.lineBreakMode = .byWordWrapping
        self.titleLabel?.font = UIFont.appFontOfSize(self.bounds.width * 0.15)
    }
}

// Makes goals time line work perfectly
let currentCalendar = Calendar(identifier: Calendar.Identifier.gregorian)

extension Date {
    
    static func from(year: Int, month: Int, day: Int) -> Date {
        let dateComponents = DateComponents(year: year, month: month, day: day)
        
        let date = currentCalendar.date(from: dateComponents)!.formattedDate()
        return date
    }
    
    /// Gives three important date components of the date which is day, month, year.
    func getDateComponents() -> DateComponents {
        var dateComponents = currentCalendar.dateComponents([.day, .month, .year, .weekday, .weekOfYear], from: self)
        dateComponents.hour = 12
        return dateComponents
    }
    
    /// Formats input date to be appropriate for Life Board and return it
    func formattedDate() -> Date {
        let formattedDate = currentCalendar.date(from: self.getDateComponents())!
        return formattedDate
    }
    
    /// Returns appropriately formatted current date
    static func todayDateFormatted() -> Date {
        return Date().formattedDate()
    }
    
    /// Returns appropriately formatted date that differs from current date by number of days that was input
    static func dateDifferFromToday(by days: Int) -> Date {
        return todayDateFormatted().changeDateByAddingDays(days)
    }
    
    /// Returns first day of particular year and month (formatted)
    static func firstDayDate(year: Int, month: Int) -> Date? {
        if month >= 1 && month <= 12 {
            let dateComponents = DateComponents(year: year, month: month, day: 1)
            let date = currentCalendar.date(from: dateComponents)?.formattedDate()
            return date
        } else {
            return nil
        }
    }
    
    /// Returns last day of input year and month (formatted)
    static func lastDayDate(year: Int, month: Int) -> Date? {
        if month >= 1 && month <= 12 {
            return currentCalendar.date(byAdding: DateComponents(month: 1, day: -1), to: firstDayDate(year: year, month: month)!)
        } else {
            return nil
        }
    }
    
    func changeDateByAddingDays(_ days: Int) -> Date {
        let newDate = currentCalendar.date(byAdding: DateComponents(day: days), to: self)
        return newDate!
    }
    
    func changeDateByAddingMonths(_ months: Int) -> Date {
        let newDate = currentCalendar.date(byAdding: DateComponents(month: months), to: self)
        return newDate!
    }
    
    func changeDateByAddingYears(_ years: Int) -> Date {
        let newDate = currentCalendar.date(byAdding: DateComponents(year: years), to: self)
        return newDate!
    }
    
    /// Current time as GMT for receipt checking: if user is currently subscribed
    static func getCurrentLocalDateApp() -> Date {
        var now = Date()
        var nowComponents = DateComponents()
        let calendar = Calendar.current
        nowComponents.year = (Calendar.current as NSCalendar).component(NSCalendar.Unit.year, from: now)
        nowComponents.month = (Calendar.current as NSCalendar).component(NSCalendar.Unit.month, from: now)
        nowComponents.day = (Calendar.current as NSCalendar).component(NSCalendar.Unit.day, from: now)
        nowComponents.hour = (Calendar.current as NSCalendar).component(NSCalendar.Unit.hour, from: now)
        nowComponents.minute = (Calendar.current as NSCalendar).component(NSCalendar.Unit.minute, from: now)
        nowComponents.second = (Calendar.current as NSCalendar).component(NSCalendar.Unit.second, from: now)
        nowComponents.timeZone = TimeZone(abbreviation: "VV")
        now = calendar.date(from: nowComponents)!
        return now
    }
}

extension TimeInterval {
    static let oneDay = Double(24*60*60)
    
}

extension String {
    /// Make body text left, spacing correctly and add indents
    func formatMainBody() -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .natural
        paragraphStyle.firstLineHeadIndent = 20.0
        paragraphStyle.lineSpacing = 2
        let font = UIFont.systemFont(ofSize: CGFloat.mainBodyPageTextFontSize())
        let color = UIColor.black
        
        let attributedString = NSAttributedString(string: self + "\n", attributes: [NSAttributedStringKey.paragraphStyle: paragraphStyle, NSAttributedStringKey.font: font, NSAttributedStringKey.foregroundColor: color])
        return attributedString
    }
    
    // Make topics colorful and centered
    func formatHeader(color: UIColor) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.paragraphSpacing = 25
        paragraphStyle.paragraphSpacingBefore = 50
        
        let font = UIFont.systemFont(ofSize: CGFloat.mainBodyPageTextFontSize() + 1, weight: UIFont.Weight(rawValue: 0.6))
        
        let attributedString = NSAttributedString(string: self + "\n", attributes: [NSAttributedStringKey.paragraphStyle: paragraphStyle, NSAttributedStringKey.foregroundColor: color, NSAttributedStringKey.font: font])
        return attributedString
    }
    
    func formatCommentHeader(color: UIColor, in bounds: CGRect) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        
        if (UIApplication.shared.userInterfaceLayoutDirection == UIUserInterfaceLayoutDirection.leftToRight) {
            paragraphStyle.alignment = .right
        } else {
            paragraphStyle.alignment = .left
        }
        paragraphStyle.paragraphSpacing = 25
        paragraphStyle.paragraphSpacingBefore = 50
        paragraphStyle.tailIndent = -bounds.width * 0.1
        let font = UIFont.systemFont(ofSize: CGFloat.mainBodyPageTextFontSize() + 1, weight: UIFont.Weight(rawValue: 0.4))
        
        let attributedString = NSAttributedString(string: self + "\n", attributes: [NSAttributedStringKey.paragraphStyle: paragraphStyle, NSAttributedStringKey.foregroundColor: color, NSAttributedStringKey.font: font])
        return attributedString
    }
    
    /// Temporary method for warning about the absence of saved page for chosen date in Chronicle.
    func formatWarningText(within textViewBounds: CGRect) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.paragraphSpacing = textViewBounds.height / 25
        
        let font = UIFont.systemFont(ofSize: textViewBounds.height / 25, weight: UIFont.Weight(rawValue: 0.7))
        
        let attributedString = NSAttributedString(string: "\n\n\n" + self, attributes: [NSAttributedStringKey.paragraphStyle: paragraphStyle, NSAttributedStringKey.foregroundColor: UIColor(hex: "0084DD")!, NSAttributedStringKey.font: font])
        return attributedString
    }
    
    // Returns true if string contains some symbols besides " " and "\n"
    func containsMeaningfulText() -> Bool {
        if !self.isEmpty {
            for symbol in self {
                if symbol != " " && symbol != "\n" {
                    return true
                }
            }
        }
        return false
    }
    
    /// Returns a completely localized standalone version of month of certain number
    static func standaloneMonthNameForNumber(_ monthNumber: Int) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.shared
        return formatter.standaloneMonthSymbols[monthNumber - 1].capitalized(with: Locale.shared)
    }
    
    /// Returns a completely localized version of month and day text (e.g. 'October 16')
    static func dateAsTextFor(month: Int, day: Int, isLongVersion: Bool) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.shared
        formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: isLongVersion == true ? "MMMMd": "MMMd", options: 0, locale: Locale.shared)
        let date = Date.from(year: 2018, month: month, day: day)
        return formatter.string(from: date)
    }
    
    /// Returns a completely localized bersion of year (In some countries years are counted in another way)
    static func yearAsTextFor(year: Int) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.shared
        formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "YYYY", options: 0, locale: Locale.shared)
        let date = Date.from(year: year, month: 1, day: 1)
        return formatter.string(from: date)
    }
    
    /// Returns a completely localized bersion of the full date as text
    static func dateAsText(month: Int, day: Int, year: Int) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.shared
        formatter.dateStyle = .long
        let date = Date.from(year: year, month: month, day: day)
        return formatter.string(from: date)
    }
    
    static let defaultThemeName = LocalizedString("Goals; defaultThemeName")
}

extension Locale {
    // Locale which is used to all the internalization of BeVisionary
    static let shared = Locale.autoupdatingCurrent
}

extension CGRect {
    
    /// View frame for interface layout (after excluding tab bar)
    static func contentViewFrameOf(viewController: UIViewController) -> CGRect {
        let rootViewFrame = viewController.view.frame
        var contentViewFrame = rootViewFrame
        if let tabBarFrame = viewController.tabBarController?.tabBar.frame {
            contentViewFrame = CGRect(x: 0, y: 0 + tabBarFrame.height,
                                      width: rootViewFrame.maxX,
                                      height: rootViewFrame.maxY - tabBarFrame.height)
        }
        return contentViewFrame
    }
}

extension UIImageView {
    func fadeIn(_ duration: TimeInterval = 1.0, delay: TimeInterval = 0.0, completion: @escaping ((Bool) -> Void) = {(finished: Bool) -> Void in}) {
        UIView.animate(withDuration: duration, delay: delay, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.alpha = 1.0
        }, completion: completion)  }
    
    func fadeOut(_ duration: TimeInterval = 1.0, delay: TimeInterval = 0.0, completion: @escaping (Bool) -> Void = {(finished: Bool) -> Void in}) {
        UIView.animate(withDuration: duration, delay: delay, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.alpha = 0.0
        }, completion: completion)
    }
}

extension UIFont {
    static func appFontOfSize(_ size: CGFloat) -> UIFont {
        return UIFont(name: "Seravek", size: size)!
    }
}

extension SKProduct {
    func localizedPrice() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = self.priceLocale
        return formatter.string(from: self.price)!
    }
}


extension FloatingPoint {
    var degreesToRadians: Self { return self * .pi / 180 }
    var radiansToDegrees: Self { return self * 180 / .pi }
}

public extension UIWindow {
    public var visibleViewController: UIViewController? {
        return UIWindow.getVisibleViewControllerFrom(self.rootViewController)
    }
    
    public static func getVisibleViewControllerFrom(_ vc: UIViewController?) -> UIViewController? {
        if let nc = vc as? UINavigationController {
            return UIWindow.getVisibleViewControllerFrom(nc.visibleViewController)
        } else if let tc = vc as? UITabBarController {
            return UIWindow.getVisibleViewControllerFrom(tc.selectedViewController)
        } else {
            if let pvc = vc?.presentedViewController {
                return UIWindow.getVisibleViewControllerFrom(pvc)
            } else {
                return vc
            }
        }
    }
}

extension CGFloat {
    
    static func mainBodyPageTextFontSize() -> CGFloat {
        return CGFloat.screenWidthInLandscape * 0.0167
    }
    
    static var screenWidthInLandscape: CGFloat {
        if UIInterfaceOrientationIsPortrait(screenOrientation) {
            return UIScreen.main.bounds.size.height
        } else {
            return UIScreen.main.bounds.size.width
        }
    }
    
    static var screenHeightInLandscape: CGFloat {
        if UIInterfaceOrientationIsPortrait(screenOrientation) {
            return UIScreen.main.bounds.size.width
        } else {
            return UIScreen.main.bounds.size.height
        }
    }
    
    static func adaptiveThinBorderSize() -> CGFloat {
        return UIScreen.main.scale >= 2.0 ? 0.4: 1
    }
}

var screenOrientation: UIInterfaceOrientation {
    return UIApplication.shared.statusBarOrientation
}

// Allow to unite attributed strings with "+"
func + (left: NSAttributedString, right: NSAttributedString) -> NSAttributedString {
    let result = NSMutableAttributedString()
    result.append(left)
    result.append(right)
    return result
}

/// Shorter version of NSLocalizedString(key: comment:) function, which calls the original function with comment value ""
/// - Parameters:
///   - key: The key of specific localized string value
/// - Returns: Localized string value for specific key
func LocalizedString(_ key: String) -> String {
    return NSLocalizedString(key, comment: "")
}



