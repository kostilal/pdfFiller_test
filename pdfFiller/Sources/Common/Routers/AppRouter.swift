//
//  AppRouter.swift
//  pdfFiller
//
//  Created by Kostyukevich Ilya on 05.05.2022.
//

import UIKit

final class AppRouter {
    // MARK: Properties
    private let navigationController: UINavigationController
    private var cropFlowRouter: CroppFlowRouter?
    
    // MARK: Init
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        
        showInitialFlow()
    }
}

private extension AppRouter {
    // MARK: Busines Logic
    func showInitialFlow() {
        // Init with bundl image
        let image = UIImage(imageLiteralResourceName: "im_test_rect")
        
        cropFlowRouter = CroppFlowRouter(navController: navigationController,
                                         image: image)
    }
}
