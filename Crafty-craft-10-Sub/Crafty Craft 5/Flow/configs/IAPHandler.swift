
import Foundation
import StoreKit
import Pushwoosh
import Adjust

protocol IAPManagerProtocol: AnyObject {
    func infoAlert(title: String, message: String)
    func goToTheApp()
    func failed()
}

protocol IAPManagerSkinPurchaseProtocol: AnyObject {
    func skinCreatorDidUnlocked()
}

protocol IAPManagerAddonPurchaseProtocol: AnyObject {
    func addonCreatorDidUnlocked()
}

protocol IAPManagerContentProtocol: AnyObject {
    func contnetDidUnlocked()
}


class IAPManager: NSObject, SKPaymentTransactionObserver, SKProductsRequestDelegate {
    
    
    var contentSubIsVaild: Bool?
    var skinCreatorSubIsValid: Bool? {
        didSet {
            if let skinCreatorSubIsValid, skinCreatorSubIsValid {
                skinProductDelegate?.skinCreatorDidUnlocked()
            }
        }
    }
    var addonCreatorIsValid: Bool? {
        didSet {
            if let addonCreatorIsValid, addonCreatorIsValid {
                addonProductDelegate?.addonCreatorDidUnlocked()
            }
        }
    }

    
    static let shared = IAPManager()
    
    weak var transactionsDelegate: IAPManagerProtocol?
    weak var skinProductDelegate: IAPManagerSkinPurchaseProtocol?
    weak var addonProductDelegate: IAPManagerAddonPurchaseProtocol?
    weak var contentProductDelegate: IAPManagerContentProtocol?
    
    public var  localizablePrice = "$4.99"
    public var productBuy : PremiumMainControllerStyle = .mainProduct
    public var productBought: [PremiumMainControllerStyle] = []
    
    private var inMain: SKProduct?
    private var inUnlockContent: SKProduct?
    private var inUnlockFunc: SKProduct?
    private var inUnlockOther: SKProduct?
    
    private var mainProduct = Configurations_REFACTOR.mainSubscriptionID
    private var unlockContentProduct = Configurations_REFACTOR.unlockContentSubscriptionID
    private var unlockFuncProduct = Configurations_REFACTOR.unlockFuncSubscriptionID
    private var unlockOther = Configurations_REFACTOR.unlockerThreeSubscriptionID
    
    private var secretKey = Configurations_REFACTOR.subscriptionSharedSecret
    
    private var isRestoreTransaction = true
    private var restoringTransactionProductId: [String] = []
    
    private let iapError      = NSLocalizedString("error_iap", comment: "")
    private let prodIDError   = NSLocalizedString("inval_prod_id", comment: "")
    private let restoreError  = NSLocalizedString("faledRestore", comment: "")
    private let purchaseError = NSLocalizedString("notPurchases", comment: "")
    
    public func loadProductsFunc() {
        SKPaymentQueue.default().add(self)
        let request = SKProductsRequest(productIdentifiers:[mainProduct,unlockContentProduct,unlockFuncProduct,unlockOther])
        request.delegate = self
        request.start()
    }
    
    
    public func doPurchase() {
        switch productBuy {
        case .mainProduct:
            processPurchase(for: inMain, with: Configurations_REFACTOR.mainSubscriptionID)
        case .unlockContentProduct:
            processPurchase(for: inUnlockContent, with: Configurations_REFACTOR.unlockContentSubscriptionID)
        case .unlockFuncProduct:
            processPurchase(for: inUnlockFunc, with: Configurations_REFACTOR.unlockFuncSubscriptionID)
        case .unlockOther:
            processPurchase(for: inUnlockOther, with: Configurations_REFACTOR.unlockerThreeSubscriptionID)
        }
    }
    
    public func localizedPrice() -> String {
        guard NetworkStatusMonitor.shared.isNetworkAvailable else { return localizablePrice }
        switch productBuy {
          case .mainProduct:
            processProductPrice(for: inMain)
          case .unlockContentProduct:
            processProductPrice(for: inUnlockContent)
          case .unlockFuncProduct:
            processProductPrice(for: inUnlockFunc)
        case .unlockOther:
            processProductPrice(for: inUnlockOther)
        }
        return localizablePrice
    }
    
    private func getCurrentProduct() -> SKProduct? {
        switch productBuy {
        case .mainProduct:
            return self.inMain
        case .unlockContentProduct:
            return self.inUnlockContent
        case .unlockFuncProduct:
            return self.inUnlockFunc
        case .unlockOther:
            return self.inUnlockOther
        }
    }
    
