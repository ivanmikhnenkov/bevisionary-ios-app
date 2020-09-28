//
//  TimeLineModel.swift
//  BeVisionary
//
//  Created by Ivan Mikhnenkov on 15.04.2018.
//  Copyright © 2018 Ivan Mikhnenkov. All rights reserved.
//

import UIKit

struct TimeLineModel {
    
    /// Returns default time line beginning date
    static func defaultTimeLineBeginningDate() -> Date {
        return Date.todayDateFormatted()
    }
    
    /// Returns default time line end date
    static func defaultTimeLineEndDate() -> Date {
        var defaultTimeLineEnd = defaultTimeLineBeginningDate()
        for _ in 1...4 {
            defaultTimeLineEnd = TimeLineModel.timePointDateAfter(date: defaultTimeLineEnd, of: .Month)
        }
        return defaultTimeLineEnd
    }
    
    
    // MARK: - Positioning
    
    /// Returns number of time point period parts of input type which are between today date and end date in bounds of input period
    static func timePointSegmentsBetweenTodayDateAndEndDateInPeriod(from beginning: Date, to end: Date, of timePointType: TimePointType) -> CGFloat {
        var partNeededToBePassed: CGFloat = 0
        
        let todayDate = Date.todayDateFormatted()
        let actualTimePointDates = timePointDatesInPeriod(from: beginning, to: end, timePointType: timePointType)
        for timePointDate in actualTimePointDates.reversed() {
            partNeededToBePassed += 1
            if todayDate == timePointDate {
                return partNeededToBePassed - 1
            } else if todayDate > timePointDate {
                return partNeededToBePassed - 2 + timePointSegmentPartToClosestTimePointDateFor(date: todayDate, timePointType: timePointType)
            }
        }
        return partNeededToBePassed - 1 + timePointSegmentPartToClosestTimePointDateFor(date: todayDate, timePointType: timePointType)
    }
    
    /// Returns minimal part of time point period of input type that should be passed by date to reach closest further time point date
    static func timePointSegmentPartToClosestTimePointDateFor(date: Date, timePointType: TimePointType) -> CGFloat {
        if isDateTimePoint(date, of: timePointType) {
            return 0
        } else {
            let previousTimePointDate = timePointDateBefore(date: date, of: timePointType)
            let nextTimePointDate = timePointDateAfter(date: date, of: timePointType)
            return CGFloat(nextTimePointDate.timeIntervalSince(date) / nextTimePointDate.timeIntervalSince(previousTimePointDate))
        }
    }
    
    
    // MARK: - Time point dates statics
    
    ///Returns the lowest timePointType with timePoints number which doesn't exceed the maximum number set for time line
    static func optimalTimePointsTypeForPeriod(from beginning: Date, to end: Date) -> TimePointType {
        var timePointType = TimePointType(rawValue: 0)!
        // Allows to avoid great number of iterations excluding counting first weekday dates where this type can't be actual by definition (6 weeks cannot be in 2 months)
        if beginning.changeDateByAddingMonths(2) < end {
            timePointType = TimePointType(rawValue: timePointType.rawValue + 1)!
            
            if beginning.changeDateByAddingMonths(4) < end {
                timePointType = TimePointType(rawValue: timePointType.rawValue + 1)!
            }
            
        }
        
        timePointTypeIncreasingLoop: while timePointsNumberInPeriod(from: beginning, to: end, timePointType: timePointType) > maximumActualTimePointsNumber {
            if TimePointType(rawValue: timePointType.rawValue + 1) != nil {
                timePointType = TimePointType(rawValue: timePointType.rawValue + 1)!
            } else {
                timePointType = .TwoYear
                break timePointTypeIncreasingLoop
            }
        }
        return timePointType
    }
    
    /// Returns time point names for all time point dates in input time period plus three time point dates for each side
    static func timePointNamesForFullTimeLineFillingWithGoalPeriod(from beginning: Date, to end: Date, of timePointType: TimePointType) -> [String] {
        let minusOneDate = timePointDateBefore(date: beginning, of: timePointType)
        let minusTwoDate = timePointDateBefore(date: minusOneDate, of: timePointType)
        let minusThreeDate = timePointDateBefore(date: minusTwoDate, of: timePointType)
        
        let plusOneDate = timePointDateAfter(date: end, of: timePointType)
        let plusTwoDate = timePointDateAfter(date: plusOneDate, of: timePointType)
        let plusThreeDate = timePointDateAfter(date: plusTwoDate, of: timePointType)
        
        var timePointsNames = [String]()
        let timePointDates = timePointDatesInPeriod(from: minusThreeDate, to: plusThreeDate, timePointType: timePointType)
        let areFullNameVersions = timePointDates.count <= 10 ? true: false
        for timePointDate in timePointDates {
            timePointsNames.append(timePointNameFor(timePointDate: timePointDate, of: timePointType, isFullName: areFullNameVersions))
        }
        return timePointsNames
    }
    
