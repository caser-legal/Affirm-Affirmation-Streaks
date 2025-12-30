import SwiftUI
import StoreKit

@MainActor @Observable
class SubscriptionManager {
    static let shared = SubscriptionManager()
    
    var products: [Product] = []
    var purchasedProductIDs: Set<String> = []
    var isLoading = false
    var errorMessage: String?
    
    private let productIDs = ["caserlegal.Affirm.weekly", "caserlegal.Affirm.monthly"]
    
    var isPro: Bool { !purchasedProductIDs.isEmpty }
    var weeklyProduct: Product? { products.first { $0.id.contains("weekly") } }
    var monthlyProduct: Product? { products.first { $0.id.contains("monthly") } }
    
    init() {
        Task { await loadProducts() }
        Task { await updatePurchasedProducts() }
        listenForTransactions()
    }
    
    @MainActor
    func loadProducts() async {
        isLoading = true
        do {
            products = try await Product.products(for: productIDs)
            products.sort { $0.id.contains("monthly") && !$1.id.contains("monthly") }
        } catch { errorMessage = "Failed to load products" }
        isLoading = false
    }
    
    func purchase(_ product: Product) async -> Bool {
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await transaction.finish()
                await updatePurchasedProducts()
                return true
            case .userCancelled, .pending: return false
            @unknown default: return false
            }
        } catch { errorMessage = "Purchase failed"; return false }
    }
    
    func restorePurchases() async -> Bool {
        do {
            try await AppStore.sync()
            await updatePurchasedProducts()
            return !purchasedProductIDs.isEmpty
        } catch { errorMessage = "Restore failed"; return false }
    }
    
    @MainActor
    private func updatePurchasedProducts() async {
        var purchased: Set<String> = []
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                if transaction.revocationDate == nil { purchased.insert(transaction.productID) }
            }
        }
        purchasedProductIDs = purchased
    }
    
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(_, let error): throw error
        case .verified(let safe): return safe
        }
    }
    
    private func listenForTransactions() {
        Task.detached {
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    await transaction.finish()
                    await self.updatePurchasedProducts()
                }
            }
        }
    }
    
    func isEligibleForTrial(_ product: Product) async -> Bool {
        guard let subscription = product.subscription else { return false }
        return await subscription.isEligibleForIntroOffer
    }
    
    func trialPeriodText(_ product: Product) -> String? {
        guard let intro = product.subscription?.introductoryOffer, intro.paymentMode == .freeTrial else { return nil }
        let value = intro.period.value
        switch intro.period.unit {
        case .day: return value == 1 ? "1 day free" : "\(value) days free"
        case .week: return value == 1 ? "1 week free" : "\(value) weeks free"
        case .month: return value == 1 ? "1 month free" : "\(value) months free"
        case .year: return value == 1 ? "1 year free" : "\(value) years free"
        @unknown default: return nil
        }
    }
    
    func periodText(_ product: Product) -> String {
        guard let period = product.subscription?.subscriptionPeriod else { return "" }
        switch period.unit {
        case .day: return period.value == 7 ? "per week" : "per day"
        case .week: return "per week"
        case .month: return "per month"
        case .year: return "per year"
        @unknown default: return ""
        }
    }
}
