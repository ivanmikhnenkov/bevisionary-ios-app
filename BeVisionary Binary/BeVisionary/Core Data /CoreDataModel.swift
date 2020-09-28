//
//  CoreDataModel.swift
//  BeVisionary
//
//  Created by Ivan Mikhnenkov on 15.04.2018.
//  Copyright © 2018 Ivan Mikhnenkov. All rights reserved.
//

import UIKit
import CoreData

class Goal: NSManagedObject {
    
    /// Creates new goal and returns it or returns nil if creation wasn't executed
    static func createNewGoal(name: String,
                              color: UIColor,
                              from beginning: Date,
                              to end: Date, number: Int,
                              identifier: String,
                              in context: NSManagedObjectContext) -> Goal? {
        
        if goalDurationIsEnough(from: beginning, to: end) && isGoalNameFree(name, beingCheckedGoalidentifier: identifier, in: context) {
            if #available(iOS 10.0, *) {
                let newGoal = Goal(context: context)
                newGoal.name = name
                newGoal.colorAsHex = color.toHex()
                newGoal.beginning = beginning
                newGoal.end = end
                newGoal.number = Int16(number)
                newGoal.identifier = identifier
                saveAll(in: context)
                return newGoal
            } else {
                // Fallback on earlier versions
                let goalEntityDescription = NSEntityDescription.entity(forEntityName: "Goal", in: CoreDataStack.managedObjectContext)
                let newGoal = Goal(entity: goalEntityDescription!, insertInto: CoreDataStack.managedObjectContext)
                newGoal.name = name
                newGoal.colorAsHex = color.toHex()
                newGoal.beginning = beginning
                newGoal.end = end
                newGoal.number = Int16(number)
                newGoal.identifier = identifier
                saveAll(in: context)
                return newGoal
            }
        } else {
            return nil
        }
    }
    
    /// Update existing goal and returns it or returns nil if updating is impossible
    private func updateGoal(newName: String,
                            newColor: UIColor,
                            newEndDate: Date,
                            newNumber: Int,
                            in context: NSManagedObjectContext) -> Goal? {
        if Goal.goalDurationIsEnough(from: self.beginning! as Date, to: newEndDate) && Goal.isGoalNameFree(newName, beingCheckedGoalidentifier: self.identifier!, in: context) {
            self.name = newName
            self.colorAsHex = newColor.toHex()
            self.end = newEndDate
            self.number = Int16(newNumber)
            saveAll(in: context)
            return self
        } else {
            return nil
        }
    }
    
    
    func deleteGoal(in context: NSManagedObjectContext) {
        
        /// Decereases goal number by 1 of goals which numbers are more than of the goal being deleted
        var goalNumber = self.number + 1
        var goal = Goal.uploadGoalWith(number: goalNumber, in: context)
        
        while goal != nil {
            goal!.updateGoalNumber(with: goalNumber - 1, in: context)
            goalNumber += 1
            goal = Goal.uploadGoalWith(number: goalNumber, in: context)
        }
        
        context.delete(self)
        saveAll(in: context)
    }
    
    static func deleteGoalWith(name: String, in context: NSManagedObjectContext) {
        let request: NSFetchRequest<Goal> = Goal.fetchRequest()
        let predicate = NSPredicate(format: "name = %@", name)
        request.predicate = predicate
        if let goal = (try? context.fetch(request))?.first {
            goal.deleteGoal(in: context)
            saveAll(in: context)
        }
    }
    
    static func deleteGoalWith(identifier: String, in context: NSManagedObjectContext) {
        let request: NSFetchRequest<Goal> = Goal.fetchRequest()
        let predicate = NSPredicate(format: "identifier = %@", identifier)
        request.predicate = predicate
        if let goal = (try? context.fetch(request))?.first {
            goal.deleteGoal(in: context)
            saveAll(in: context)
        }
    }
    
    static func deleteGoalsWithEndedTimePeriods() {
        let goals = Goal.uploadAllGoals(in: context)
        for goal in goals {
            if goal.end! < Date.todayDateFormatted() {
                goal.deleteGoal(in: context)
            }
        }
        saveAll(in: context)
    }
    
    // Fetch all goals sorted by goals numbers ascending
    static func uploadAllGoals(in context: NSManagedObjectContext) -> [Goal] {
        let request: NSFetchRequest<Goal> = Goal.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "number", ascending: true, selector: #selector(NSDate.compare(_:)))]
        
        let goals = try? context.fetch(request)
        return goals ?? [Goal]()
    }
    
    static func uploadGoalWith(name: String, in context: NSManagedObjectContext) -> Goal? {
        let request: NSFetchRequest<Goal> = Goal.fetchRequest()
        let particularNamePredicator = NSPredicate(format: "name = %@", name)
        request.predicate = particularNamePredicator
        let goals = try? context.fetch(request)
        return goals?.first
    }
    
    static func uploadGoalWith(identifier: String, in context: NSManagedObjectContext) -> Goal? {
        let request: NSFetchRequest<Goal> = Goal.fetchRequest()
        let particulalIdentifierPredicator = NSPredicate(format: "identifier = %@", identifier)
        request.predicate = particulalIdentifierPredicator
        if let goals = try? context.fetch(request) {
            return goals.first
        } else {
            return nil
        }
    }
    
    static func uploadGoalWith(number: Int16, in context: NSManagedObjectContext) -> Goal? {
        let request: NSFetchRequest<Goal> = Goal.fetchRequest()
        let particulalNumberPredicator = NSPredicate(format: "number == %i", number)
        request.predicate = particulalNumberPredicator
        let goals = try? context.fetch(request)
        return goals?.first
    }
    
    func updateGoalNameAndColor(newName: String, newColor: UIColor, in context: NSManagedObjectContext) -> Goal? {
        if Goal.isGoalNameFree(newName, beingCheckedGoalidentifier: self.identifier!, in: context) {
            self.name = newName
            self.colorAsHex = newColor.toHex()!
            saveAll(in: context)
            return self
        } else {
            return nil
        }
    }
    
    func updateGoalEndDate(newEndDate: Date, in context: NSManagedObjectContext) -> Goal? {
        if Goal.goalDurationIsEnough(from: self.beginning! as Date, to: newEndDate) && newEndDate >= self.beginning! as Date {
            return self.updateGoal(newName: self.name!,
                                   newColor: UIColor(hex: self.colorAsHex!)!,
                                   newEndDate: newEndDate,
                                   newNumber: Int(self.number),
                                   in: context)
            
        } else {
            return nil
        }
    }
    
    func updateGoalNumber(with newNumber: Int16, in context: NSManagedObjectContext) {
        self.number = newNumber
        saveAll(in: context)
    }
    
    // Delete all goals
    static func deleteAllGoals(in context: NSManagedObjectContext) {
        for goal in Goal.uploadAllGoals(in: context) {
            goal.deleteGoal(in: context)
        }
        
        saveAll(in: context)
    }
    
    static func newGoalNumber(in context: NSManagedObjectContext) -> Int {
        return uploadAllGoals(in: context).count + 1
    }
    
    // Check if the potential goal name is original
    static func isGoalNameFree(_ name: String, beingCheckedGoalidentifier: String?, in context: NSManagedObjectContext) -> Bool {
        // Check if it exists merely one goal with name that is being checked.
        for goal in Goal.uploadAllGoals(in: context) {
            // Identifier is checked in order to avoid comparing new goal name with its old name (in the case of entering the same name while goal updating)
            if name == goal.name && (beingCheckedGoalidentifier ?? "") != goal.identifier! {
                return false
            }
        }
        
        return true
    }
    
    // Check if there is min gap (7 days) between beginning and end dates
    static func goalDurationIsEnough(from beginning: Date, to end: Date) -> Bool {
        if end.timeIntervalSince(beginning) >= TimeInterval.oneDay * 7 {
            return true
        } else {
            return false
        }
    }
}

