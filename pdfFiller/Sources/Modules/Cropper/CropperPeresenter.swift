//
//  CropperPeresenter.swift
//  pdfFiller
//
//  Created by Kostyukevich Ilya on 04.05.2022.
//

import Foundation
import UIKit

protocol CropperPeresenterProtocol: BasePresenterProtocol {
    func imageCropped(with path: UIBezierPath)
}

protocol CropperPeresenterDelegate: AnyObject {
    func presenterCropImage(_ presenter: CropperPeresenterProtocol, image: UIImage)
}

final class CropperPeresenter: CropperPeresenterProtocol {
    // MARK: Properties
    private weak var controller: CropperControllerProtocol?
    private weak var delegate: CropperPeresenterDelegate?
    private let image: UIImage
    
    // MARK: Init
    @discardableResult init(controller: CropperControllerProtocol, delegate: CropperPeresenterDelegate, image: UIImage) {
        self.controller = controller
        self.delegate = delegate
        self.image = image
        
        self.controller?.presenter = self
    }
    
    // MARK: Busines Logic
    func onViewDidLoad() {
        let data = CropperViewModel(title: "Crop image",
                                    applyButtonTitle: "Apply",
                                    image: image)
        
        controller?.show(data: data)
    }
    
    func imageCropped(with path: UIBezierPath) {
        guard let maskedImage = image.imageByApplyingMask(path)?.flattened else {
            controller?.showPopup(title: "Error", message: "Couldn't proceed image. Try again")
            
            return
        }
        
        delegate?.presenterCropImage(self, image: maskedImage)
    }
}
