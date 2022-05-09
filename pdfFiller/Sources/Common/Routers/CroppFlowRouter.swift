//
//  CroppFlowRouter.swift
//  pdfFiller
//
//  Created by Kostyukevich Ilya on 04.05.2022.
//

import UIKit

final class CroppFlowRouter {
    // MARK: Properties
    private let navController: UINavigationController
    
    // MARK: Init
    init(navController: UINavigationController, image: UIImage) {
        self.navController = navController
        
        let controller = CropperController(loadType: .xib)
        CropperPeresenter(controller: controller, delegate: self, image: image)
        navController.pushViewController(controller, animated: false)
    }
}

extension CroppFlowRouter: CropperPeresenterDelegate {
    // MARK: Busines Logic
    func presenterCropImage(_ presenter: CropperPeresenterProtocol, image: UIImage) {
        let controller = CropResultController(loadType: .xib)
        CropResultPeresenter(controller: controller, image: image)
        navController.pushViewController(controller, animated: true)
    }
}
