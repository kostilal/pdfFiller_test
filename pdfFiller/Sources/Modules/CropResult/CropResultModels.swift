//
//  CropResultModels.swift
//  pdfFiller
//
//  Created by Kostyukevich Ilya on 04.05.2022.
//

import UIKit

typealias CropResultViewModel = CropResultModels.ViewModel

struct CropResultModels {
    struct ViewModel {
        let title: String
        let image: UIImage
        let imageViewInsets: CGFloat
    }
}
