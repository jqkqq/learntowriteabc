//
//  AppDelegate.swift
//  LearnToWriteABC

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let tabbar = UITabBarController()
        let voiceNav = UINavigationController()
        voiceNav.viewControllers = [VoiceViewController()]
        voiceNav.tabBarItem = UITabBarItem(title: "发音", image: UIImage(named: "icons8-voice-32"), selectedImage: UIImage(named: "icons8-voice-32"))
        
        let drawNav = UINavigationController()
        drawNav.viewControllers = [DrawViewController()]
        drawNav.tabBarItem = UITabBarItem(title: "寫字", image: UIImage(named: "icons8-ball-point-pen-32"), selectedImage: UIImage(named: "icons8-ball-point-pen-32"))
        
        let testNav = UINavigationController()
        testNav.viewControllers = [TestViewController()]
        testNav.tabBarItem = UITabBarItem(title: "測驗", image: UIImage(named: "icons8-test-results-32"), selectedImage: UIImage(named: "icons8-test-results-32"))
        
        tabbar.viewControllers = [voiceNav, drawNav, testNav]
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = tabbar
        window?.makeKeyAndVisible()
        
        return true
    }

    // MARK: UISceneSession Lifecycle

//    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
//        // Called when a new scene session is being created.
//        // Use this method to select a configuration to create the new scene with.
//        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
//    }
//
//    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
//        // Called when the user discards a scene session.
//        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
//        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
//    }


}

