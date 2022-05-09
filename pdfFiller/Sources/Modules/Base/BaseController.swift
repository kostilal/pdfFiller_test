//
//  BaseController.swift
//  pdfFiller
//
//  Created by Kostyukevich Ilya on 04.05.2022.
//

import UIKit

protocol BaseViewControllerProtocol: AnyObject {
    func showPopup(title: String?, message: String?)
}

class BaseController: UIViewController {
    enum LoadType {
        case programmatically
        case xib
        case xibName(String)
    }
    
    init(loadType: LoadType = .xib) {
        var nibName: String
        
        switch loadType {
        case .programmatically:
            super.init(nibName: nil, bundle: nil)
            return
        case .xib:
            nibName = type(of: self).className
        case let .xibName(name):
            nibName = name
        }
        
        super.init(nibName: nibName, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
}

extension BaseController: BaseViewControllerProtocol {
    func showPopup(title: String?, message: String?) {
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertController.addAction(ok)
        
        present(alertController, animated: true, completion: nil)
    }
}
