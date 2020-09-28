//
//  ImpressionsView.swift
//  BeVisionary
//
//  Created by Ivan Mikhnenkov on 15.04.2018.
//  Copyright © 2018 Ivan Mikhnenkov. All rights reserved.
//

import UIKit

class ImpressionsView: UIView {
    // Theme buttons which would be built and displayed in Impressions View
    var themeButtons = [UIButton]() {
        willSet {
            // Delete old theme buttons subviews from superview (current are called newValue here)
            deleteThemeButtons()
        }
        didSet {
            addDuplicateButtonIfNeeded()
            // Add current theme buttons as subview to ImpressionsView instance (old are called oldValue here)
            setupThemeButtons()
        }
    }
    
    // Delete all current theme buttons from ImpressionsView instance subviews
    private func deleteThemeButtons() {
        for themeButton in themeButtons {
            themeButton.removeFromSuperview()
        }
    }
    
    // Set all current theme buttons to ImpressionsView instance subviews
    private func setupThemeButtons() {
        for themeButton in themeButtons {
            self.addSubview(themeButton)
        }
    }
    
    // Add duplicate button if there is only default theme button in order to make design consistency
    private func addDuplicateButtonIfNeeded() {
        if themeButtons.count == 1 {
            let defaultButton = themeButtons.first!
            let defaultButtonFrame = defaultButton.frame
            let duplicateButton = UIButton(frame: CGRect(x: self.bounds.width - defaultButtonFrame.width, y: 0, width: defaultButtonFrame.width, height: defaultButtonFrame.height))
            duplicateButton.backgroundColor = defaultButton.backgroundColor
            themeButtons.append(duplicateButton)
        }
    }
}
