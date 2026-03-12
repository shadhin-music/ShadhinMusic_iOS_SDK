
import UIKit

public class ShadhinCore {
    
    static let instance = ShadhinCore()
    
    let api: ShadhinApi
    let defaults: ShadhinDefaults
    
    private init(){
        defaults = ShadhinDefaults()
        api = ShadhinApi()
    }
    
    var notifiers : WeakObjectSet = WeakObjectSet()
    var isHomeLoaded: Bool = false
    var isBangla : Bool = true

    public func addNotifier(notifier : ShadhinCoreNotifications){
        notifiers.addObject(notifier)
    }
    
    public func removeNotifier(notifier : ShadhinCoreNotifications){
        notifiers.removeObject(ObjectIdentifier(notifier).hashValue)
    }
    
    public func getTopViewController() -> UIViewController?{
        var topController = UIApplication.shared.keyWindow?.rootViewController
        while let presentedViewController = topController?.presentedViewController {
            topController = presentedViewController
        }
        return topController
    }
    
    public func initialize(){
        //api.upgradeToV5Token()
        api.releaseServerLock()
        api.tryToGetApproxLocationData()
        api.fetchAndCacheAllFav()
    }
    
    public func isInDebug() -> Bool{
#if DEBUG
        return true
#else
        return false
#endif
    }
    
}


