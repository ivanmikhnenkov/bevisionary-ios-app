//
//  AllGoalsTableViewController.swift
//  BeVisionary
//
//  Created by Ivan Mikhnenkov on 15.04.2018.
//  Copyright © 2018 Ivan Mikhnenkov. All rights reserved.
//

import UIKit

class GoalTableViewCell: UITableViewCell  {
    @IBOutlet weak var nameLabel: UILabel!
}

class AllGoalsTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Disable edit button when no goals are saved in core data
        editButton.isEnabled = isEditButtonEnabled()
        // Set appropriate text for back button item
        backButton.title = TextUsedInInterface.backButtonTitle
        editButton.title = TextUsedInInterface.editButtonTitleStandard
        self.navigationItem.title = TextUsedInInterface.navigationItemTitle
        
        // Remove empty cell view below cell displaying info
        tableView.tableFooterView = UIView()
        
        // Set color for middle title (Your goals)
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: AppearenceSettings.systemEnabledTitleColor]
        
        // Set navigation bar background color
        self.navigationController?.navigationBar.barTintColor = AppearenceSettings.systemBackgroundColor
        
    }
    
    private func isEditButtonEnabled() -> Bool {
        if goalsCellInfo.first!.color == GoalsCellsModel.startNewGoalCreationCellInfo.color {
            return false
        } else {
            return true
        }
    }
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    // Signal when edit button is pressed so starts or fnish editing behavior
    @IBAction func edit(_ sender: UIBarButtonItem) {
        
        tableView.isEditing = !tableView.isEditing
        
        switch tableView.isEditing {
        case true:
            editButton.title = TextUsedInInterface.editButtonTitleWhenEditing
            // Remove 'set new goal cell' if it was when editing has been started
            if goalsCellInfo.last?.color == GoalsCellsModel.startNewGoalCreationCellInfo.color {
                goalsCellInfo.removeLast()
                tableView.reloadData()
            }
        case false:
            editButton.title = TextUsedInInterface.editButtonTitleStandard
            // Add 'set new goal cell' if there are less than 5 goals when editing has been done
            if goalsCellInfo.count < GoalsCellsModel.maximumNumberOfGoals {
                goalsCellInfo.append(GoalsCellsModel.startNewGoalCreationCellInfo)
                tableView.reloadData()
            }
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return goalsCellInfo.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "GoalCell", for: indexPath) as! GoalTableViewCell
        let goalCellInfo = goalsCellInfo[indexPath.row]
        
        // Check if it is turn of '+' that initialize new goal creation process and if true - set appropriate parameters for this cell
        if goalsCellInfo[indexPath.row].color == GoalsCellsModel.startNewGoalCreationCellInfo.color {
            cell.nameLabel.text = "+"
            cell.nameLabel.textColor = goalCellInfo.color
            cell.nameLabel?.font = UIFont.appFontOfSize(cell.bounds.height/2)
            cell.backgroundColor = AppearenceSettings.systemBackgroundColor
            return cell
        }
        
        cell.nameLabel?.text = goalCellInfo.name
        cell.nameLabel?.font = UIFont.appFontOfSize(cell.bounds.height/4)
        cell.nameLabel?.textColor = AppearenceSettings.goalNameColor
        cell.backgroundColor = goalCellInfo.color.withAlphaComponent(AppearenceSettings.goalCellBackgroundAlpha)
        cell.nameLabel.adjustsFontSizeToFitWidth = true
        cell.nameLabel.minimumScaleFactor = 0.7
        return cell
    }
    
    // MARK: - Customization and supporting editing behavior
    
    // Row height depending on tableView height
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.view.bounds.height / AppearenceSettings.tableViewToCellRowHeightRatio
    }
    
    // Support goals deleting in editing behavior
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let deletedGoalName = goalsCellInfo[indexPath.row].name
            goalsCellInfo.remove(at: indexPath.row)
            GoalsCellsModel.deleteGoalWithName(deletedGoalName)
            GoalsCellsModel.updateGoalsNumbersBasingOn(goalsCellInfo: goalsCellInfo)
            
            tableView.reloadData()
        }
    }
    
    // Support goals rearranging in editing behavior
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedObject = goalsCellInfo[sourceIndexPath.row]
        goalsCellInfo.remove(at: sourceIndexPath.row)
        goalsCellInfo.insert(movedObject, at: destinationIndexPath.row)
        GoalsCellsModel.updateGoalsNumbersBasingOn(goalsCellInfo: goalsCellInfo)
    }
    
    // Define customization parameters
    private struct AppearenceSettings {
        static let systemEnabledTitleColor = UIColor.systemEnabledTitleColor
        static let systemBackgroundColor = UIColor.systemBackgroundColor
        static let goalNameColor = UIColor.white
        static let goalCellBackgroundAlpha: CGFloat = 0.7
        static let tableViewToCellRowHeightRatio: CGFloat = 5
    }
    
    private struct TextUsedInInterface {
        static let backButtonTitle = LocalizedString("AllGoalsTVC; backButtonTitle")
        static let navigationItemTitle = LocalizedString("AllGoalsTVC; navigationItemTitle")
        static let editButtonTitleStandard = LocalizedString("AllGoalsTVC; editButtonTitleStandard")
        static let editButtonTitleWhenEditing = LocalizedString("AllGoalsTVC; editButtonTitleWhenEditing")
    }
    
    // MARK: - GoalsTVC data model and data interaction provision
    
    // Cells info for allGoalsList. Can update only goals number when is set.
    var goalsCellInfo: [GoalsCellsModel.CellInfo] = GoalsCellsModel.getCurrentGoalsCellInfo()
    
    // Provide methods and data type for processing input goals from core date to be appropriately displayed and updating core data back in its turn
    struct GoalsCellsModel {
        
        static let maximumNumberOfGoals = 5
        
        static let startNewGoalCreationCellInfo = CellInfo(name: "+", color: AppearenceSettings.systemEnabledTitleColor)
        
        static func getCurrentGoalsCellInfo() -> [CellInfo] {
            var allGoalsCellInfo = [CellInfo]()
            let currentGoals = Goal.uploadAllGoals(in: context)
            
            for goal in currentGoals {
                let goalCellInfo = CellInfo(name: goal.name!, color: UIColor(hex: goal.colorAsHex!)!)
                allGoalsCellInfo.append(goalCellInfo)
                
            }
            
            // Append '+' button to start new goal setting process if there are less than 5 goals
            if allGoalsCellInfo.count < maximumNumberOfGoals {
                allGoalsCellInfo.append(startNewGoalCreationCellInfo)
            }
            
            return allGoalsCellInfo
        }
        
        static func updateGoalsNumbersBasingOn(goalsCellInfo: [CellInfo]) {
            for (goalCellIndex, goalCellInfo) in goalsCellInfo.enumerated() {
                if let goal = Goal.uploadGoalWith(name: goalCellInfo.name, in: context) {
                    goal.updateGoalNumber(with: Int16(goalCellIndex + 1), in: context)
                }
            }
        }
        
        static func deleteGoalWithName(_ name: String) {
            Goal.deleteGoalWith(name: name, in: context)
        }
        
        // Goal info which is needed by allGoalsList
        struct CellInfo {
            var name: String
            var color: UIColor
        }
    }
}
