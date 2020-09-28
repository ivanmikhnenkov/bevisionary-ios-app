//
//  IAPHandler.swift
//  BeVisionary
//
//  Created by Ivan Mikhnenkov on 24.04.2018.
//  Copyright © 2018 Ivan Mikhnenkov. All rights reserved.
//


import Foundation
import StoreKit
import SystemConfiguration

class IAPHandler: NSObject, SKPaymentTransactionObserver, SKRequestDelegate, SKProductsRequestDelegate {
    
    static let shared = IAPHandler()
    
    // MARK: - Products retrieving and appropriate UI transmitting to delegate
    
    private let subscriptionProductID = "com.ivanmikhnenkov.BeVisionary.fullaccess.onemonth"
    private var productRequest = SKProductsRequest()
    private var subscriptionProduct: SKProduct?
    
    /// Retrieves product request with correct product ID
    func retrieveProductRequest() {
        productRequest = SKProductsRequest(productIdentifiers: [subscriptionProductID])
        productRequest.delegate = self
        productRequest.start()
    }
    
    // Gets the response with subscription product if successfull, saves the product, generates and sends the subscription button title to delegate
    internal func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        
        subscriptionProduct = response.products.first
        
        // If correct product was received - send the information about its name and update mode according to receipt
        if subscriptionProduct?.productIdentifier == subscriptionProductID {
            
            delegate?.pricePerMonthPhrase = subscriptionProduct!.localizedPrice() + LocalizedString("OfferSubscriptionVC; perMonthText")
            delegate?.subscriptionName = subscriptionProduct!.localizedTitle
            
            // Updates offer subscription text in order to provide delegate with the appropriate subscriprion button title
            updateOfferedSubscriptionMode()
        } else {
            // If no expected product was found set no product was found to delegate
            delegate?.offeredSubscriptionMode = .noProductFound
        }
    }
    
    
    // MARK: - Payment and restore requests
    
    /// Tries to make payment request, handles the probable problems and display them
    func requestPayment() {
        if SKPaymentQueue.canMakePayments() {
            if subscriptionProduct?.productIdentifier == subscriptionProductID {
                let payment = SKMutablePayment(product: subscriptionProduct!)
                SKPaymentQueue.default().add(payment)
            } else {
                if isConnectedToNetwork() {
                    showAlert(title: AlertNotifications.cannotStartTransactionTitle,
                              message: AlertNotifications.noProductFoundWithInternetMessage)
                    // Tries to fix the problem with the no product being found
                    retrieveProductRequest()
                } else {
                    showAlert(title: AlertNotifications.cannotStartTransactionTitle,
                              message: AlertNotifications.noProductFoundNoInternetMessage)
                }
            }
        } else {
            showAlert(title: AlertNotifications.cannotStartTransactionTitle, message: AlertNotifications.userCannotMakePurchase)
        }
    }
    
    /// Tries to restore the subscription, the result is handled by methods-recievers
    func restoreSubscription() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    

    // MARK: - Observing transaction queue
    internal func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {            
            switch transaction.transactionState {
            case.purchased:
                if transaction.payment.productIdentifier == subscriptionProductID {
                    isUserCurrentlySubscribed = isUserCurrentlySubscribedBasedOnReceipt()
                    SKPaymentQueue.default().finishTransaction(transaction)
                }
                break
                
            case.restored:
                isUserCurrentlySubscribed = isUserCurrentlySubscribedBasedOnReceipt()
                SKPaymentQueue.default().finishTransaction(transaction)
                break
                
            case.failed:
                SKPaymentQueue.default().finishTransaction(transaction)
                
                if isConnectedToNetwork() == false {
                    showAlert(title: nil,
                              message: AlertNotifications.noInternetConnection)
                } else {
                    retrieveProductRequest()
                }
                break
                
            default: break
            }
        }
    }
    
    
    // MARK: - Restoration process handling
    
    /// Handles the fail when subscription restoring
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        if isConnectedToNetwork() == false {
            showAlert(title: nil,
                      message: AlertNotifications.noInternetConnection)
        } else {
            showAlert(title: AlertNotifications.subscriptionWasNotRestoredTitle, message: AlertNotifications.unknownErrorWhenRestoringSubscriptionMessage)
        }
    }
    
    /// Show alert when subscription was restored for better UX
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        if isUserCurrentlySubscribed {
            showAlert(title: nil, message: AlertNotifications.subscriptionWasRestored)
        } else {
            showAlert(title: AlertNotifications.subscriptionWasNotRestoredTitle, message: AlertNotifications.noValidSubscriptionToRestoreMessage)
        }
    }
    
    
    // MARK: - Receipt checking methods
    
    private var isReceiptValid: Bool!
    private var currentIAPReceipts = [ParsedInAppPurchaseReceipt]()
    private let receiptRefresher = ReceiptRefresher()

    /// Checks if user is currently subscribed or not according to app receipt and returns true or false accordingly
    func isUserCurrentlySubscribedBasedOnReceipt() -> Bool {
        
        let receiptValidator = ReceiptValidator()
        switch receiptValidator.validateReceipt() {
        
        case .success(let parsedReceipt):
            isReceiptValid = true
            let sortedIAPReceiptByExpirationDateAscending = parsedReceipt.inAppPurchaseReceipts?.sorted(by: { (receipt1: ParsedInAppPurchaseReceipt, receipt2: ParsedInAppPurchaseReceipt) -> Bool in
                return receipt1.subscriptionExpirationDate! < receipt2.subscriptionExpirationDate!
            })
            
            if sortedIAPReceiptByExpirationDateAscending != nil {
                self.currentIAPReceipts = sortedIAPReceiptByExpirationDateAscending!
            }
            
            if let lastIAPReceipt = self.currentIAPReceipts.last {
                if lastIAPReceipt.subscriptionExpirationDate! > Date.getCurrentLocalDateApp() {
                    return true
                } else {
                    return false
                }
            }
            return false
            
        case .error(_):
            isReceiptValid = false
            if !ReceiptRefresher.shared.wasReceiptRefreshed {
                ReceiptRefresher.shared.refreshReceipt()
            }
            return false
        }
    }

    
    class ReceiptRefresher: SKReceiptRefreshRequest, SKRequestDelegate {
        static let shared = ReceiptRefresher()
        
        var wasReceiptRefreshed = false
        
        func refreshReceipt() {
            let receiptRefreshRequest = SKReceiptRefreshRequest()
            receiptRefreshRequest.delegate = self
            receiptRefreshRequest.start()
        }
        
        func requestDidFinish(_ request: SKRequest) {
            isUserCurrentlySubscribed = IAPHandler.shared.isUserCurrentlySubscribedBasedOnReceipt()
            self.wasReceiptRefreshed = true
        }
    }
    
    /// Sets correct offer subsription mode based on receipt checking
    private func updateOfferedSubscriptionMode() {
        if subscriptionProduct != nil {
            for iAPReceipt in currentIAPReceipts {
                if iAPReceipt.isFreeTrial == true || iAPReceipt.isIntroductoryPrice == true {
                    delegate?.offeredSubscriptionMode = .standardPrice
                    return
                }
            }
            delegate?.offeredSubscriptionMode = .introductoryPrice
        } else {
            delegate?.offeredSubscriptionMode = .noProductFound
        }
    }
    
    // MARK: - Handling events methods
    
    /// Checks if the device is currently connected to network
    private func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
    
    /// Makes a currently visible view controller to show alert
    private func showAlert(title: String?, message: String?) {
        if let visibleVC = UIApplication.shared.keyWindow?.visibleViewController {
            let alertVC = UIAlertController(title: title ?? nil, message: message ?? nil, preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            visibleVC.present(alertVC, animated: true)
        }
    }
    
    /// Catalogue of user notifications displaying in alerts when handling transactions events
    private struct AlertNotifications {
        static let noInternetConnection = LocalizedString("IAPHandler; noInternetConnection")
        static let cannotStartTransactionTitle = LocalizedString("IAPHandler; cannotStartTransactionTitle")
        static let noProductFoundNoInternetMessage = LocalizedString("IAPHandler; noProductFoundNoInternetMessage")
        static let noProductFoundWithInternetMessage = LocalizedString("IAPHandler; noProductFoundWithInternetMessage")
        static let userCannotMakePurchase = LocalizedString("IAPHandler; userCannotMakePurchase")
        
        static let subscriptionWasRestored = LocalizedString("IAPHandler; subscriptionWasRestored")
        static let subscriptionWasNotRestoredTitle = LocalizedString("IAPHandler; subscriptionWasNotRestoredTitle")
        static let noValidSubscriptionToRestoreMessage = LocalizedString("IAPHandler; noValidSubscriptionToRestoreMessage")
        static let unknownErrorWhenRestoringSubscriptionMessage = LocalizedString("IAPHandler; unknownErrorWhenRestoringSubscriptionMessage")
    }
    
    /// Delegate which displays offer subscription UI
    var delegate: IAPHandlerDelegate?
    
    enum OfferSubscriptionMode {
        case standardPrice, introductoryPrice, noProductFound
    }
}

protocol IAPHandlerDelegate {
    var subscriptionName: String { get set }
    var pricePerMonthPhrase: String { get set }
    var offeredSubscriptionMode: IAPHandler.OfferSubscriptionMode {get set}
}
