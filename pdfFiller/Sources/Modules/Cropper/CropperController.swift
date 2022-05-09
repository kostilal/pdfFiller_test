//
//  CropperController.swift
//  pdfFiller
//
//  Created by Kostyukevich Ilya on 04.05.2022.
//

import UIKit

protocol CropperControllerProtocol: BaseViewControllerProtocol {
    var presenter: CropperPeresenterProtocol? { get set }
    
    func show(data: CropperViewModel)
}

final class CropperController: BaseController {
    // MARK: Properties
    private lazy var imageView: CropImageView = {
        let imageView = CropImageView()
        view.addSubview(imageView)
        
        return imageView
    }()
    
    var presenter: CropperPeresenterProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.onViewDidLoad()
    }
}

extension CropperController: CropperControllerProtocol {
    // MARK: Presenting
    func show(data: CropperViewModel) {
        title = data.title
        
        let applyButton = UIBarButtonItem(title: data.applyButtonTitle,
                                          style: .plain,
                                          target: self,
                                          action: #selector(applyButtonPressed))
        navigationItem.rightBarButtonItem = applyButton
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])

        imageView.configure(image: data.image)
    }
}

private extension CropperController {
    // MARK: Actions
    @objc func applyButtonPressed() {
        let poinst = imageView.getFramePath()
        presenter?.imageCropped(with: poinst)
    }
}