    /// Returns number of time points in certain period
    static func timePointsNumberInPeriod(from beginning: Date, to end: Date, timePointType: TimePointType) -> Int {
        return timePointDatesInPeriod(from: beginning, to: end, timePointType: timePointType).count
    }
    
    /// Returns time point names for in input period
    static func timePointNamesInPeriod(from beginning: Date, to end: Date, timePointType: TimePointType, isFullName: Bool) -> [String] {
        var timePointsNames = [String]()
        let timePointDates = timePointDatesInPeriod(from: beginning, to: end, timePointType: timePointType)
        
        for timePointDate in timePointDates {
            timePointsNames.append(timePointNameFor(timePointDate: timePointDate, of: timePointType, isFullName: isFullName))
        }
        return timePointsNames
    }
    
    /// BLASTAR SPACECRAFT: Returns all time point dates of certain type inside entered time period
    /// - Parameters:
    ///   - beginning: beginning of the time period
    ///   - end: end of the time period
    ///   - timePointType: which type of time point dates you want to get
    /// - Returns: time point dates
    private static func timePointDatesInPeriod(from beginning: Date, to end: Date, timePointType: TimePointType) -> [Date] {
        let beginningComponents = beginning.getDateComponents()
        let endComponents = end.getDateComponents()
        
        var timePointDates = [Date]()
        if timePointType == .FirstWeekday || timePointType == .UnevenWeekFirstWeekday {
            for year in beginningComponents.year!...endComponents.year! {
                for month in rangeOfMonthsForCertainYearInTimePeriod(from: beginningComponents, to: endComponents, year: year)! {
                    for day in rangeOfDaysForCertainMonthInTimePeriod(from: beginningComponents, to: endComponents, year: year, month: month) {
                        let date = Date.firstDayDate(year: year, month: month)?.changeDateByAddingDays(day - 1)
                        if isDateTimePoint(date!, of: timePointType) {
                            timePointDates.append(date!)
                        }
                    }
                }
            }
        } else {
            for year in beginningComponents.year!...endComponents.year! {
                if isAppropriate(year: year, for: timePointType) {
                    for month in rangeOfMonthsForCertainYearInTimePeriod(from: beginningComponents, to: endComponents, year: year)! {
                        if isAppropriate(month: month, for: timePointType) {
                            // If beginning year and month is currently being iterated then checks if beginning date day is one (is it timePointDate)
                            if year == beginningComponents.year && month == beginningComponents.month {
                                if beginningComponents.day == timePointDateDay {
                                    timePointDates.append(beginning)
                                }
                            }
                                // All others approptiate months with years are inside the period OR end date, so consequently always includes first day
                            else {
                                timePointDates.append(Date.firstDayDate(year: year, month: month)!)
                            }
                        }
                    }
                }
            }
        }
        return timePointDates
    }
    
    /// Returns range of months for particular year, which is limited by time period
    private static func rangeOfMonthsForCertainYearInTimePeriod(from beginningComponents: DateComponents, to endComponents: DateComponents, year: Int) -> CountableClosedRange<Int>? {
        
        if year >= beginningComponents.year! && year <= endComponents.year! {
            if beginningComponents.year! == endComponents.year! {
                return beginningComponents.month!...endComponents.month!
            } else {
                if year == beginningComponents.year! {
                    return beginningComponents.month!...12
                } else if year == endComponents.year! {
                    return 1...endComponents.month!
                } else {
                    return 1...12
                }
            }
        } else {
            return nil
        }
    }
    
    /// Returns range of days for particular year and month, which is limited by time period
    private static func rangeOfDaysForCertainMonthInTimePeriod(from beginningComponents: DateComponents, to endComponents: DateComponents, year: Int, month: Int) -> CountableClosedRange<Int> {
        let lastDayOfMonth = Date.lastDayDate(year: year, month: month)!.getDateComponents().day!
        
        let isBeginningInMonthAndYear = beginningComponents.year == year && beginningComponents.month == month
        let isEndInMonthAndYear = endComponents.year == year && endComponents.month == month
        
        if isBeginningInMonthAndYear && isEndInMonthAndYear {
            return beginningComponents.day!...endComponents.day!
        } else if isBeginningInMonthAndYear {
            return beginningComponents.day!...lastDayOfMonth
        } else if isEndInMonthAndYear {
            return 1...endComponents.day!
        } else {
            return 1...lastDayOfMonth
        }
    }
    
    
    // MARK: - Time point dates dynamics
    
