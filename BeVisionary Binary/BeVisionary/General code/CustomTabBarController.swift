//
//  CustomTabBarController.swift
//  BeVisionary
//
//  Created by Ivan Mikhnenkov on 15.04.2018.
//  Copyright © 2018 Ivan Mikhnenkov. All rights reserved.
//

import UIKit

class CustomTabBarController:  UITabBarController, UITabBarControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set delegate to be self in order to create animated transition
        self.delegate = self
        
        // Set ImpressionsVC to be an initial one
        self.selectedIndex = 1
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Sets tab bar to be on the top of the screen, and configure its height in dependence on the current screen size
        customTabBar.frame = CGRect(x: 0, y: 0,
                                    width: self.view.bounds.width,
                                    height: HeaderSettings.tabBarHeight(for: self.view))
        
        // Set custom background color instead of default
        customTabBar.barTintColor = HeaderSettings.backgroundColor
        
        // Spread tab bar items across the enire width of the tab bar (Needed for devices with iOS 9, 10 and/or devices with 7.9 inches screens)
        customTabBar.itemPositioning = .fill
        
        // Set custom titles for each button
        configureTabBarItems()
    }

    @IBOutlet weak var customTabBar: CustomTabBar!
    
    // Makes tab bar items that provide flat navigation to be custom.
    private func configureTabBarItems() {
        for (itemIndex, item) in customTabBar.items!.enumerated() {
                item.title = HeaderSettings.titlesForItemIndexes[itemIndex]!
                item.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: HeaderSettings.colorForUnselectedTitle, NSAttributedStringKey.font: HeaderSettings.headerFont(for: customTabBar)], for: .normal)
                item.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: HeaderSettings.colorForSelectedTitle, NSAttributedStringKey.font: HeaderSettings.headerFont(for: customTabBar)], for: .selected)
            }
    }

    // MARK: Sets animation when transition is going
    internal func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        if selectedViewController == nil || viewController == selectedViewController {
            return false
        }
        
        let fromView = selectedViewController!.view
        let toView = viewController.view
        
        UIView.transition(from: fromView!, to: toView!, duration: 0.25, options: [.transitionCrossDissolve], completion: nil)
        
        return true
    }
    
    private struct HeaderSettings {
        
        static func tabBarHeight(for rootView: UIView) -> CGFloat {
            return 20 + 32 * rootView.bounds.height / 768.0
        }
        
        static let titlesForItemIndexes = [0: TextUsedInInterface.goalsInterfaceTitle, 1: TextUsedInInterface.impressionsInterfaceTitle, 2: TextUsedInInterface.chronicleInterfaceTitle]
        
        static let backgroundColor = UIColor.appStar
    
        static let colorForSelectedTitle = UIColor.appNavi //UIColor(hex: "0D1489")!
        
        static let colorForUnselectedTitle = colorForSelectedTitle.withAlphaComponent(0.5)
        
        static func headerFont(for tabBar: UITabBar) -> UIFont {
            let headerFont = UIFont.appFontOfSize(tabBar.bounds.height * 0.7)
            return headerFont
        }
    }

    private struct TextUsedInInterface {
        static let goalsInterfaceTitle = LocalizedString("GoalsInterfaceTitle")
        static let impressionsInterfaceTitle = LocalizedString("ImpressionsInterfaceTitle")
        static let chronicleInterfaceTitle = LocalizedString("ChronicleInterfaceTitle")
    }
}

class CustomTabBar: UITabBar {}