    private func processPurchase(for product: SKProduct?, with configurationId: String) {
        guard let product = product else {
            self.transactionsDelegate?.infoAlert(title: iapError, message: prodIDError)
            return
        }
        if product.productIdentifier.isEmpty {
            
            self.transactionsDelegate?.infoAlert(title: iapError, message: prodIDError)
        } else if product.productIdentifier == configurationId {
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(payment)
        }
    }
    
    
    public func doRestore() {
        guard isRestoreTransaction else { return }
        SKPaymentQueue.default().restoreCompletedTransactions()
        isRestoreTransaction = false
    }
    
    private func completeRestoredStatusFunc(restoreProductID : String, transaction: SKPaymentTransaction) {
        if restoringTransactionProductId.contains(restoreProductID) { return }
        restoringTransactionProductId.append(restoreProductID)
        
        validateSubscriptionWithCompletionHandler(productIdentifier: restoreProductID) { [weak self] result in
            guard let self = self else {
                return
            }
            
            self.restoringTransactionProductId.removeAll {$0 == restoreProductID}
            if result {
                
                if let mainProd = self.inMain, restoreProductID == mainProd.productIdentifier {
                    self.transactionsDelegate?.goToTheApp()
                    self.trackSubscription(transaction: transaction, product: mainProd)
                    
                }
                else if let firstProd = self.inUnlockFunc, restoreProductID == firstProd.productIdentifier {
                    self.trackSubscription(transaction: transaction, product: firstProd)
                    
                }
                else if let unlockContent = self.inUnlockContent, restoreProductID == unlockContent.productIdentifier {
                    self.trackSubscription(transaction: transaction, product: unlockContent)
                    
                }
            } else {
                self.transactionsDelegate?.infoAlert(title: self.restoreError, message: self.purchaseError)
            }
        }
    }
    
    
    public func completeAllTransactionsFunc() {
        let transactions = SKPaymentQueue.default().transactions
        for transaction in transactions {
            let transactionState = transaction.transactionState
            if transactionState == .purchased || transactionState == .restored {
                SKPaymentQueue.default().finishTransaction(transaction)
            }
        }
    }
    
    // Ваша собственная функция для проверки подписки.
    public func validateSubscriptionWithCompletionHandler(productIdentifier: String,_ resultExamination: @escaping (Bool) -> Void) {
        SKReceiptRefreshRequest().start()
        
        guard let receiptUrl = Bundle.main.appStoreReceiptURL,
              let receiptData = try? Data(contentsOf: receiptUrl) else {
            pushwooshSetSubTag(value: false)
            resultExamination(false)
            return
        }
        
        let receiptDataString = receiptData.base64EncodedString(options: [])
        
        let jsonRequestBody: [String: Any] = [
            "receipt-data": receiptDataString,
            "password": self.secretKey,
            "exclude-old-transactions": true
        ]
        
        let requestData: Data
        do {
            requestData = try JSONSerialization.data(withJSONObject: jsonRequestBody)
        } catch {
            print("Failed to serialize JSON: \(error)")
            pushwooshSetSubTag(value: false)
            resultExamination(false)
            return
        }
#warning("replace to release")
        //#if DEBUG
        let url = URL(string: "https://sandbox.itunes.apple.com/verifyReceipt")!
        //#else
        //        let url = URL(string: "https://buy.itunes.apple.com/verifyReceipt")!
        //#endif
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = requestData
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Failed to validate receipt: \(error) IAPManager")
                self.pushwooshSetSubTag(value: false)
                resultExamination(false)
                return
            }
            
            guard let data = data else {
                print("No data received from receipt validation IAPManager")
                self.pushwooshSetSubTag(value: false)
                resultExamination(false)
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let latestReceiptInfo = json["latest_receipt_info"] as? [[String: Any]] {
                    for receipt in latestReceiptInfo {
                        if let receiptProductIdentifier = receipt["product_id"] as? String,
                           receiptProductIdentifier == productIdentifier,
                           let expiresDateMsString = receipt["expires_date_ms"] as? String,
                           let expiresDateMs = Double(expiresDateMsString) {
                            let expiresDate = Date(timeIntervalSince1970: expiresDateMs / 1000)
                            if expiresDate > Date() {
                                DispatchQueue.main.async {
                                    self.pushwooshSetSubTag(value: true)
                                    resultExamination(true)
                                }
                                return
                            }
                        }
                    }
                }
            } catch {
                print("Failed to parse receipt data 🔴: \(error) IAPManager")
            }
            
