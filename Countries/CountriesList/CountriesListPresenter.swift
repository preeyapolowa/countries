//
//  CountriesListPresenter.swift
//  Countries

import UIKit

protocol CountriesListPresenterOutput: AnyObject {
    func presentCountriesListFromFile(response: CountriesListModels.CountriesListFromFile.Response)
}

final class CountriesListPresenter: CountriesListPresenterOutput {
    weak var viewController: CountriesListViewControllerOutput?

    // MARK: - Presentation logic

    func presentCountriesListFromFile(response: CountriesListModels.CountriesListFromFile.Response) {
        viewController?.displayCountriesListFromFile(viewModel: CountriesListModels.CountriesListFromFile.ViewModel())
    }
}
