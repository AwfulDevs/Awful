//  UserDefaults+Settings.swift
//
//  Copyright 2019 Awful Contributors. CC BY-NC-SA 3.0 US https://github.com/Awful/Awful.app

import Foundation
import class ScannerShim.Scanner

// MARK: Keys

/**
 Keys used to store Awful's settings in UserDefaults.

 KVO-compliant properties are generated by Sourcery (see `UserDefaults+Settings.stencil` and `UserDefaults+Settings.generated.swift`). The value type is assumed to be `Bool` when not otherwise specified.
 */
enum SettingsKeys {
    static let automaticallyEnableDarkMode = "auto_dark_theme"
    static let automaticallyPlayGIFs = "autoplay_gifs"
    // sourcery: valueType = Double
    static let automaticDarkModeBrightnessThresholdPercent = "auto_theme_threshold"
    static let confirmNewPosts = "confirm_before_replying"
    // sourcery: valueType = String?
    static let customBaseURLString = "custom_base_URL"
    // sourcery: valueType = String!
    static let defaultDarkTheme = "default_dark_theme_name"
    // sourcery: valueType = String!
    static let defaultLightTheme = "default_light_theme_name"
    static let embedTweets = "embed_tweets"
    // sourcery: valueType = Double
    static let fontScale = "font_scale"
    static let hideSidebarInLandscape = "hide_sidebar_in_landscape"
    static let isDarkModeEnabled = "dark_theme"
    static let isHandoffEnabled = "handoff_enabled"
    static let isPullForNextEnabled = "pull_for_next"
    // sourcery: valueType = String?
    static let lastOfferedPasteboardURLString = "last_offered_pasteboard_URL"
    static let loggedInUserCanSendPrivateMessages = "can_send_private_messages"
    // sourcery: valueType = String?
    static let loggedInUserID = "userID"
    // sourcery: valueType = String?
    static let loggedInUsername = "username"
    static let openCopiedURLAfterBecomingActive = "clipboard_url_enabled"
    static let openTwitterLinksInTwitter = "open_twitter_links_in_twitter"
    static let openYouTubeLinksInYouTube = "open_youtube_links_in_youtube"
    static let postLargeImagesAsThumbnails = "automatic_timg"
    // sourcery: valueType = String?
    static let rawDefaultBrowser = "default_browser"
    static let showAuthorAvatars = "show_avatars"
    static let showImages = "show_images"
    static let showThreadTagsInThreadList = "show_thread_tags"
    static let showTweaksOnShake = "show_tweaks_on_shake"
    static let showUnreadAnnouncementsBadge = "show_unread_announcements_badge"
    static let sortUnreadBookmarksFirst = "bookmarks_sorted_unread"
    static let sortUnreadForumThreadsFirst = "forum_threads_sorted_unread"
}

// MARK: Keys still used in Objective-C code

extension UserDefaults {
    
    // If you can't find anywhere these properties are used, please delete them!
    
    @objc class var automaticDarkModeBrightnessThresholdPercentKey: String {
        SettingsKeys.automaticDarkModeBrightnessThresholdPercent
    }
    
    @objc class var automaticallyEnableDarkModeKey: String {
        SettingsKeys.automaticallyEnableDarkMode
    }
    
    @objc class var isDarkModeEnabledKey: String {
        SettingsKeys.isDarkModeEnabled
    }
}

// MARK: Observation helpers

extension UserDefaults {
    
    /**
     Calls a closure whenever the value for a particular keypath is changed.
     
     Unlike the closure passed to `observe(_:options:changeHandler:)`, this changeHandler is always called on the main queue.
     
     Also, including `.new` for the `options` parameter here doesn't seem to result in the closure getting passed anything for `change.newValue`. Not sure if we're doing something weird here, but it's actually easier to just ask the `UserDefaults` instance for the current value anyway, so that's the recommended approach.
     */
    func observeOnMain<Value>(
        _ keyPath: KeyPath<UserDefaults, Value>,
        options: NSKeyValueObservingOptions = [],
        changeHandler: @escaping (UserDefaults, NSKeyValueObservedChange<Value>) -> Void)
        -> NSKeyValueObservation
    {
        return observe(keyPath, options: options, changeHandler: { object, change in
            DispatchQueue.main.async {
                changeHandler(object, change)
            }
        })
    }
    
    /**
     Add several `UserDefaults` observers at once. Each observer will be called on the main queue.
     
     For example:
     
     var observers: [NSKeyValueObservation] = []
     
     observers += UserDefaults.standard.observeSeveral {
         $0.observe(\.showAvatars) { defaults in
             print("showAvatars is now \(defaults.showAvatars)")
         }
     }
     
     Note that there's no provision for `NSKeyValueObservingOptions` or `NSKeyValueObservedChange`; this is a convenience method for adding several observers that react to settings changes, and the assumption is that the current value is desired and will be obtained from the passed-in `UserDefaults` instance (as in the example).
     */
    func observeSeveral(_ block: (ObserveSeveralHelper) -> Void) -> [NSKeyValueObservation] {
        let helper = ObserveSeveralHelper(self)
        block(helper)
        return helper.observers
    }
    
    /// - Seealso: `UserDefaults.observeSeveral(_:)`.
    final class ObserveSeveralHelper {
        private let defaults: UserDefaults
        fileprivate var observers: [NSKeyValueObservation] = []
        
        fileprivate init(_ defaults: UserDefaults) {
            self.defaults = defaults
        }
        
