//
//  GoalsViewController.swift
//  BeVisionary
//
//  Created by Ivan Mikhnenkov on 15.04.2018.
//  Copyright © 2018 Ivan Mikhnenkov. All rights reserved.
//

import UIKit

class GoalsViewController: UIViewController, UIPopoverPresentationControllerDelegate {
    
    // MARK: - Offer Subscription UI
    
    // Setups offer subscription functionality by adding offerSubscriptionVC as child view controller to goalsVC, with boundaries as all content view
    private func buildOfferSubscriptionUIIfNeeded() {
        if isUserCurrentlySubscribed == false {
            if offerSubscriptionVC != nil {
                offerSubscriptionVC!.view.frame = contentView.bounds
                self.addChildViewController(offerSubscriptionVC!)
                contentView.addSubview(offerSubscriptionVC!.view)
                offerSubscriptionVC!.didMove(toParentViewController: self)
            } else {
                isUserCurrentlySubscribed = false
            }
        }
    }
    
    // Removes offer subscription view controller which was previously added as child view controller and blocked all the functionality of goalsVC offering user to subscribe
    func removeOfferSubscriptionViewController() {
        func makeOfferSubscriptionUIClear() {
            offerSubscriptionVC?.view.alpha = 0.0
        }
        
        UIView.animate(withDuration: 0.5, animations: makeOfferSubscriptionUIClear, completion: { _ in
            offerSubscriptionVC?.willMove(toParentViewController: nil)
            offerSubscriptionVC?.view.removeFromSuperview()
            offerSubscriptionVC?.removeFromParentViewController()
        })
        offerSubscriptionVC = nil
        
        if currentlyDisplayedGoal == nil {
            displayGoalsTableViewButtonIndicator()
        }
    }
    
