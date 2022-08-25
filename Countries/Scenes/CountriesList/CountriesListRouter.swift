//
//  CountriesListRouter.swift
//  Countries

import UIKit

protocol CountriesListRouterInput: AnyObject {
    func createVC() -> UIViewController
}

final class CountriesListRouter: CountriesListRouterInput {
    weak var viewController: CountriesListViewController!

    // MARK: - Navigation

    func createVC() -> UIViewController {
        let storyBoard: UIStoryboard = UIStoryboard(name: "CountriesList", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "CountriesListViewController")
        return vc
    }
}