    /// Returns next time point date of certain type after input date
    static func timePointDateAfter(date: Date, of timePointType: TimePointType) -> Date {
        let dateComponents = date.getDateComponents()
        switch timePointType {
        case .FirstWeekday :
            return date.changeDateByAddingDays(8 - dateComponents.weekday!)
        case .UnevenWeekFirstWeekday:
            if dateComponents.weekOfYear! % 2 == 1 {
                return date.changeDateByAddingDays(15 - dateComponents.weekday!)
            } else {
                return date.changeDateByAddingDays(8 - dateComponents.weekday!)
            }
        case .Month:
            let nextEndDateComponents = date.changeDateByAddingMonths(1).getDateComponents()
            return Date.firstDayDate(year: nextEndDateComponents.year!, month: nextEndDateComponents.month!)!
        case .ThreeMonth:
            let monthChangeNeeded = 3 - ((dateComponents.month! - 1) % 3)
            let nextEndDateComponents = date.changeDateByAddingMonths(monthChangeNeeded).getDateComponents()
            return Date.firstDayDate(year: nextEndDateComponents.year!, month: nextEndDateComponents.month!)!
        case .SixMonth:
            let monthChangeNeeded = 6 - ((dateComponents.month! - 1) % 6)
            let nextEndDateComponents = date.changeDateByAddingMonths(monthChangeNeeded).getDateComponents()
            return Date.firstDayDate(year: nextEndDateComponents.year!, month: nextEndDateComponents.month!)!
        case .Year:
            let nextEndDateComponents = date.changeDateByAddingYears(1).getDateComponents()
            return Date.firstDayDate(year: nextEndDateComponents.year!, month: 1)!
        case .TwoYear:
            let yearChangeNeeded = 2 - dateComponents.year! % 2
            let nextEndDateComponents = date.changeDateByAddingYears(yearChangeNeeded).getDateComponents()
            return Date.firstDayDate(year: nextEndDateComponents.year!, month: 1)!
        }
    }
    
    /// Returns previous time point date of certain type before input date
    static func timePointDateBefore(date: Date, of timePointType: TimePointType) -> Date {
        let dateComponents = date.getDateComponents()
        switch timePointType {
        case .FirstWeekday :
            return date.changeDateByAddingDays(-1 - (dateComponents.weekday! + 5) % 7)
        case .UnevenWeekFirstWeekday:
            if isDateTimePoint(date, of: .UnevenWeekFirstWeekday) {
                return date.changeDateByAddingDays(-14)
            } else if dateComponents.weekOfYear! % 2 == 0 {
                return date.changeDateByAddingDays(-7 - (dateComponents.weekday! - 1) % 7)
            } else {
                return date.changeDateByAddingDays(-(dateComponents.weekday! - 1) % 7)
            }
        case .Month:
            if dateComponents.day! == 1 {
                return date.changeDateByAddingMonths(-1)
            } else {
                return Date.firstDayDate(year: dateComponents.year!, month: dateComponents.month!)!
            }
        case .ThreeMonth:
            if dateComponents.day! != 1 && isAppropriate(month: dateComponents.month!, for: timePointType) {
                return Date.firstDayDate(year: dateComponents.year!, month: dateComponents.month!)!
            } else {
                let monthChangeNeeded = -(1 + (dateComponents.month! + 1) % 3)
                let previousEndDateComponents = date.changeDateByAddingMonths(monthChangeNeeded).getDateComponents()
                return Date.firstDayDate(year: previousEndDateComponents.year!, month: previousEndDateComponents.month!)!
            }
        case .SixMonth:
            if dateComponents.day! != 1 && isAppropriate(month: dateComponents.month!, for: timePointType) {
                return Date.firstDayDate(year: dateComponents.year!, month: dateComponents.month!)!
            } else {
                let monthChangeNeeded = -(1 + (dateComponents.month! + 4) % 6)
                let previousEndDateComponents = date.changeDateByAddingMonths(monthChangeNeeded).getDateComponents()
                return Date.firstDayDate(year: previousEndDateComponents.year!, month: previousEndDateComponents.month!)!
            }
        case .Year:
            if dateComponents.month! == 1 && dateComponents.day! == timePointDateDay {
                return date.changeDateByAddingYears(-1)
            } else {
                return Date.firstDayDate(year: dateComponents.year!, month: 1)!
            }
        case .TwoYear:
            if dateComponents.month! == 1 && dateComponents.day! == 1 {
                return date.changeDateByAddingYears(-2)
            } else {
                let yearChangeNeeded = -(dateComponents.year! % 2)
                let previousEndDateYear = date.changeDateByAddingYears(yearChangeNeeded).getDateComponents().year!
                return Date.firstDayDate(year: previousEndDateYear, month: 1)!
            }
        }
    }
    
