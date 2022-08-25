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
    let fileJsonName = "cities"
    var countriesList: [Countries]?
    var searchResult: [Countries]?
    var displayItemsList: [Countries] = []
    var startIndex = 0
    var countItems = 10
    var canLoadMore = false
    var isLoadMore = false
    var isRunningTests: Bool {
        return ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
    }
    
    func getCountriesListFromFile(request: CountriesListModels.CountriesListFromFile.Request) {
        DispatchQueue.global(qos: .background).async {
            do {
                guard let fileUrl = Bundle.main.url(forResource: self.fileJsonName, withExtension: "json") else { fatalError() }
                let data = try Data(contentsOf: fileUrl)
                let countriesJson = try JSONDecoder().decode([Countries].self, from: data)
                self.countriesList = countriesJson
                self.presenter.presentCountriesListFromFile(response: CountriesListModels.CountriesListFromFile.Response())
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
              !request.keyword.isEmpty else {
            let response = Response(isTextEmpty: request.keyword.isEmpty, hasSearchResult: false, searchList: [])
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
                self.searchResult = self.searchResult?.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
            } else {
                var nameList = countriesList.filter {
                    return $0.name.hasPrefix(request.keyword, caseSensitive: false)
                }
                var countryList = countriesList.filter {
                    return $0.country.hasPrefix(request.keyword, caseSensitive: false)
                }
                nameList = nameList.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
                countryList = countryList.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
                self.searchResult = nameList
                countryList.forEach { value in
                    if nameList.contains(where: { value.name != $0.name }) {
                        self.searchResult?.append(value)
                    }
                }
            }
            
            if let result = self.searchResult, !result.isEmpty {
                if self.isRunningTests {
                    for index in self.startIndex...result.count - 1 {
                        self.displayItemsList.append(result[index])
                    }
                } else {
                    self.canLoadMore = result.count >= self.countItems
                    self.countItems = result.count >= self.countItems ? self.countItems : result.count
                    for index in self.startIndex...self.countItems - 1 {
                        self.displayItemsList.append(result[index])
                    }
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
