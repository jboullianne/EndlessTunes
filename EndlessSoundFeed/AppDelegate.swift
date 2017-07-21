//
//  AppDelegate.swift
//  EndlessSoundFeed
//
//  Created by Jean-Marc Boullianne on 5/1/17.
//  Copyright © 2017 Jean-Marc Boullianne. All rights reserved.
//

import UIKit
import Firebase
import FirebaseMessaging
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var auth = SPTAuth.defaultInstance()
    var npBarDelegate:NowPlayingBarDelegate?
    var spSession:SPTSession?
    var loginURL:URL?
    
    var mediaManager:MediaManager!
    var application:UIApplication!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        self.application = application
        
        FIRApp.configure()
        auth?.redirectURL = URL(string: "endlesseoundfeed://spotifyReturnAfterLogin")
        auth?.sessionUserDefaultsKey = "SpotifySession"
        
        mediaManager = MediaManager.sharedInstance
        setupSpotify()
        loadSpotifySession()
        
        if #available(iOS 10.0, *) {
            
            
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            // For iOS 10 data message (sent via FCM)
            FIRMessaging.messaging().remoteMessageDelegate = self
            
        }
        
        //application.registerForRemoteNotifications()
        
        return true
    }
    
    // 1
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        print("APP URL?: \(url)")
        // 2- check if app can handle redirect URL
        if (auth?.canHandle(auth?.redirectURL))! {
            //print("Redirect URL in AUTH: \(auth?.redirectURL)")
            // 3 - handle callback in closure
            //print("Absolute String: \(url.absoluteString)")
            let tempURL = url.absoluteString
            //print("RANGE: \(tempURL.range(of: "/?"))")
            //print("Replaced URL: \(tempURL.replacingCharacters(in: tempURL.range(of: "/?")! , with: "?"))")
            let newURL = URL(string: tempURL.replacingCharacters(in: tempURL.range(of: "/?")! , with: "?"))
            
            auth?.handleAuthCallback(withTriggeredAuthURL: newURL, callback: { (error, session) in
                // 4- handle error
                print("URL?: \(url)")
                if error != nil {
                    print("error!\(error.debugDescription)")
                    return
                }
                // 5- Add session to User Defaults
                let userDefaults = UserDefaults.standard
                let sessionData = NSKeyedArchiver.archivedData(withRootObject: session!)
                userDefaults.set(sessionData, forKey: "SpotifySession")
                userDefaults.synchronize()
                print("Session set into user defaults")
                // 6 - Tell notification center login is successful
                self.spSession = session
                NotificationCenter.default.post(name: Notification.Name(rawValue: "loginSuccessfull"), object: nil)
            })
            return true
        }
        return false
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func loadSpotifySession(){
        print("LoadSpotifySession Called")
        if let sessionObj:AnyObject = UserDefaults.standard.object(forKey: "SpotifySession") as AnyObject? {
            let sessionDataObj = sessionObj as! Data
            let firstTimeSession = NSKeyedUnarchiver.unarchiveObject(with: sessionDataObj) as! SPTSession
            
            spSession = firstTimeSession
            print("SPOTIFY SESSION IS VALID: ", spSession!.isValid())
            
            if(!spSession!.isValid()){
                SPTAuth.defaultInstance().renewSession(spSession, callback: { (error, session) in
                    print("SESSION RENEW?: \(String(describing: error)) : \(String(describing: session))")
                    if let newSession = session {
                        self.spSession = session
                        let userDefaults = UserDefaults.standard
                        let sessionData = NSKeyedArchiver.archivedData(withRootObject: newSession)
                        userDefaults.set(sessionData, forKey: "SpotifySession")
                        userDefaults.synchronize()
                        self.mediaManager.initializePlayer(authSession: self.spSession!)
                    }
                })
            }else{
                self.mediaManager.initializePlayer(authSession: self.spSession!)
            }
        }
    }
    
    func refreshSpotifySession(callback: @escaping () -> ()){
        SPTAuth.defaultInstance().renewSession(spSession, callback: { (error, session) in
            print("SESSION RENEW?: \(String(describing: error)) : \(String(describing: session))")
            if let newSession = session {
                self.spSession = newSession
                callback()
                
                let userDefaults = UserDefaults.standard
                let sessionData = NSKeyedArchiver.archivedData(withRootObject: newSession)
                userDefaults.set(sessionData, forKey: "SpotifySession")
                userDefaults.synchronize()
            }
        })
    }
    
    func setupSpotify(){
        auth!.clientID          = "64cc78e5b2384aaeb6b0272bc6ab70b1"
        auth!.redirectURL       = URL(string: "endlesssoundfeed://spotifyReturnAfterLogin")
        auth!.requestedScopes   = [SPTAuthStreamingScope, SPTAuthPlaylistReadPrivateScope]
        
        //Token Swap Service On Server
        auth!.tokenSwapURL = URL(string: "https://us-central1-endlesssoundfeed-fc088.cloudfunctions.net/spotifyCallback")
        //Token Refresh Service On Server
        auth!.tokenRefreshURL = URL(string: "https://us-central1-endlesssoundfeed-fc088.cloudfunctions.net/spotifyRefresh")
        
        //For Implicit Token Grant
        //loginUrl = URL(string: "https://us-central1-endlesssoundfeed-fc088.cloudfunctions.net/connectSpotify")
        if(SPTAuth.supportsApplicationAuthentication()){
            print("Can Handle App Authentication.")
            loginURL = auth?.spotifyAppAuthenticationURL()
        }else{
            print("Can Handle Web Authentication.")
            loginURL = auth?.spotifyWebAuthenticationURL()
        }
        
        //For Authorization Code Grant?
        //loginUrl = SPTAuth.defaultInstance().spotifyAppAuthenticationURL()
        
        
    }

}

@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        // Print message ID.
        print("Message ID: \(userInfo["gcm.message_id"]!)")
        
        // Print full message.
        print("%@", userInfo)
        
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        
        let token = tokenParts.joined()
        print("Device Token: \(token)")
        if let refreshedToken = FIRInstanceID.instanceID().token() {
            print("InstanceID token: \(refreshedToken)")
            AccountManager.sharedInstance.attachDeviceTokenToUser(token: refreshedToken)
        }
        
        
        
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Error Registering For Remote Notifications: \(error.localizedDescription)")
    }
    
}

extension AppDelegate : FIRMessagingDelegate  {
    /// The callback to handle data message received via FCM for devices running iOS 10 or above.
    func applicationReceivedRemoteMessage(_ remoteMessage: FIRMessagingRemoteMessage) {
        print("%@", remoteMessage.appData)
    }

}

