//
//  CropResultController.swift
//  pdfFiller
//
//  Created by Kostyukevich Ilya on 04.05.2022.
//

import UIKit

protocol CropResultControllerProtocol: BaseViewControllerProtocol {
    var presenter: BasePresenterProtocol? { get set }
    
    func show(data: CropResultViewModel)
}

final class CropResultController: BaseController {
    // MARK: Properties
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        return imageView
    }()
    
    var presenter: BasePresenterProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.onViewDidLoad()
    }
}

extension CropResultController: CropResultControllerProtocol {
    // MARK: Presenting
    func show(data: CropResultViewModel) {
        title = data.title
        imageView.image = data.image
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: data.imageViewInsets),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -data.imageViewInsets),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 1/(data.image.size.width/data.image.size.height))
        ])
    }
}
