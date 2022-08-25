//
//  MapsRouter.swift
//  Countries

import UIKit

protocol MapsRouterInput: AnyObject {
    func createVC() -> UIViewController
    func dismissVC()
}

final class MapsRouter: MapsRouterInput {
    weak var viewController: MapsViewController!

    // MARK: - Navigation

    func createVC() -> UIViewController {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Maps", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "MapsViewController")
        return vc
    }
    
    func dismissVC() {
        viewController.dismiss(animated: true)
    }
}