class Page: NSManagedObject {
    
    /// Uploads and return all the pages sorted by date ascending
    static func uploadAllPagesSortedByDateAscending(excludeTodayDatedPage: Bool, in context: NSManagedObjectContext) -> [Page]? {
        let request: NSFetchRequest<Page> = Page.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true, selector: #selector(NSDate.compare(_:)))]
        
        /// Exclude today dated page when fetching all pages from core data storage, because it is never needed in Chronicle
        if excludeTodayDatedPage {
            let todayDate = Date.todayDateFormatted() as NSDate
            let excludeTodayDatedPagePreicate = NSPredicate(format: "date < %@", todayDate)
            request.predicate = excludeTodayDatedPagePreicate
        }
        
        let allPagesSorted = try? context.fetch(request)
        if allPagesSorted?.isEmpty == false {
            return allPagesSorted
        } else {
            return nil
        }
    }
    
    static func firstAndLastPagesDates(excludeTodayDatedPage: Bool, in context: NSManagedObjectContext) -> (Date?, Date?) {
        let allPagesSorted = uploadAllPagesSortedByDateAscending(excludeTodayDatedPage: excludeTodayDatedPage,in: context)
        return (allPagesSorted?.first?.date, allPagesSorted?.last?.date)
    }
    
    static func firstPage(excludeTodayDatedPage: Bool, in context: NSManagedObjectContext) -> Page? {
        if let allPagesSorted = uploadAllPagesSortedByDateAscending(excludeTodayDatedPage: excludeTodayDatedPage, in: context) {
            return allPagesSorted.first!
        } else {
            return nil
        }
    }
    
