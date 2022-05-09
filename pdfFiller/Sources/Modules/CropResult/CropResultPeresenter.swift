//
//  CropResultPeresenter.swift
//  pdfFiller
//
//  Created by Kostyukevich Ilya on 04.05.2022.
//

import Foundation
import UIKit

final class CropResultPeresenter: BasePresenterProtocol {
    // MARK: Properties
    private weak var controller: CropResultControllerProtocol?
    private let image: UIImage
    
    // MARK: Init
    @discardableResult init(controller: CropResultControllerProtocol, image: UIImage) {
        self.controller = controller
        self.image = image
        
        self.controller?.presenter = self
    }
    
    // MARK: Busines Logic
    func onViewDidLoad() {
        let data = CropResultViewModel(title: "Result",
                                       image: image,
                                       imageViewInsets: 20)
        controller?.show(data: data)
    }
}