        /**
         Add a key-value observer for each provided key path. The change handler is called on the main queue whenever any of the key paths change.
         
         The added observers are all included in the return value from `UserDefaults.observeSeveral(_:)`.
         
         If `options` contains `.initial`, then `changeHandler` will be called immediately, but exactly once (no matter how many `keyPaths` are provided).
         
         Passing `.old` and/or `.new` in `options` is probably not terribly useful, as `changeHandler` doesn't have access to the `NSKeyValueObservedChange` instance.
         */
        func observe<Value>(_ keyPaths: KeyPath<UserDefaults, Value>..., options: NSKeyValueObservingOptions = [], changeHandler: @escaping (UserDefaults) -> Void) {
            var noninitialOptions = options
            noninitialOptions.remove(.initial)
            observers += keyPaths.map { keyPath in
                return defaults.observeOnMain(keyPath, options: noninitialOptions, changeHandler: { defaults, change in
                    changeHandler(defaults)
                })
            }
            if options.contains(.initial) {
                changeHandler(defaults)
            }
        }
    }
}

// MARK: Working with SettingsSection

extension UserDefaults {
    func registerDefaults(_ sections: [SettingsSection]) {
        var defaults = SettingsSection.mainBundleSections.reduce(into: [:]) { defaults, section in
            defaults.merge(section.defaultValues, uniquingKeysWith: { $1 })
        }
        defaults[SettingsKeys.defaultDarkTheme] = SystemCapabilities.oled ? "oledDark" : "dark"
        defaults[SettingsKeys.defaultLightTheme] = SystemCapabilities.oled ? "brightLight" : "default"

        #if targetEnvironment(macCatalyst)
        defaults[SettingsKeys.automaticallyEnableDarkMode] = true
        #endif

        defaults.merge(Theme.forumSpecificDefaults, uniquingKeysWith: { $1 })
        register(defaults: defaults)
    }
}

// MARK: Mass deletion

extension UserDefaults {
    
    func removeAllObjectsInMainBundleDomain() {
        guard let bundleID = Bundle.main.bundleIdentifier else { return }
        setPersistentDomain([:], forName: bundleID)
    }
}

// MARK: Settings migration

extension UserDefaults {
    
    private enum OldSettingsKeys {
        
        /// Value was an array of forumID strings. As of Awful 3.2, favorite forums are stored in Core Data.
        static let favoriteForums = "favorite_forums"
        
        /// Possible values: "never", "landscape", "portrait", "always".
        static let keepSidebarOpen = "keep_sidebar_open"

        /// Possible values: `true`, `false`.
        static let isAlternateThemeEnabled = "alternate_theme"

        /// An array of strings representing theme names of themes that should be made available for selection in any forum, not just the specific forum that the theme was created for. This is no longer a relevant concept, as we allow users to choose any theme. We don't even bother deleting the now-unused value for this key. It's simply documented here for posterity.
        static let ubiquitousThemeNames = "ubiquitous_theme_names"
        
        /// Possible values: "green", "amber", "macinyos", "winpos95".
        static let yosposStyle = "yospos_style"
    }
    
    func migrateOldAwfulSettings() {
        let userSpecifiedSettings = persistentDomain(forName: Bundle.main.bundleIdentifier!) ?? [:]

        var newYOSPOSStyle: String? {
            switch userSpecifiedSettings[OldSettingsKeys.yosposStyle] as? String {
            case "green": return "YOSPOS"
            case "amber": return "YOSPOS (amber)"
            case "macinyos": return "Macinyos"
            case "winpos95": return "Winpos 95"
            default: return nil
            }
        }
        if let newYOSPOSStyle = newYOSPOSStyle {
            Theme.setThemeName(newYOSPOSStyle, forForumIdentifiedBy: "219", modes: [.light, .dark])
            removeObject(forKey: OldSettingsKeys.yosposStyle)
        }
        
        switch userSpecifiedSettings[OldSettingsKeys.keepSidebarOpen] as? String {
        case "never", "portrait":
            hideSidebarInLandscape = true
            removeObject(forKey: OldSettingsKeys.keepSidebarOpen)
        default:
            break
        }

        // "Alternate App Theme" used to be a separate setting. Now we have default theme settings for each mode.
        if userSpecifiedSettings[OldSettingsKeys.isAlternateThemeEnabled] as? Bool == true {
            defaultDarkTheme = "alternateDark"
            defaultLightTheme = "alternateDefault"
            removeObject(forKey: OldSettingsKeys.isAlternateThemeEnabled)
        }

        // Now we set forum-specific themes for each mode, so migrate the old keys over.
        func parseForumSpecificThemeKey(_ key: String) -> String? {
            let scanner = Scanner(string: key)
            scanner.caseSensitive = true
            scanner.charactersToBeSkipped = nil
            guard
                scanner.scanString("theme-") != nil,
                let forumID = scanner.scanInt(),
                scanner.isAtEnd
                else { return nil }
            return String(forumID)
        }
        var keysToRemove: [String] = []
        // We don't want any registered defaults, just ones the user has set.
        for (key, themeName) in userSpecifiedSettings {
            guard
                let forumID = parseForumSpecificThemeKey(key),
                let themeName = themeName as? String
                else { continue }
            Theme.setThemeName(themeName, forForumIdentifiedBy: forumID, modes: [.light, .dark])
            keysToRemove.append(key)
        }
        for key in keysToRemove {
            removeObject(forKey: key)
        }
    }
    
    var oldFavoriteForums: [String]? {
        get { return object(forKey: OldSettingsKeys.favoriteForums) as? [String] }
        set { set(newValue, forKey: OldSettingsKeys.favoriteForums) }
    }
}