    static func lastPage(excludeTodayDatedPage: Bool, in context: NSManagedObjectContext) -> Page? {
        if let allPagesSorted = uploadAllPagesSortedByDateAscending(excludeTodayDatedPage: excludeTodayDatedPage, in: context) {
            return allPagesSorted.last!
        } else {
            return nil
        }
    }
    
    
    // Returns the page marked with particular date (There is the only page for particular date in Life Board)
    static func uploadPage(datedBy date: Date, excludeTodayDatedPage: Bool, in context: NSManagedObjectContext) -> Page? {
        /// Check if entered day is today date and if true return nil becuase today dated page is not shown in chronicle
        if excludeTodayDatedPage {
            if date == Date.todayDateFormatted() {
                return nil
            } else {
                let request: NSFetchRequest<Page> = Page.fetchRequest()
                request.predicate = NSPredicate(format: "date = %@", date as NSDate)
                let onePageArray = try? context.fetch(request)
                return onePageArray?.first ?? nil
            }
        } else {
            let request: NSFetchRequest<Page> = Page.fetchRequest()
            request.predicate = NSPredicate(format: "date = %@", date as NSDate)
            if let onePageArray = try? context.fetch(request) {
                return onePageArray.first
            } else {
                return nil
            }
        }
    }
    
    
    // Create new page if no page for input date is saved OR update attributed text of existing page
    static func createOrUpdatePage(containing pageText: NSAttributedString, datedBy date: Date, excludeTodayDatedPage: Bool, in context: NSManagedObjectContext) {
        if let existingPage = uploadPage(datedBy: date, excludeTodayDatedPage: excludeTodayDatedPage, in: context) {
            existingPage.attributedText = pageText
        } else {
            
            if #available(iOS 10.0, *) {
                let newPage = Page(context: context)
                newPage.date = date
                newPage.attributedText = pageText
            } else {
                // Fallback on earlier versions
                let pageEntityDescription = NSEntityDescription.entity(forEntityName: "Page", in: CoreDataStack.managedObjectContext)
                let newPage = Page(entity: pageEntityDescription!, insertInto: CoreDataStack.managedObjectContext)
                newPage.date = date
                newPage.attributedText = pageText
            }
        }
        saveAll(in: context)
    }
    
    // Delete page for input date if it exists
    static func deletePage(datedBy date: Date, in context: NSManagedObjectContext) {
        if let pageToDelete = uploadPage(datedBy: date, excludeTodayDatedPage: false, in: context) {
            context.delete(pageToDelete)
            saveAll(in: context)
        }
    }
    
    // MARK: Temporary code
    static func deleteAllPages(in context: NSManagedObjectContext) {
        let request: NSFetchRequest<Page> = Page.fetchRequest()
        if let pages = try? context.fetch(request) {
            for page in pages {
                context.delete(page)
            }
        }
        saveAll(in: context)
    }
}

// Save all the changes within the context
private func saveAll(in context: NSManagedObjectContext) {
    do {
        try context.save()
    } catch {
        print("Error when trying to save context")
    }
}

let context: NSManagedObjectContext! = CoreDataStack.managedObjectContext //AppDelegate.context