    /// Displays goals table view button indicator as fading in and out image view. It's finished by function
    private func displayGoalsTableViewButtonIndicator() {
        let goalsTableViewIndicatorImageView = UIImageView(image: #imageLiteral(resourceName: "goalsTableViewButtonIndicator"))
        let goalsButtonIndicatorWidth = contentView.bounds.width * 0.06
        let goalsButtonIndicatorHeight = contentView.bounds.width * 0.06

        goalsTableViewIndicatorImageView.frame = CGRect(x: goalsTableViewButton.frame.midX - goalsButtonIndicatorWidth * 0.25, y: goalsTableViewButton.frame.minY + goalsTableViewButton.frame.height * 0.75, width: goalsButtonIndicatorWidth, height: goalsButtonIndicatorHeight)
        contentView.addSubview(goalsTableViewIndicatorImageView)

        var isFadingIn: Bool = false {
            didSet {
                // This checker stops endless cycle when editModeImageView is removed from superview
                if contentView.subviews.contains(goalsTableViewIndicatorImageView) {
                    if isFadingIn {
                        goalsTableViewIndicatorImageView.fadeIn(1, delay: 0.5, completion: { _ in
                            isFadingIn = false
                        })
                    } else {
                        goalsTableViewIndicatorImageView.fadeOut(1, delay: 0.5) { _ in
                            isFadingIn = true
                        }
                    }
                }
            }
        }
        
        goalsTableViewIndicatorImageView.alpha = 0
        goalsTableViewIndicatorImageView.fadeIn(1, delay: 0) { _ in
            isFadingIn = false
        }
        
    }
    
    // MARK: - Interface setup
    
    // Frame of view where interface can be built (except tab bar)
    private var contentViewFrame: CGRect!
    
    @IBOutlet weak var contentView: UIView!
    private func configureContentView() {
        contentView.frame = CGRect(x: 0,
                                   y: contentViewFrame.minY,
                                   width: contentViewFrame.width,
                                   height: contentViewFrame.height)
    }
    
    private func setupGestureRecognizers() {
        goalEndDateChangingPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(goalEndDateChangingPanning(_:)))
        finishGoalEndDateChangingGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(finishGoalEndDateChanging))
        goalEndDateChangingPanGestureRecognizer.isEnabled = false
        finishGoalEndDateChangingGestureRecognizer.isEnabled = false
        if contentView != nil {
            contentView.addGestureRecognizer(goalEndDateChangingPanGestureRecognizer)
            contentView.addGestureRecognizer(finishGoalEndDateChangingGestureRecognizer)
        }
    }
    
    @IBOutlet weak var timeLineView: TimeLineView!
    private func configureTimeLineViewLayout() {
        timeLineView.frame = CGRect(x: contentView.bounds.minX,
                                    y: contentView.bounds.height * 0.7,
                                    width: contentView.bounds.width * 1.004,
                                    height: contentView.bounds.height * 0.1)
        timeLineView.transform = timeLineView.transform.rotated(by: -CGFloat(5.0.degreesToRadians))
        timeLineView.center.x += timeLineView.bounds.width * 0.0007
        
        // Makes main time line view path smooth after rotation (This setting can be generalized to whole app in info.plist but there is no need and it influences the speed)
        timeLineView.layer.allowsEdgeAntialiasing = true
    }
    
    @IBOutlet weak var goalsTableViewButton: UIButton!
    private func configureGoalsTableViewButton() {
        goalsTableViewButton.frame = CGRect(x: contentView.bounds.width * 0.8,
                                            y: contentView.bounds.height * 0.8,
                                            width: contentView.bounds.width * 0.12,
                                            height: contentView.bounds.height * 0.12)
        
        goalsTableViewButton.setImage(#imageLiteral(resourceName: "allGoalsButtonImage").withRenderingMode(.alwaysOriginal), for: .normal)
    }
    
    
    // MARK: - Setup all the initial paremeters of the Goals interface
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contentViewFrame = CGRect.contentViewFrameOf(viewController: self)
        configureContentView()
        configureGoalsTableViewButton()
        configureTimeLineViewLayout()
        setFirstNumberGoalAsCurrentlyDisplayedIfPossible()
        setupGestureRecognizers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        buildOfferSubscriptionUIIfNeeded()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        disactivateGoalEndDateEditingMode()
    }

    
    // MARK: - Time Period Editing Mode Controller
    
    /// Starts goal end date editing mode, when user can edit goal end date by dragging gesture
    func activateGoalEndDateEditingMode() {
        startGoalEndEditingModeAnimating()
        editGoalTapGestureRecognizer.isEnabled = false
        finishGoalEndDateChangingGestureRecognizer.isEnabled = true
        goalEndDateChangingPanGestureRecognizer.isEnabled = true
    }
    
    /// Finishes goal end date editing mode, when user can edit goal end date by dragging gesture
    private func disactivateGoalEndDateEditingMode() {
        stopAllImageViewsAnimating()
        editGoalTapGestureRecognizer.isEnabled = true
        finishGoalEndDateChangingGestureRecognizer.isEnabled = false
        goalEndDateChangingPanGestureRecognizer.isEnabled = false
    }
    
    /// Starts goal end editing mode animation
    private func startGoalEndEditingModeAnimating() {
        let editModeImageView = UIImageView(image: #imageLiteral(resourceName: "GoalEditingModeImage"))
        editModeImageView.frame = CGRect(x: contentView.bounds.maxX * 0.35,
                                         y: contentView.bounds.maxY * 0.8,
                                         width: contentView.bounds.maxX * 0.35,
                                         height: contentView.bounds.maxY * 0.14)
        self.contentView.addSubview(editModeImageView)
        
        var isFadingIn: Bool = false {
            didSet {
                // This checker stops endless cycle when editModeImageView is removed from superview
                if contentView.subviews.contains(editModeImageView) {
                    if isFadingIn {
                        editModeImageView.fadeIn(1, delay: 0.5, completion: { _ in
                            isFadingIn = false
                        })
                    } else {
                        editModeImageView.fadeOut(1, delay: 0.5) { _ in
                            isFadingIn = true
                        }
                    }
                }
            }
        }
        
        editModeImageView.alpha = 0
        editModeImageView.fadeIn(1, delay: 0) { _ in
            isFadingIn = false
        }
    }
    
    /// Stops goal edit mode animation and goals button indicator animation
    private func stopAllImageViewsAnimating() {
        for subview in self.contentView.subviews {
            if subview is UIImageView {
                subview.removeFromSuperview()
            }
        }
    }
    
    
    private var goalEndDateChangingPanGestureRecognizer: UIPanGestureRecognizer!
    @objc private func goalEndDateChangingPanning(_ gesture: UIPanGestureRecognizer) {
        var valueOfTranslationByX: CGFloat = 0 {
            didSet {
                if valueOfTranslationByX >= 75 {
                    decreaseGoalEnd()
                    gesture.setTranslation(CGPoint(x: 0, y: 0), in: contentView)
                } else if valueOfTranslationByX <= -75 {
                    increaseGoalEnd()
                    gesture.setTranslation(CGPoint(x: 0, y: 0), in: contentView)
                }
            }
        }
        valueOfTranslationByX = gesture.translation(in: contentView).x
    }
    
    private var finishGoalEndDateChangingGestureRecognizer: UITapGestureRecognizer!
    @objc private func finishGoalEndDateChanging() {
        disactivateGoalEndDateEditingMode()
    }
    
    
    // MARK: - Time Line Controller
    
    /// First date which is displayed on timeLine in the bounds its central half (accords to goalView bounds if goal displayed)
    private var timeLineBeginning: Date!
    
    /// Last date which is displayed on timeLine in the bounds of its central half (accords to goalView bounds if goal displayed)
    private var timeLineEnd: Date! {
        didSet {
            _ = currentlyDisplayedGoal?.updateGoalEndDate(newEndDate: timeLineEnd, in: context)
            
            timeLineView.allTimePointsNames = allTimePointsNames
            timeLineView.todayDateNeedsTimePointPeriodsToPassToReachEnd = TimeLineModel.timePointSegmentsBetweenTodayDateAndEndDateInPeriod(from: timeLineBeginning, to: timeLineEnd, of: currentTimePointType)
            
            timeLineView.indicatorLabelText = TimeLineModel.todayDateLabelText()
            
            timeLineView.timePointPeriodPartFromBeginningToClosestTimePointDate = TimeLineModel.timePointSegmentPartToClosestTimePointDateFor(date: timeLineBeginning, timePointType: currentTimePointType)
        }
    }
    
    /// Type of time points which are displayed on time line
    private var currentTimePointType: TimeLineModel.TimePointType!
    
    /// Increases goal end date according to rules of descrete date changing in Time Line Model
    private func increaseGoalEnd() {
        if !(currentTimePointType == .TwoYear && timeLineActualTimePointsNumber == TimeLineModel.maximumActualTimePointsNumber) {
            
            currentTimePointType = TimeLineModel.timePointTypeForNextDate(currentType: currentTimePointType, timePointsNumber: timeLineActualTimePointsNumber)
            
            
            timeLineEnd = TimeLineModel.timePointDateAfter(date: timeLineEnd, of: currentTimePointType)
            
        }
    }
    
    /// Decreases goal end date according to rules of descrete date changing in Time Line Model
    private func decreaseGoalEnd() {
        if !(currentTimePointType == .FirstWeekday && timeLineActualTimePointsNumber == TimeLineModel.minimumActualTimePointsNumber) {
            let decreasedTimeLineEndDate = TimeLineModel.timePointDateBefore(date: timeLineEnd, of: currentTimePointType)
            
            if decreasedTimeLineEndDate >= Date.todayDateFormatted() {
                currentTimePointType = TimeLineModel.timePointTypeForPreviousDate(currentType: currentTimePointType, timePointsNumber: timeLineActualTimePointsNumber, beginning: timeLineBeginning, end: decreasedTimeLineEndDate)
                timeLineEnd = decreasedTimeLineEndDate
            }
        }
    }
    
    /// Time points number in the period between timeLineBeginning and timeLineEnd
    private var timeLineActualTimePointsNumber: Int {
        return TimeLineModel.timePointsNumberInPeriod(from: timeLineBeginning, to: timeLineEnd, timePointType: currentTimePointType)
    }
    
    /// Returns an array of time point date names for complete visual time line filling
    private var allTimePointsNames: [String] {
        return TimeLineModel.timePointNamesForFullTimeLineFillingWithGoalPeriod(from: timeLineBeginning, to: timeLineEnd, of: currentTimePointType)
    }
    
    /// Updates time line parameters based on currently displayed goal
    private func updateTimeLineParameters() {
        var beginning: Date!
        var end: Date!
        if currentlyDisplayedGoal?.identifier != nil {
            beginning = currentlyDisplayedGoal!.beginning! as Date
            end = currentlyDisplayedGoal!.end! as Date
        } else {
            beginning = TimeLineModel.defaultTimeLineBeginningDate()
            end = TimeLineModel.defaultTimeLineEndDate()
        }
        currentTimePointType = TimeLineModel.optimalTimePointsTypeForPeriod(from: beginning, to: end)
        timeLineBeginning = beginning
        timeLineEnd = end
    }
    
    
    // MARK: - Currently displayed goal controller
    
    ///Goal which is currently displayed (nothing is displayed if nil set).
    var currentlyDisplayedGoal: Goal? {
        didSet {
            if currentlyDisplayedGoal?.identifier != nil {
                displayGoalViewFor(goal: currentlyDisplayedGoal!)
            } else {
                removeCurrentlyDisplayedGoalView()
            }
            updateTimeLineParameters()
        }
    }
    
    ///Display goal view for particular goal
    /// - Parameter goal: Goal which should be displayed
    private func displayGoalViewFor(goal: Goal) {
        removeCurrentlyDisplayedGoalView()
        
        // Create and add new goal view
        let goalView = GoalView(frame: CGRect(x: contentView.bounds.width * 0.25, y: 0, width: contentView.bounds.width * 0.5, height: contentView.bounds.height * 0.75))
        
        goalView.color = UIColor(hex: goal.colorAsHex!)
        goalView.name = goal.name
        
        contentView.addSubview(goalView)
        contentView.bringSubview(toFront: timeLineView)
        
        editGoalTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(presentGoalEditingOptionsList))
        goalView.addGestureRecognizer(editGoalTapGestureRecognizer)
    }
    
    /// Removes previosly displayed goal view if it exists
    private func removeCurrentlyDisplayedGoalView() {
        for subview in contentView.subviews {
            if subview is GoalView {
                subview.removeFromSuperview()
            }
        }
    }

    private var editGoalTapGestureRecognizer = UITapGestureRecognizer()
    
    @objc private func presentGoalEditingOptionsList() {
        presentGoalEditingOptionsViewController()
    }
    
    /// Present view controller for initialize goal updating
    /// - Parameter identifierOfGoalIfUpdating: Set it to nil if you want to create new goal, and set existing goal identifier of goal you want to update.
    private func presentGoalEditingOptionsViewController() {
        let goalEditingOptionsViewController = GoalEditingOptionsViewController()
        goalEditingOptionsViewController.modalPresentationStyle = .overCurrentContext
        goalEditingOptionsViewController.modalTransitionStyle = .crossDissolve
        present(goalEditingOptionsViewController, animated: true, completion: nil)
    }

    ///If first goal exists then, sets it as the displayed goal
    private func setFirstNumberGoalAsCurrentlyDisplayedIfPossible() {
        if let firstNumberGoal = Goal.uploadGoalWith(number: 1, in: context) {
            currentlyDisplayedGoal = firstNumberGoal
        } else {
            currentlyDisplayedGoal = nil
        }
    }
    
    private func setFirstNumberGoalToBeCurrentlyDisplayedIfPreviouslyDisplayedOneWasDeleted() {
        if currentlyDisplayedGoal?.identifier == nil {
            // There is no first number goal identifier, which means the current goal was deleted
            // So, now app should try to set new first number goal
            // In fact, if it wasn't current goal at all this method can't be called cause another one to start creating new goal would be called
            setFirstNumberGoalAsCurrentlyDisplayedIfPossible()
        }
    }
    
    
    // MARK: - New Goal Creation Provisioning
    
    /// Present view controller for setting goal name and color.
    /// - Parameter identifierOfGoalIfUpdating: set it to nil if you want to create a new goal, and set existing goal identifier of goal you want to update.
    func presentGoalNameAndColorSettingVC(goalIdentiferIfUpdating: String?) {
        let goalNameAndColorSettingVC = GoalNameAndColorSettingViewController()
        goalNameAndColorSettingVC.identifierOfGoalBeingUpdated = goalIdentiferIfUpdating
        goalNameAndColorSettingVC.modalPresentationStyle = .overCurrentContext
        goalNameAndColorSettingVC.isModalInPopover = true
        goalNameAndColorSettingVC.modalTransitionStyle = .crossDissolve
        present(goalNameAndColorSettingVC, animated: true, completion: nil)
    }
    
    
    // MARK: - Navigation
    
    /// Sets size for popover that is preferred on iPads screens
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        disactivateGoalEndDateEditingMode()
        if segue.identifier == "ShowGoalsTableView" {
            segue.destination.preferredContentSize = CGSize(width: contentViewFrame.width * 0.6, height: contentViewFrame.height * 0.7)
            if let popoverVC = segue.destination.popoverPresentationController {
                popoverVC.delegate = self
            }
        }
    }
    
    /// Sets currently displayed goal to nil if no goals exist when user dismiss popover by tapping on screen outside popover bounds
    internal func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        setFirstNumberGoalToBeCurrentlyDisplayedIfPreviouslyDisplayedOneWasDeleted()
    }
    
    /// Dismisses goals table view without any settings
    @IBAction func closeGoalsTableView(from segue: UIStoryboardSegue) {
        setFirstNumberGoalToBeCurrentlyDisplayedIfPreviouslyDisplayedOneWasDeleted()
    }
    
    /// Checks for "+" cell OR existing goal cell being selected that are mutually excluding, and starts one of two different processes.
    @IBAction func startNewGoalCreationOrDisplaySelectedOne(from segue: UIStoryboardSegue) {
        if let goalsTVC = segue.source as? AllGoalsTableViewController {
            
            // Number of cell that was picked and reasons unwinding
            let selectedCellNumber = goalsTVC.tableView.indexPathForSelectedRow!.row
            let selectedGoalCellInfo = goalsTVC.goalsCellInfo[selectedCellNumber]
            
            // Check if cell "+" in order to create new goal was pressed
            if selectedGoalCellInfo.color == AllGoalsTableViewController.GoalsCellsModel.startNewGoalCreationCellInfo.color {
                dismiss(animated: true, completion: nil)
                presentGoalNameAndColorSettingVC(goalIdentiferIfUpdating: nil)
            }
            
            // Check if it exists goal for chosen cell number and if it is - set this goal to be currently displayed
            if let selectedGoal = Goal.uploadGoalWith(number: Int16(selectedCellNumber) + 1, in: context) {
                // Set picked goal cell as currently displayed goal
                currentlyDisplayedGoal = selectedGoal
            }
        }
    }
}