    ///Returns timePointType based on which endDate increasing to next timePointDate should be done depending on current timePointsNumber and timePointsType
    static func timePointTypeForNextDate(currentType: TimePointType, timePointsNumber: Int) -> TimePointType {
        if timePointsNumber == maximumActualTimePointsNumber {
            return TimePointType(rawValue: currentType.rawValue + 1) ?? .TwoYear
        } else {
            return currentType
        }
    }
    
    ///Returns timePointType based on which endDate decreasing to previous timePointDate should be done depending on current timePointsNumber and timePointsType
    static func timePointTypeForPreviousDate(currentType: TimePointType, timePointsNumber: Int, beginning: Date, end: Date) -> TimePointType {
        if timePointsNumber == minimumActualTimePointsNumber {
            return TimePointType(rawValue: currentType.rawValue - 1) ?? .FirstWeekday
        } else {
            return optimalTimePointsTypeForPeriod(from: beginning, to: end)
        }
    }
    
    
    // MARK: - Checking belonging of date or its components to time point
    
    /// Checks if input date is time point date of input type
    private static func isDateTimePoint(_ date: Date, of timePointType: TimePointType) -> Bool {
        let dateComponents = date.getDateComponents()
        if timePointType == .FirstWeekday || timePointType == .UnevenWeekFirstWeekday {
            return isAppropriate(weekday: dateComponents.weekday!, weekOfYear: dateComponents.weekOfYear!, for: timePointType)
        } else {
            return (isAppropriate(year: dateComponents.year!, for: timePointType)
                && isAppropriate(month: dateComponents.month!, for: timePointType)
                && dateComponents.day! == timePointDateDay)
        }
    }
    
    /// Checks if weekday of certain week of year number is appropriate to be time point date of particular time point type
    private static func isAppropriate(weekday: Int, weekOfYear: Int, for timePointType: TimePointType) -> Bool {
        if timePointType == .FirstWeekday {
            return weekday == 1 ? true: false
        } else if timePointType == .UnevenWeekFirstWeekday {
            return (weekday == 1 && weekOfYear % 2 == 1) ? true: false
        } else {
            return false
        }
    }
    
    /// Checks if year is appropriate to be time point date of particular time point type
    private static func isAppropriate(year: Int, for timePointType: TimePointType) -> Bool {
        if timePointType == .TwoYear {
            return (year % 2 == 0 ? true : false)
        } else {
            return true
        }
    }
    
    /// Checks if month is appropriate to be time point date of particular time point type
    private static func isAppropriate(month: Int, for timePointType: TimePointType) -> Bool {
        return monthNumbersForTimePointType(timePointType).contains(month) ? true : false
    }
    
    private static let timePointDateDay = 1
    
    /// Returns array of month numbers which are appropriate for input time point type
    private static func monthNumbersForTimePointType(_ type: TimePointType) -> [Int] {
        switch type {
        case .FirstWeekday, .UnevenWeekFirstWeekday, .Month: return [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
        case .ThreeMonth: return [1, 4, 7, 10]
        case .SixMonth: return [1, 7]
        default: return [1]
        }
    }
    
    
    // MARK: - Customization
    
    /// Returns label text for today date indicator
    static func todayDateLabelText() -> String {
        let todayDateComponents = Date().getDateComponents()
        return String.dateAsTextFor(month: todayDateComponents.month!, day: todayDateComponents.day!, isLongVersion: true)
    }
    
    /// Returns label text for input time point date of time point type
    private static func timePointNameFor(timePointDate: Date, of timePointType: TimePointType, isFullName: Bool) -> String {
        if timePointType == .FirstWeekday || timePointType == .UnevenWeekFirstWeekday {
            let month = timePointDate.getDateComponents().month!
            let day = timePointDate.getDateComponents().day!
            return String.dateAsTextFor(month: month, day: day, isLongVersion:  isFullName)
        } else {
            let year = timePointDate.getDateComponents().year!
            let month = timePointDate.getDateComponents().month!
            return month == 1 ? String.yearAsTextFor(year: year) : String.standaloneMonthNameForNumber(month)
        }
    }
    
    
    // MARK: - Basic settings
    
    /// Types of time points which are used in time line
    enum TimePointType: Int {
        case FirstWeekday = 0
        case UnevenWeekFirstWeekday = 1
        case Month = 2
        case ThreeMonth = 3
        case SixMonth = 4
        case Year = 5
        case TwoYear = 6
    }
    
    static let minimumActualTimePointsNumber = 2
    static let maximumActualTimePointsNumber = 6
}

