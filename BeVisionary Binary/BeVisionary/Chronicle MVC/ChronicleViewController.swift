//
//  ChronicleViewController.swift
//  BeVisionary
//
//  Created by Ivan Mikhnenkov on 15.04.2018.
//  Copyright © 2018 Ivan Mikhnenkov. All rights reserved.
//

import UIKit

class ChronicleViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, CommentPageViewControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buildChronicleInterface()
        setDefaults()
    }
    
    // MARK: - Chronicle interface
    
    private var contentView: UIView!
    private var yearPicker: UIPickerView!
    private var monthPicker: UIPickerView!
    private var daysCalendarView: UIView!
    private var commentButton: UIButton!
    private var selectedPageTextView: UITextView!
    
    private func addContentView() {
        contentView = UIView(frame: CGRect.contentViewFrameOf(viewController: self))
        view.addSubview(contentView)
    }
    
    private func addYearPicker() {
        yearPicker = UIPickerView(frame: LayoutSettings.yearPickerFrame(in: contentView))
        yearPicker.backgroundColor = UIColor.systemBackgroundColor
        yearPicker.delegate = self
        yearPicker.dataSource = self
        contentView.addSubview(yearPicker)
    }
    
    private func addMonthPicker() {
        monthPicker = UIPickerView(frame: LayoutSettings.monthPickerFrame(in: contentView))
        monthPicker.backgroundColor = UIColor.systemBackgroundColor
        monthPicker.delegate = self
        monthPicker.dataSource = self
        contentView.addSubview(monthPicker)
    }
    
    private func addDaysCalendarView() {
        daysCalendarView = UIView(frame: LayoutSettings.calendarDaysViewFrame(in: contentView))
        contentView.addSubview(daysCalendarView)
    }
    
    private func addCommentButton() {
        commentButton = UIButton(frame: LayoutSettings.commentButtonFrame(in: contentView))
        commentButton.backgroundColor = AppearenceSettings.commentButtonColor
        commentButton.setTitle(TextsUsedInInterface.commentButtonTitle, for: .normal)
        commentButton.setTitleColor(AppearenceSettings.commentButtonEnabledTextColor, for: .normal)
        commentButton.titleLabel?.textAlignment = .center
        
        // Multiplicator which is responsible for adjusting font size especially in cases when localized "comment on" title differs significantly from the original english version. Min is taken in order to prevent too big hieroglyphs
        let commentButtonFontSizeFactor = min(0.5 + 5 / CGFloat(commentButton.titleLabel!.text!.count), 1)
        
        commentButton.titleLabel?.font = UIFont.appFontOfSize(commentButton.bounds.height * 0.3 * commentButtonFontSizeFactor)
        commentButton.addTarget(self, action: #selector(commentButtonIsPressed), for: .touchUpInside)
        commentButton.titleLabel?.adjustsFontSizeToFitWidth = true
        contentView.addSubview(commentButton)
    }
    
    private func addSelectedPageTextView() {
        selectedPageTextView = UITextView(frame: LayoutSettings.selectedPageTextViewFrame(in: contentView))
        selectedPageTextView.isEditable = false
        selectedPageTextView.isSelectable = false
        selectedPageTextView.isScrollEnabled = true
        selectedPageTextView.textAlignment = .natural
        contentView.addSubview(selectedPageTextView)
    }
    
    private func buildChronicleInterface() {
        addContentView()
        addYearPicker()
        addMonthPicker()
        addDaysCalendarView()
        addCommentButton()
        addSelectedPageTextView()
    }
    
    private struct LayoutSettings {
        
        private static let leftSideWidthPart: CGFloat = 0.4
        private static let rightnterfaceSideWidthPart: CGFloat = 1 - leftSideWidthPart
        
        private static let monthAndYearPickerHeightPart: CGFloat = 0.2
        private static let calendarHeightPart: CGFloat = 0.6
        private static let commentButtonHeightPart: CGFloat = 0.2
        
        private static let yearPickerWidthPart: CGFloat = 0.4
        private static let monthPickerWidthPart: CGFloat = 1 - yearPickerWidthPart
        
        private static func leftSideWidth(in contentView: UIView) -> CGFloat {
            return contentView.bounds.width * leftSideWidthPart
        }
        
        
        static func yearPickerFrame(in contentView: UIView) -> CGRect {
            return CGRect(x: 0,
                          y: 0,
                          width: leftSideWidth(in: contentView) * yearPickerWidthPart,
                          height: contentView.bounds.height * monthAndYearPickerHeightPart)
        }
        
        static func monthPickerFrame(in contentView: UIView) -> CGRect {
            return CGRect(x: yearPickerFrame(in: contentView).width,
                          y: 0,
                          width: leftSideWidth(in: contentView) * monthPickerWidthPart,
                          height: contentView.bounds.height * monthAndYearPickerHeightPart)
        }
        
        static func calendarDaysViewFrame(in contentView: UIView) -> CGRect {
            return CGRect(x: 0,
                          y: contentView.bounds.height * monthAndYearPickerHeightPart,
                          width: leftSideWidth(in: contentView),
                          height: contentView.bounds.height * calendarHeightPart)
        }
        
        static func commentButtonFrame(in contentView: UIView) -> CGRect {
            return CGRect(x: 0,
                          y: calendarDaysViewFrame(in: contentView).maxY,
                          width: leftSideWidth(in: contentView),
                          height: contentView.bounds.height * commentButtonHeightPart)
        }
        
        static func selectedPageTextViewFrame(in contentView: UIView) -> CGRect {
            let indent = contentView.bounds.width * 0.01
            return CGRect(x: leftSideWidth(in: contentView) + indent,
                          y: 0,
                          width: contentView.bounds.width - leftSideWidth(in: contentView) - indent,
                          height: contentView.bounds.height)
        }
        
        static func frameOfDayButtonWith(buttonInfo: DaysCalendarModel.DayButtonInfo, in contentView: UIView) -> CGRect {
            let rowNumber = CGFloat(Int(buttonInfo.position / 7))
            let columnNumber = CGFloat(buttonInfo.position % 7)
            
            let buttonWidth = contentView.bounds.width / 7
            let buttonHeight = contentView.bounds.height / 6
            
            return CGRect(x: buttonWidth * columnNumber, y: buttonHeight * rowNumber, width: buttonWidth, height: buttonHeight)
        }
    }
    
    private struct AppearenceSettings {
        static let yearPickerTextColor = UIColor.appRed
        static let monthPickerTextColor = UIColor(hex: "008AE6")!
        
        static let dayButtonColorEnabled = UIColor(hex: "B50202")!
        static let dayButtonColorDisabled = dayButtonColorEnabled.withAlphaComponent(0.3)
        static let selectedDayButtonBackgroundColor = AppearenceSettings.commentButtonColor.withAlphaComponent(0.2)
        static let unselectedDayButtonBackgroundColor = UIColor.systemBackgroundColor
        
        static let commentButtonColor = UIColor(hex: "32E2AB")!
        static let commentButtonEnabledTextColor = UIColor.systemBackgroundColor
        static let commentButtonDisabledTextColor = UIColor(hex: "C4A0AD")!
    }
    
    private struct TextsUsedInInterface {
        static let commentButtonTitle = LocalizedString("ChronicleVC; commentButtonTitle")
        static let noPagesSavedNotification = LocalizedString("ChronicleVC; noPagesSavedNotification")
    }
    
    // MARK: - Chronicle Controller
    
    /// Delegate method which is called bu comment page view controller when page is changed by adding new comment
    func updateCurrentlyDisplayedPage() {
        if let updatedDisplayedPage = Page.uploadPage(datedBy: dateOfCurrentlySelectedPage!, excludeTodayDatedPage: true, in: context) {
            currentlyDisplayedPageAttributedText = updatedDisplayedPage.attributedText!
            dateOfCurrentlySelectedPage = updatedDisplayedPage.date!
        }
    }
    
    /// Text which is currently displayed by page text view
    private var currentlyDisplayedPageAttributedText: NSAttributedString {
        get {
            return selectedPageTextView.attributedText
        }
        set {
            selectedPageTextView.attributedText = newValue
        }
    }
    
    
    /// Date of page which was lastly selected. Nil only if there is no pages saved at all, because last page is set to be selected by default.
    private var dateOfCurrentlySelectedPage: Date?
    
    /// Button which is currently selected, so its page text is displayed by page text view. Allows to swap between buttons in one month
    private var currentlySelectedButton: UIButton? {
        didSet {
            /// Change background color which means what button is selected from old button to new one.
            oldValue?.backgroundColor = AppearenceSettings.unselectedDayButtonBackgroundColor
            currentlySelectedButton?.backgroundColor = AppearenceSettings.selectedDayButtonBackgroundColor
        }
    }
    
    /// Year which is currently selected on year picker
    private var currentlySelectedYear: Int!
    
    /// Month which is currently selected on month picker.
    private var currentlySelectedMonth: Int! {
        didSet {
            resetDayButtonsFor(year: currentlySelectedYear,
                               month: currentlySelectedMonth,
                               in: daysCalendarView)
        }
    }
    
    /// Day buttons that are currently displayed on calendar view
    private func resetDayButtonsFor(year: Int, month: Int, in superView: UIView) {
        /// Delete all buttons which are already in view
        superView.subviews.forEach { $0.removeFromSuperview() }
        let currentlysSelectedPageDateComponents = dateOfCurrentlySelectedPage?.getDateComponents()
        for dayButton in DaysCalendarModel.allDayButtonsIn(year: year, month: month, in: superView) {
            if year == currentlysSelectedPageDateComponents?.year && month == currentlysSelectedPageDateComponents?.month {
                if Int(dayButton.titleLabel!.text!) == currentlysSelectedPageDateComponents?.day {
                    currentlySelectedButton = dayButton
                }
            }
            superView.addSubview(dayButton)
        }
    }
    
    
    /// Set appropriate page text to be displayed and change
    @objc private func dayButtonIsPressed(sender: UIButton) {
        /// Page date which is derived from currentle selected year, month and day (based on day button being selected)
        let dateOfCurrentlySelectedButton = Date.from(year: currentlySelectedYear,
                                                      month: currentlySelectedMonth,
                                                      day: Int(sender.titleLabel!.text!)!).formattedDate()
        
        /// Page from Core Data which accords to selected page date (Call for Core Data)
        if let selectedPage = Page.uploadPage(datedBy: dateOfCurrentlySelectedButton, excludeTodayDatedPage: true, in: context) {
            currentlyDisplayedPageAttributedText = selectedPage.attributedText!
            dateOfCurrentlySelectedPage = dateOfCurrentlySelectedButton
        }
        currentlySelectedButton = sender
    }
    
    @objc private func commentButtonIsPressed() {
        let commentPageViewController = CommentPageViewController()
        commentPageViewController.delegate = self
        commentPageViewController.pageDateUserCommentsOn = dateOfCurrentlySelectedPage!
        commentPageViewController.modalTransitionStyle = .crossDissolve
        commentPageViewController.modalPresentationStyle = .overCurrentContext
        present(commentPageViewController, animated: true, completion: nil)
    }
    
    
    // MARK: - Pickers settings
    
    internal func numberOfComponents(in pickerView: UIPickerView) -> Int {
        /// Hide selector lines in both pickers in order to make interface maximum laconic
        pickerView.subviews.forEach({
            $0.isHidden = $0.frame.height <= 1.0
        })
        return 1
    }
    
    internal func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == yearPicker {
            return yearsForPicker.count
        } else {
            return monthsForPicker.count
        }
    }
    
    internal func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var customizedPickerLabel = UILabel()
        if let pickerLabel = view as? UILabel { customizedPickerLabel = pickerLabel }
        
        let pickerFontSize = yearPicker.bounds.height * 0.167
        
        if pickerView == yearPicker {
            customizedPickerLabel.text = String.yearAsTextFor(year: yearsForPicker[row])
            customizedPickerLabel.font = UIFont.systemFont(ofSize: pickerFontSize)
            customizedPickerLabel.textColor = AppearenceSettings.yearPickerTextColor
        } else {
            customizedPickerLabel.adjustsFontSizeToFitWidth = true
            customizedPickerLabel.text = String.standaloneMonthNameForNumber(monthsForPicker[row])
            customizedPickerLabel.font = UIFont.boldSystemFont(ofSize: pickerFontSize)
            customizedPickerLabel.textColor = AppearenceSettings.monthPickerTextColor
        }
        customizedPickerLabel.textAlignment = .center
        return customizedPickerLabel
    }
    
    internal func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return pickerView.bounds.height * 0.182

    }
    
    internal func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == yearPicker {
            let previouslySelectedYear = currentlySelectedYear!
            /// Update currently picked year and months fot it
            currentlySelectedYear = yearsForPicker[row]
            /// Set correct months for month picker
            monthsForPicker = PickersDataModel.monthsFor(year: currentlySelectedYear, in: yearsWithMonthsForPickers)
            monthPicker.reloadAllComponents()
            
            /// If next year is picked, then first available month is picked, if previous year picked, then last available month picked
            currentlySelectedMonth = previouslySelectedYear > currentlySelectedYear ? monthsForPicker.last!: monthsForPicker.first!
            monthPicker.selectRow(monthsForPicker.index(of: currentlySelectedMonth)!, inComponent: 0, animated: true)
        } else {
            currentlySelectedMonth = monthsForPicker[row]
        }
    }
    
    
    // MARK: - Chronicle Model
    
    private var yearsWithMonthsForPickers: [PickersDataModel.YearWithMonths]!
    private var yearsForPicker: [Int]!
    private var monthsForPicker: [Int]!
    
    private func setDefaults() {
        
        /// Set last saved page to be displayed it there at least one page saved OR display the text that explains. (Call for Core Data)
        if let lastPage = Page.lastPage(excludeTodayDatedPage: true, in: context) {
            dateOfCurrentlySelectedPage = lastPage.date
            currentlyDisplayedPageAttributedText = lastPage.attributedText!
        } else {
            currentlyDisplayedPageAttributedText = TextsUsedInInterface.noPagesSavedNotification.formatWarningText(within: selectedPageTextView.bounds)
            commentButton.isEnabled = false
            commentButton.setTitleColor(AppearenceSettings.commentButtonDisabledTextColor, for: .normal)
        }
        
        currentlySelectedYear = PickersDataModel.defaultYear
        currentlySelectedMonth = PickersDataModel.defaultMonth
        
        yearsWithMonthsForPickers = PickersDataModel.yearsWithMonthsForPickers()
        yearsForPicker = PickersDataModel.yearsForPicker(in: yearsWithMonthsForPickers)
        monthsForPicker = PickersDataModel.monthsFor(year: currentlySelectedYear, in: yearsWithMonthsForPickers)
        
        yearPicker.selectRow(yearsForPicker.index(of: currentlySelectedYear)!, inComponent: 0, animated: true)
        monthPicker.selectRow(monthsForPicker.index(of: currentlySelectedMonth)!, inComponent: 0, animated: true)
    }
    
    private struct PickersDataModel {
        /// Tuple with dates of first and last pages for chronicle being saved in Core Data (Call for Core Data)
        private static let firstAndLastPagesDates = Page.firstAndLastPagesDates(excludeTodayDatedPage: true, in: context)
        private static let todayDateComponents = Date.todayDateFormatted().getDateComponents()
        
        private static let firstPageDateComponents = PickersDataModel.firstAndLastPagesDates.0?.getDateComponents()
        static let lastPageDateComponents = PickersDataModel.firstAndLastPagesDates.1?.getDateComponents()
        
        static let defaultYear = lastPageDateComponents?.year ?? todayDateComponents.year!
        static let defaultMonth = lastPageDateComponents?.month ?? todayDateComponents.month!
        
        
        static func yearsWithMonthsForPickers() -> [YearWithMonths] {
            if firstPageDateComponents != nil {
                var yearsWithMonths = [YearWithMonths]()
                
                let firstDateYear = firstPageDateComponents!.year!
                let firstDateMonth = firstPageDateComponents!.month!
                
                let lastDateYear = lastPageDateComponents!.year!
                let lastDateMonth = lastPageDateComponents!.month!
                
                for year in firstDateYear...lastDateYear {
                    if firstDateYear == lastDateYear {
                        yearsWithMonths.append(YearWithMonths(year: year, months: integersInRange(from: firstDateMonth, to: lastDateMonth)))
                    } else if year == firstDateYear {
                        yearsWithMonths.append(YearWithMonths(year: year, months: integersInRange(from: firstDateMonth, to: 12)))
                    } else if year == lastDateYear {
                        yearsWithMonths.append(YearWithMonths(year: year, months: integersInRange(from: 1, to: lastDateMonth)))
                    } else {
                        yearsWithMonths.append(YearWithMonths(year: year, months: integersInRange(from: 1, to: 12)))
                    }
                }
                return yearsWithMonths
            } else {
                return [YearWithMonths(year: defaultYear, months: [defaultMonth])]
            }
        }
        
        static func yearsForPicker(in yearsWithMonths: [YearWithMonths]) -> [Int] {
            var years = [Int]()
            for yearWithMonths in yearsWithMonths {
                years.append(yearWithMonths.year)
            }
            return years
        }
        
        static func monthsFor(year: Int, in yearsWithMonths: [YearWithMonths]) -> [Int] {
            var months = [Int]()
            for yearInMonth in yearsWithMonths {
                if yearInMonth.year == year {
                    months = yearInMonth.months
                }
            }
            return months
        }
        
        private static func integersInRange(from startNumber: Int, to endNumber: Int) -> [Int] {
            var integersInRange = [Int]()
            for number in startNumber...endNumber {
                integersInRange.append(number)
            }
            return integersInRange
        }
        
        struct YearWithMonths {
            var year: Int
            var months: [Int]
        }
    }
    
    private struct DaysCalendarModel {
        /// Returns all day button in content view which are already completely configured
        static func allDayButtonsIn(year: Int, month: Int, in superView: UIView) -> [UIButton] {
            var dayButtons = [UIButton]()
            let dayButtonsInfo = dayButtonsInfoFor(year: year, month: month)
            
            for dayButtonInfo in dayButtonsInfo {
                let dayButton = basicDayButton(for: dayButtonInfo, in: superView)
                
                /// Checks if there is a page for button date, and if there is set it to be enabled and set bright text color which means for user: button is selectable (Call for Core Data)
                if Page.uploadPage(datedBy: Date.from(year: year, month: month, day: dayButtonInfo.day), excludeTodayDatedPage: true, in: context) != nil {
                    dayButton.isEnabled = true
                    dayButton.setTitleColor(AppearenceSettings.dayButtonColorEnabled, for: .normal)
                    dayButton.addTarget(self, action: #selector(dayButtonIsPressed(sender:)), for: .touchUpInside)
                } else {
                    dayButton.isEnabled = false
                    dayButton.setTitleColor(AppearenceSettings.dayButtonColorDisabled, for: .normal)
                }
                
                dayButtons.append(dayButton)
            }
            return dayButtons
        }
        
        /// Returns the button whith all genereic setting which can be done based on super view and day button info
        private static func basicDayButton(for dayButtonInfo: DayButtonInfo, in superView: UIView) -> UIButton {
            let dayButton = UIButton(frame: LayoutSettings.frameOfDayButtonWith(buttonInfo: dayButtonInfo, in: superView))
            dayButton.setTitle("\(dayButtonInfo.day)", for: .normal)
            dayButton.titleLabel?.font = UIFont.systemFont(ofSize: dayButton.bounds.height / 2.5)
            dayButton.titleLabel?.textAlignment = .center
            dayButton.isOpaque = true
            dayButton.backgroundColor = AppearenceSettings.unselectedDayButtonBackgroundColor
            return dayButton
        }
        
        /// Returns all day buttons info for the month of the year.
        private static func dayButtonsInfoFor(year: Int, month: Int) -> [DayButtonInfo] {
            var dayButtonsInfo = [DayButtonInfo]()
            let firstDayDateComponents = Date.firstDayDate(year: year, month: month)!.getDateComponents()
            let lastDayDateComponents = Date.lastDayDate(year: year, month: month)!.getDateComponents()
            let firstDayDatePosition = firstDayDateComponents.weekday! - 1
            
            for day in firstDayDateComponents.day!...lastDayDateComponents.day! {
                dayButtonsInfo.append(DayButtonInfo(day: day, position: firstDayDatePosition - 1 + day))
            }
            
            return dayButtonsInfo
        }
        
        /// Day button info includes number of day and position in calendar view, where positions from 0 to 6 are for the first row, from 7 to 13 for the second, and so on.
        struct DayButtonInfo {
            var day: Int
            var position: Int
        }
    }
}
