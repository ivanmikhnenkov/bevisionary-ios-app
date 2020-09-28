//
//  ImpressionsDataModel.swift
//  BeVisionary
//
//  Created by Ivan Mikhnenkov on 15.04.2018.
//  Copyright © 2018 Ivan Mikhnenkov. All rights reserved.
//

import UIKit

struct ImpressionsDataModel {
    
    // Checks if there is a new day and if it is - creates new today records with empty strings, if it's not - update current records because of possible goals changes during the day. Update all the checking info
    static func defaultImpressionsStorageUpdating() {
        if isNewDay() == true || isNewDay() == nil {
            createNewTodayRecords()
            updateTodayDateWithCurrrentOne()
            updateTodaySessionLastTheme(with: defaultThemeInfo.name)
            setThemesIdentifiersWithNames(currentThemesIdentifiersWithNames())
            
            // Update already stored records if some goals were deleted, created or their names were changed. Update theme identifiers with names for future checking
        } else if isNewDay() == false {
            updateCurrentTodayRecords()
            updateTodaySessionLastThemeName()
            setThemesIdentifiersWithNames(currentThemesIdentifiersWithNames())
        }
    }
    
    // MARK: - Transform Info from Core Data to info which is required in Impressions Data Model
    
    private static func uploadThemesInfo() -> [ThemeInfo] {
        var themesInfo = [ThemeInfo]()
        themesInfo.append(defaultThemeInfo)
        // MARK: - Upload goals saved in Core Data if user is subscribed. In the other way user would get the default interface if it wasn't any goals saved
        if isUserCurrentlySubscribed {
            for goal in Goal.uploadAllGoals(in: context) {
                let customThemeInfo = ThemeInfo(name: goal.name!, identifier: goal.identifier!, number: goal.number, colorAsHex: goal.colorAsHex!)
                themesInfo.append(customThemeInfo)
            }
        }
        return themesInfo
    }
    
    // Themes names are values and identifiers are keys
    private static func currentThemesIdentifiersWithNames() -> [String: String] {
        
        var themesIdentifiersWithNames = [String: String]()
        
        for themeInfo in uploadThemesInfo() {
            themesIdentifiersWithNames.updateValue(themeInfo.name, forKey: themeInfo.identifier)
        }
        
        return themesIdentifiersWithNames
    }
    
    // Date Type which includes all the theme required information in the Impressions Interface
    private struct ThemeInfo {
        var name: String
        var identifier: String
        var number: Int16
        var colorAsHex: String
    }
    
    // Default theme value that is added
    private static let defaultThemeInfo = ThemeInfo(name: String.defaultThemeName, identifier: "Default Theme", number: 0, colorAsHex: UIColor.defaultThemeColor.toHex()!)
    
    
    // MARK: - Themes Identifiers with theme names are needed in order to check: was it new theme or old theme with updated name uploaded -> empty string OR stored text of previos theme name is prescribed respectively.
    
    // Is needed for checking: if there are themes which original goals names were changed. (Because their text in records shouldn't be deleted but rerecorded for new theme names of previously stored themes)
    private static func storedThemesIdentifiersWithNames() -> [String: String] {
        return storage.value(forKey: themesIdentifiersWithNamesKey) as? [String : String] ?? [String: String]()
    }
    
    private static func setThemesIdentifiersWithNames(_ themesIdentifiersWithNames: [String: String]) {
        storage.set(themesIdentifiersWithNames, forKey: themesIdentifiersWithNamesKey)
    }
    
    private static let themesIdentifiersWithNamesKey = "Themes Identifiers With Names"
    
    
    // MARK: - Buttons Building Info
    
    static func getButtonsBuildingInfoSortedByNumber() -> [ButtonBuildingInfo] {
        var buttonsBuildingInfo = [ButtonBuildingInfo]()
        
        for themeInfo in uploadThemesInfo() {
            let buttonBuildingInfo = ButtonBuildingInfo(name: themeInfo.name, number: Int(themeInfo.number), color: UIColor(hex: themeInfo.colorAsHex)!)
            buttonsBuildingInfo.append(buttonBuildingInfo)
        }
        return buttonsBuildingInfo.sorted { $0.number < $1.number }
    }
    
    struct ButtonBuildingInfo {
        var name: String
        var number: Int
        var color: UIColor
    }
    
    // MARK: Today Records - default updating and updating because of user interaction
    
    // Create records consisting of current themes as keys and empty strings as texts
    private static func createNewTodayRecords() {
        
        var newTodayRecords = [String: String]()
        
        for themeIdentifier in currentThemesIdentifiersWithNames().keys {
            let themeName = currentThemesIdentifiersWithNames()[themeIdentifier]!
            newTodayRecords.updateValue("", forKey: themeName)
        }
        updateTodayRecords(with: newTodayRecords)
    }
    
