//
//  CountriesListRouter.swift
//  Countries

import UIKit

protocol CountriesListRouterInput: AnyObject {
    func createVC() -> UIViewController
    func navigateToMaps(lat: Double, lon: Double)
}

final class CountriesListRouter: CountriesListRouterInput {
    weak var viewController: CountriesListViewController!

    // MARK: - Navigation

    func createVC() -> UIViewController {
        let storyBoard: UIStoryboard = UIStoryboard(name: "CountriesList", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "CountriesListViewController")
        return vc
    }
    
    func navigateToMaps(lat: Double, lon: Double) {
        guard let vc = MapsRouter().createVC() as? MapsViewController else { return }
        vc.interactor.lat = lat
        vc.interactor.lon = lon
        vc.modalPresentationStyle = .fullScreen
        viewController.present(vc, animated: true)
    }
}