            DispatchQueue.main.async {
                self.pushwooshSetSubTag(value: false)
                resultExamination(false)
            }
        }
        task.resume()
    }
    
    
    func validateSubscriptions(productIdentifiers: [String], completion: @escaping ([String: Bool]) -> Void) {
        var results = [String: Bool]()
        let dispatchGroup = DispatchGroup()
        
        for productIdentifier in productIdentifiers {
            dispatchGroup.enter()
            validateSubscriptionWithCompletionHandler(productIdentifier: productIdentifier) { isValid in
                results[productIdentifier] = isValid
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(results)
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        Pushwoosh.sharedInstance().sendSKPaymentTransactions(transactions)
        for transaction in transactions {
            if let error = transaction.error as NSError?, error.domain == SKErrorDomain {
                switch error.code {
                case SKError.paymentCancelled.rawValue:
                    print("User cancelled the request IAPManager")
                case SKError.paymentNotAllowed.rawValue, SKError.paymentInvalid.rawValue, SKError.clientInvalid.rawValue, SKError.unknown.rawValue:
                    print("This device is not allowed to make the payment IAPManager")
                default:
                    break
                }
            }
            
            switch transaction.transactionState {
            case .purchased:
                if let product = getCurrentProduct() {
                    if transaction.payment.productIdentifier == product.productIdentifier {
                        SKPaymentQueue.default().finishTransaction(transaction)
                        trackSubscription(transaction: transaction, product: product)
                        switch productBuy {
                        case .unlockContentProduct:
                            contentSubIsVaild = true
                            contentProductDelegate?.contnetDidUnlocked()
                        case .unlockFuncProduct:
                            addonCreatorIsValid = true
                        case .unlockOther:
                            skinCreatorSubIsValid = true
                        case .mainProduct:
                            transactionsDelegate?.goToTheApp()
                        }
                    }
                }
            case .failed:
                SKPaymentQueue.default().finishTransaction(transaction)
                transactionsDelegate?.failed()
                //transactionsDelegate?.infoAlert(title: "error", message: "something went wrong")
                print("Failed IAPManager")
                
            case .restored:
                SKPaymentQueue.default().finishTransaction(transaction)
                completeRestoredStatusFunc(restoreProductID: transaction.payment.productIdentifier, transaction: transaction)
                
            case .purchasing, .deferred:
                print("Purchasing IAPManager")
                
            default:
                print("Default IAPManager")
            }
        }
        completeAllTransactionsFunc()
    }
    
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print("requesting to product IAPManager")
        
        if let invalidIdentifier = response.invalidProductIdentifiers.first {
            print("Invalid product identifier:", invalidIdentifier , "IAPManager")
        }
        
        guard !response.products.isEmpty else {
            print("No products available IAPManager")
            return
        }
        
        response.products.forEach({ productFromRequest in
            switch productFromRequest.productIdentifier {
            case Configurations_REFACTOR.mainSubscriptionID:
                inMain = productFromRequest
            case Configurations_REFACTOR.unlockContentSubscriptionID:
                inUnlockContent = productFromRequest
            case Configurations_REFACTOR.unlockFuncSubscriptionID:
                inUnlockFunc = productFromRequest
            case Configurations_REFACTOR.unlockerThreeSubscriptionID:
                inUnlockOther = productFromRequest
            default:
                print("error IAPManager")
                return
            }
            print("Found product: \(productFromRequest.productIdentifier) IAPManager")
        })
    }
    
    private func processProductPrice(for product: SKProduct?) {
        guard let product = product else {
            self.localizablePrice = "4.99 $"
            return
        }
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = product.priceLocale
        
        if let formattedPrice = numberFormatter.string(from: product.price) {
            self.localizablePrice = formattedPrice
        } else {
            self.localizablePrice = "4.99 $"
        }
    }
    
    private func pushwooshSetSubTag(value : Bool) {
        
        var tag = Configurations_REFACTOR.mainSubscriptionPushTag
        
        switch productBuy {
        case .mainProduct:
            print("continue IAPManager")
        case .unlockContentProduct:
            tag = Configurations_REFACTOR.unlockContentSubscriptionPushTag
        case .unlockFuncProduct:
            tag = Configurations_REFACTOR.unlockFuncSubscriptionPushTag
        case .unlockOther:
            tag = Configurations_REFACTOR.unlockerThreeSubscriptionPushTag
        }
        
        Pushwoosh.sharedInstance().setTags([tag: value]) { error in
            if let err = error {
                print(err.localizedDescription)
                print("send tag error IAPManager")
            }
        }
    }
    
    private func trackSubscription(transaction: SKPaymentTransaction, product: SKProduct) {
        if let receiptURL = Bundle.main.appStoreReceiptURL,
           let receiptData = try? Data(contentsOf: receiptURL) {
            
            let price = NSDecimalNumber(decimal: product.price.decimalValue)
            let currency = product.priceLocale.currencyCode ?? "USD"
            let transactionId = transaction.transactionIdentifier ?? ""
            let transactionDate = transaction.transactionDate ?? Date()
            let salesRegion = product.priceLocale.regionCode ?? "US"
            
            if let subscription = ADJSubscription(price: price, currency: currency, transactionId: transactionId, andReceipt: receiptData) {
                subscription.setTransactionDate(transactionDate)
                subscription.setSalesRegion(salesRegion)
                Adjust.trackSubscription(subscription)
            }
        }
    }
}