    // Update stored today records if some goals were created, deleted or their names were changed during today
    private static func updateCurrentTodayRecords() {
        
        var actualTodayRecords = getTodayRecords()
        
        // Delete theme names with their texts from today records if goals which are themes origins were deleted
        for storedIdentifier in storedThemesIdentifiersWithNames().keys {
            if currentThemesIdentifiersWithNames()[storedIdentifier] == nil {
                let nameOfDeletedTheme = storedThemesIdentifiersWithNames()[storedIdentifier]
                actualTodayRecords.removeValue(forKey: nameOfDeletedTheme!)
            }
        }
        
        // Resave value for renamed themes and create empty strings for new themes
        for currentThemeIdentifier in currentThemesIdentifiersWithNames().keys {
            
            // Check if there is stored theme name for current theme identifier (else new theme was created)
            if let storedThemeName = storedThemesIdentifiersWithNames()[currentThemeIdentifier] {
                let currentThemeNameOfStoredTheme = currentThemesIdentifiersWithNames()[currentThemeIdentifier]
                
                // Check if the name of the stored theme was changed
                if storedThemeName != currentThemeNameOfStoredTheme {
                    // Resave text to new theme name and delete old theme name with its text from today records
                    let storedTextForNewThemeNameToSave = getTodayRecords()[storedThemeName]
                    actualTodayRecords.updateValue(storedTextForNewThemeNameToSave!, forKey: currentThemeNameOfStoredTheme!)
                    actualTodayRecords.removeValue(forKey: storedThemeName)
                }
            } else {
                // There is new theme and new record with empty text is created for it
                let newCurrentThemeName = currentThemesIdentifiersWithNames()[currentThemeIdentifier]
                actualTodayRecords.updateValue("", forKey: newCurrentThemeName!)
            }
        }
        
        updateTodayRecords(with: actualTodayRecords)
    }
    
    // User interaction part
    static func getTodayRecords() -> [String: String] {
        return storage.value(forKey: ImpressionsDataModel.todayRecordsKey) as? [String: String] ?? [String: String]()
    }
    
    static func updateTodayRecords(with records: [String: String]) {
        storage.set(records, forKey: ImpressionsDataModel.todayRecordsKey)
    }
    
    private static let todayRecordsKey = "Today Records"
    
    // MARK: - Page saving
    
    // Updates main page dated with current date in Core Data (create, change or delete)
    static func updateTodayPageInCoreDateAccordingToTodayRecords() {
        if let compiledPage = compilePageIfPossible() {
            Page.createOrUpdatePage(containing: compiledPage, datedBy: storedTodayDate() ?? Date.todayDateFormatted(), excludeTodayDatedPage: false, in: context)
        } else {
            // If page exists - user saved it previously today, but now deleted all today impressions (because trial of compilling returned nil), so previously saved page also should be deleted
            Page.deletePage(datedBy: storedTodayDate() ?? Date.todayDateFormatted(), in: context)
        }
    }
    
    // Compiles main page based on today impressions: returns NSAttributedString if there is meaningful text, else nil.
    private static func compilePageIfPossible() -> NSAttributedString? {
        var page = NSAttributedString(string: "")
        
        let currentRecords = getTodayRecords()
        
        for buttonInfo in getButtonsBuildingInfoSortedByNumber() {
            if currentRecords[buttonInfo.name]!.containsMeaningfulText() {
                page = page + buttonInfo.name.formatHeader(color: buttonInfo.color) + currentRecords[buttonInfo.name]!.formatMainBody()
            }
        }
        
        if !page.string.isEmpty {
            return page
        } else {
            return nil
        }
    }
    
    
    // MARK: - Today session last theme implementation provision
    
    // Stores last theme that was picked by user during current day in order to open theme that was picked last time before Impression Interface has disappeared
    static func todaySessionLastTheme() -> String {
        return (storage.value(forKey: todaySessionLastThemeNameKey) as! String?) ?? defaultThemeInfo.name
    }
    
    // Update last theme today (is used to set default if its new day and to save before Impressions Interface disappears)
    static func updateTodaySessionLastTheme(with theme: String) {
        storage.set(theme, forKey: todaySessionLastThemeNameKey)
    }
    
    // Check if last sessions theme origin goal name was changed and if true: update its name in storage,
    // Check if last session theme origin goal was deleted and if true: update today session last theme name with default theme name
    private static func updateTodaySessionLastThemeName() {
        
        let savedTodaySessionLastThemeName = todaySessionLastTheme()
        
        for identifier in storedThemesIdentifiersWithNames().keys {
            if savedTodaySessionLastThemeName == storedThemesIdentifiersWithNames()[identifier] {
                let identifierOfTodaySessionsLastTheme = identifier
                
                // Two checks described higher accordingly
                if let currentTodaySessionLastThemeName = currentThemesIdentifiersWithNames()[identifierOfTodaySessionsLastTheme] {
                    updateTodaySessionLastTheme(with: currentTodaySessionLastThemeName)
                } else {
                    updateTodaySessionLastTheme(with: defaultThemeInfo.name)
                }
            }
        }
    }
    
    // Key of today session last theme value in storage
    private static let todaySessionLastThemeNameKey = "Today Session Last Theme Name"
    
    
    // MARK: - Current day checker with provision
    
    // Check if today date is saved in storage (nil if not), and if it is - is this date actually current one (return false) OR outdated (return true)
    private static func isNewDay() -> Bool? {
        if let storedTodayDate = storedTodayDate() {
            if storedTodayDate == Date.todayDateFormatted() {
                return false
            } else {
                return true
            }
        } else {
            return nil
        }
    }
    
    // Return a date which is stored as the today date in the storage
    private static func storedTodayDate() -> Date? {
        return storage.value(forKey: todayDateKey) as? Date
    }
    
    // Save actual current date in the storage
    private static func updateTodayDateWithCurrrentOne() {
        storage.set(Date.todayDateFormatted(), forKey: todayDateKey)
    }
    
    private static let todayDateKey = "Today Date"
    
    private static var storage = UserDefaults()
    
    // Temporary method for testing of the interface
    static func cleanStorage() {
        storage.removeObject(forKey: todayRecordsKey)
        storage.removeObject(forKey: todayDateKey)
        storage.removeObject(forKey: todaySessionLastThemeNameKey)
        storage.removeObject(forKey: themesIdentifiersWithNamesKey)
    }
    
    static func cleanTodayDate() {
        storage.removeObject(forKey: todayDateKey)
    }
}
