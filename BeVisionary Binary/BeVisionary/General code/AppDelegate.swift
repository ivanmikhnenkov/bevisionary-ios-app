//
//  AppDelegate.swift
//  BeVisionary
//
//  Created by Ivan Mikhnenkov on 14.04.2018.
//  Copyright © 2018 Ivan Mikhnenkov. All rights reserved.
//

import UIKit
import CoreData
import StoreKit


/// Influence the themes in Impressions interface being fetched and offer subscription UI setup
var isUserCurrentlySubscribed: Bool = true {
    didSet {
        // Offer subscription UI building preparation starts here in order to improve the User experience
        if isUserCurrentlySubscribed == false {
            if offerSubscriptionVC == nil {
                offerSubscriptionVC = OfferSubscriptionViewController()
                IAPHandler.shared.delegate = offerSubscriptionVC!
            }
            IAPHandler.shared.retrieveProductRequest()
        } else {
            offerSubscriptionVC?.unblockGoalsInterface()
            impressionsVC?.updateInterfaceAccordingToCurrentImpressionsStorage()
        }
    }
}

// View Controller which blocks the goals VC content and offers subscription when user is not subscribed
// Is delegate of IAPHandler.shared, because retrieves text for title of the button which offers subscription
var offerSubscriptionVC: OfferSubscriptionViewController?

//View Controller which should be updated immideately when subscription is bought, so al the goals set in GoalsVC and saved in Core Data are handled and displayed
var impressionsVC: ImpressionsViewController?

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Attach an observer to the payment queue
        SKPaymentQueue.default().add(IAPHandler.shared)
        
        // Checks the receipt every time the user opens the app
        isUserCurrentlySubscribed = IAPHandler.shared.isUserCurrentlySubscribedBasedOnReceipt()
        
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Saves in the case when app terminate and willResignActive state is missed
        defaultSavingBeforeImpressionsInterfaceIsClosed()
        
        CoreDataStack.saveContext()
        
        // Remove an observer
        SKPaymentQueue.default().remove(IAPHandler.shared)
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Save data when appis closed when user is currently in the Impressions interface, so willDisappear there is not called
        defaultSavingBeforeImpressionsInterfaceIsClosed()
    }

   
    private func defaultSavingBeforeImpressionsInterfaceIsClosed() {
        ((window?.rootViewController as? CustomTabBarController)?.viewControllers?[1] as? ImpressionsViewController)?.defaultPreparationBeforeClosingTheInterface()
    }
}

