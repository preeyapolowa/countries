//
//  CountriesListInteractor.swift
//  Countries

import UIKit

protocol CountriesListInteractorOutput: AnyObject {
    func getCountriesListFromFile(request: CountriesListModels.CountriesListFromFile.Request)
    func searchCountry(request: CountriesListModels.SearchCountry.Request)
    func getDataLoadMore(request: CountriesListModels.DataLoadMore.Request)
    
    var canLoadMore: Bool { get }
}

final class CountriesListInteractor: CountriesListInteractorOutput {
    var presenter: CountriesListPresenterOutput!
    // MARK: - Business logic
    var countriesList: [Countries]?
    var searchResult: [Countries]?
    var displayItemsList: [Countries] = []
    var startIndex = 0
    var countItems = 10
    var canLoadMore = false
    var isLoadMore = false
    
    func getCountriesListFromFile(request: CountriesListModels.CountriesListFromFile.Request) {
        DispatchQueue.global(qos: .background).async {
            do {
                guard let fileUrl = Bundle.main.url(forResource: "cities", withExtension: "json") else { fatalError() }
                let data = try Data(contentsOf: fileUrl)
                let countriesJson = try JSONDecoder().decode([Countries].self, from: data)
                DispatchQueue.main.async {
                    self.countriesList = countriesJson
                    self.presenter.presentCountriesListFromFile(response: CountriesListModels.CountriesListFromFile.Response())
                }
            } catch {
                print(error)
            }
        }
    }
    
    func searchCountry(request: CountriesListModels.SearchCountry.Request) {
        // Reset
        searchResult = []
        displayItemsList = []
        startIndex = 0
        countItems = 10
        canLoadMore = false
        typealias Response = CountriesListModels.SearchCountry.Response
        guard let countriesList = countriesList,
              !request.keyword.isEmpty  else {
            let response = Response(isTextEmpty: true, hasSearchResult: false, searchList: [])
            presenter.presentSearchCountry(response: response)
            return
        }

        DispatchQueue.global(qos: .background).async {
            if request.keyword.count > 2 {
                self.searchResult = countriesList.filter {
                    if $0.name.hasPrefix(request.keyword, caseSensitive: false) {
                        return true
                    }
                    return false
                }
                
            } else {
                self.searchResult = countriesList.filter {
                    if $0.name.hasPrefix(request.keyword, caseSensitive: false) ||
                        $0.country.hasPrefix(request.keyword, caseSensitive: false) {
                        return true
                    }
                    return false
                }
                self.searchResult = self.searchResult?.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
            }
            
            if let result = self.searchResult, !result.isEmpty {
                self.canLoadMore = result.count >= self.countItems
                self.countItems = result.count >= self.countItems ? self.countItems : result.count
                for index in self.startIndex...self.countItems - 1 {
                    self.displayItemsList.append(result[index])
                }
            }
            
            let response: Response
            if !self.displayItemsList.isEmpty {
                response = Response(hasSearchResult: true, searchList: self.displayItemsList)
                self.presenter.presentSearchCountry(response: response)
            } else {
                response = Response(hasSearchResult: false, searchList: [])
                self.presenter.presentSearchCountry(response: response)
            }
        }
    }
    
    func getDataLoadMore(request: CountriesListModels.DataLoadMore.Request) {
        startIndex = countItems
        countItems = countItems + 10
        typealias Response = CountriesListModels.DataLoadMore.Response
        if let result = self.searchResult {
            self.canLoadMore = result.count >= self.countItems
            DispatchQueue.global(qos: .background).async {
                self.countItems = result.count >= self.countItems ? self.countItems : result.count
                for index in self.startIndex...self.countItems - 1 {
                    self.displayItemsList.append(result[index])
                }
                
                let response = Response(loadMoreItems: self.displayItemsList)
                self.presenter.presentDataLoadMore(response: response)
            }
        }
    }
}
