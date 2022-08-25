//
//  CountriesListPresenter.swift
//  Countries

import UIKit

protocol CountriesListPresenterOutput: AnyObject {
    func presentCountriesListFromFile(response: CountriesListModels.CountriesListFromFile.Response)
    func presentSearchCountry(response: CountriesListModels.SearchCountry.Response)
    func presentDataLoadMore(response: CountriesListModels.DataLoadMore.Response)
}

final class CountriesListPresenter: CountriesListPresenterOutput {
    weak var viewController: CountriesListViewControllerOutput?

    // MARK: - Presentation logic

    func presentCountriesListFromFile(response: CountriesListModels.CountriesListFromFile.Response) {
        viewController?.displayCountriesListFromFile(viewModel: CountriesListModels.CountriesListFromFile.ViewModel())
    }
    
    func presentSearchCountry(response: CountriesListModels.SearchCountry.Response) {
        let viewModel: CountriesListModels.SearchCountry.ViewModel
        if response.hasSearchResult {
            viewModel = CountriesListModels.SearchCountry.ViewModel(data: .success(response.searchList))
        } else if response.isTextEmpty {
            viewModel = CountriesListModels.SearchCountry.ViewModel(data: .searchTextEmpty)
        } else {
            viewModel = CountriesListModels.SearchCountry.ViewModel(data: .emptyList)
        }
        viewController?.displaySearchCountry(viewModel: viewModel)
    }
    
    func presentDataLoadMore(response: CountriesListModels.DataLoadMore.Response) {
        let viewModel = CountriesListModels.DataLoadMore.ViewModel(loadMoreItems: response.loadMoreItems)
        viewController?.displayDataLoadMore(viewModel: viewModel)
    }
}
