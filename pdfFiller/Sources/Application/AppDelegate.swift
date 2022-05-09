//
//  AppDelegate.swift
//  pdfFiller
//
//  Created by Kostyukevich Ilya on 04.05.2022.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var appRouter: AppRouter?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setupWindow()
        
        return true
    }
}

private extension AppDelegate {
    func setupWindow() {
        let navigationController = UINavigationController()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        
        appRouter = AppRouter(navigationController: navigationController)
    }
}
