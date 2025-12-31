import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var subscriptionManager = SubscriptionManager.shared
    @AppStorage("isPurchasing") private var isPurchasing = false
    @State private var selectedProduct: Product?
    @AppStorage("showSuccess") private var showSuccess = false
    @AppStorage("showError") private var showError = false
    @State private var eligibleForTrial: [String: Bool] = [:]
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [AppColors.warmCoral.opacity(0.1), AppColors.sunsetOrange.opacity(0.05), Color(.systemBackground)], startPoint: .top, endPoint: .bottom).ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 34) {
                        headerSection
                        featuresSection
                        productsSection
                        legalSection
                        restoreSection
                    }.padding()
                }
            }
            .navigationTitle("Go Pro")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Close") { dismiss() } }
            }
            .task { await checkTrialEligibility() }
            .alert("Welcome to Pro!", isPresented: $showSuccess) {
                Button("OK") { dismiss() }
            } message: { Text("Enjoy unlimited affirmations and features!") }
            .alert("Error", isPresented: $showError) {
                Button("OK") {}
            } message: { Text(subscriptionManager.errorMessage ?? "An error occurred") }
        }
    }
    
    private func checkTrialEligibility() async {
        for product in subscriptionManager.products {
            eligibleForTrial[product.id] = await subscriptionManager.isEligibleForTrial(product)
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 13) {
            Image(systemName: "sun.max.fill").font(.system(size: 80)).foregroundStyle(AppColors.goldenYellow)
            Text("Unlock Affirm Pro").font(.title.weight(.bold))
            if let monthly = subscriptionManager.monthlyProduct,
               eligibleForTrial[monthly.id] == true,
               let trialText = subscriptionManager.trialPeriodText(monthly) {
                Text("Start your \(trialText) trial").font(.headline).foregroundStyle(AppColors.warmCoral)
            } else {
                Text("Transform your mindset daily").font(.subheadline).foregroundStyle(.secondary)
            }
        }.padding(.top, 21)
    }
    
    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: 13) {
            FeatureRow(icon: "heart.fill", title: "Unlimited Favorites", description: "Save as many affirmations as you want")
            FeatureRow(icon: "clock.fill", title: "Custom Reminder Time", description: "Set your perfect daily reminder")
            FeatureRow(icon: "icloud.fill", title: "iCloud Sync", description: "Sync favorites across all devices")
            FeatureRow(icon: "sparkles", title: "Support Development", description: "Help us build more features")
            FeatureRow(icon: "heart.circle.fill", title: "Good Karma", description: "Support mindfulness apps")
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 21))
    }
    
    private var productsSection: some View {
        VStack(spacing: 13) {
            if subscriptionManager.isLoading {
                ProgressView().frame(height: 120)
            } else if subscriptionManager.products.isEmpty {
                Text("Products unavailable").foregroundStyle(.secondary).frame(height: 120)
            } else {
                ForEach(subscriptionManager.products, id: \.id) { product in
                    ProductCard(product: product, isSelected: selectedProduct?.id == product.id, isPurchasing: isPurchasing, isEligibleForTrial: eligibleForTrial[product.id] ?? false, subscriptionManager: subscriptionManager) { selectedProduct = product }
                }
                Button {
                    guard let product = selectedProduct else { return }
                    Task {
                        isPurchasing = true
                        let success = await subscriptionManager.purchase(product)
                        isPurchasing = false
                        if success { showSuccess = true }
                        else if subscriptionManager.errorMessage != nil { showError = true }
                    }
                } label: {
                    HStack {
                        if isPurchasing { ProgressView().tint(.white) }
                        else { Text(selectedProduct != nil && eligibleForTrial[selectedProduct!.id] == true ? "Start Free Trial" : "Subscribe").fontWeight(.semibold) }
                    }
                    .frame(maxWidth: .infinity).frame(height: 50)
                    .background(selectedProduct != nil ? AppColors.warmCoral : Color.gray, in: RoundedRectangle(cornerRadius: 13))
                    .foregroundStyle(.primary)
                }
                .disabled(selectedProduct == nil || isPurchasing)
            }
        }
        .onAppear { if selectedProduct == nil { selectedProduct = subscriptionManager.monthlyProduct ?? subscriptionManager.products.first } }
    }
    
    private var legalSection: some View {
        VStack(spacing: 8) {
            if let product = selectedProduct {
                let periodText = subscriptionManager.periodText(product)
                if eligibleForTrial[product.id] == true, let trialText = subscriptionManager.trialPeriodText(product) {
                    Text("\(trialText), then \(product.displayPrice) \(periodText). Cancel anytime.").font(.caption2).foregroundStyle(.secondary).multilineTextAlignment(.center)
                } else {
                    Text("\(product.displayPrice) \(periodText). Auto-renews. Cancel anytime.").font(.caption2).foregroundStyle(.secondary).multilineTextAlignment(.center)
                }
            }
            HStack(spacing: 13) {
                Link("Terms", destination: URL(string: "https://apple.caserlegal.com/#terms")!)
                Text("•").foregroundStyle(.secondary)
                Link("Privacy", destination: URL(string: "https://apple.caserlegal.com/#privacy")!)
            }.font(.caption2).foregroundStyle(AppColors.warmCoral)
        }
    }
    
    private var restoreSection: some View {
        Button {
            Task {
                isPurchasing = true
                let success = await subscriptionManager.restorePurchases()
                isPurchasing = false
                if success { showSuccess = true }
                else { subscriptionManager.errorMessage = "No purchases to restore"; showError = true }
            }
        } label: { Text("Restore Purchases").font(.subheadline).foregroundStyle(AppColors.warmCoral) }
        .disabled(isPurchasing).padding(.bottom, 21)
    }
}

struct FeatureRow: View {
    let icon: String; let title: String; let description: String
    var body: some View {
        HStack(spacing: 13) {
            Image(systemName: icon).font(.title2).foregroundStyle(AppColors.warmCoral).frame(width: 32)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.subheadline.weight(.semibold))
                Text(description).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
        }
    }
}

struct ProductCard: View {
    let product: Product; let isSelected: Bool; let isPurchasing: Bool; let isEligibleForTrial: Bool
    let subscriptionManager: SubscriptionManager; let onSelect: () -> Void
    var body: some View {
        Button(action: onSelect) {
            HStack {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle").font(.title2).foregroundStyle(isSelected ? AppColors.warmCoral : .secondary)
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(product.displayName).font(.headline)
                        if product.id.contains("monthly") {
                            Text("BEST VALUE").font(.caption2.weight(.bold)).foregroundStyle(.primary).padding(.horizontal, 6).padding(.vertical, 2).background(AppColors.goldenYellow, in: Capsule())
                        }
                    }
                    HStack(spacing: 4) {
                        Text(subscriptionManager.periodText(product)).font(.caption).foregroundStyle(.secondary)
                        if isEligibleForTrial, let trialText = subscriptionManager.trialPeriodText(product) {
                            Text("• \(trialText)").font(.caption.weight(.medium)).foregroundStyle(AppColors.warmCoral)
                        }
                    }
                }
                Spacer()
                Text(product.displayPrice).font(.title3.weight(.bold)).foregroundStyle(isSelected ? AppColors.warmCoral : .primary)
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 13).fill(isSelected ? AppColors.warmCoral.opacity(0.15) : Color.clear))
            .overlay(RoundedRectangle(cornerRadius: 13).stroke(isSelected ? AppColors.warmCoral : Color.secondary.opacity(0.3), lineWidth: isSelected ? 2 : 1))
        }.buttonStyle(.plain).disabled(isPurchasing)
    }
}

#Preview { PaywallView() }
