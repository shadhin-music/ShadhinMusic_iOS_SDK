import Foundation

public struct SubscriptionAppleProducts {
    public static let monthlySub = "com.gakkmedia.Shadhin.monthlySub"
    public static let yearlySub = "com.gakkmedia.Shadhin.yearlySub"
    public static let store = IAPManager(productIDs: SubscriptionAppleProducts.productIDs)
    private static let productIDs: Set<ProductID> = [SubscriptionAppleProducts.monthlySub, SubscriptionAppleProducts.yearlySub]
}

//public func resourceNameForProductIdentifier(_ productIdentifier: String) -> String? {
//    return productIdentifier.components(separatedBy: ".").last
//}
//

