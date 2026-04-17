import Foundation

enum AppSettings {
    private static let autoSyncKey = "settings.autoSyncEnabled"

    static var autoSyncEnabled: Bool {
        get {
            if UserDefaults.standard.object(forKey: autoSyncKey) == nil {
                return true
            }

            return UserDefaults.standard.bool(forKey: autoSyncKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: autoSyncKey)
        }
    }
}
