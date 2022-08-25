//
//  CountriesListInteractor.swift
//  Countries

import UIKit

protocol CountriesListInteractorOutput: AnyObject {
    func getCountriesListFromFile(request: CountriesListModels.CountriesListFromFile.Request)
    func searchCountry(request: CountriesListModels.SearchCountry.Request)
}

final class CountriesListInteractor: CountriesListInteractorOutput {
    var presenter: CountriesListPresenterOutput!
    // MARK: - Business logic
    var countriesList: [Countries]?
    
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
        guard let countriesList = countriesList,
              !request.keyword.isEmpty  else {
            let response = CountriesListModels.SearchCountry.Response(isTextEmpty: true, hasSearchResult: false, searchList: [])
            presenter.presentSearchCountry(response: response)
            return
        }
        
        var searchResult: [Countries]?
        if request.keyword.count > 2 {
            searchResult = countriesList.filter {
                if $0.name.hasPrefix(request.keyword, caseSensitive: false) {
                    return true
                }
                return false
            }
        } else {
            searchResult = countriesList.filter {
                if $0.name.hasPrefix(request.keyword, caseSensitive: false) ||
                    $0.country.hasPrefix(request.keyword, caseSensitive: false) {
                    return true
                }
                return false
            }
            searchResult = searchResult?.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        }
        
        let response: CountriesListModels.SearchCountry.Response
        if let result = searchResult, !result.isEmpty {
            response = CountriesListModels.SearchCountry.Response(hasSearchResult: true, searchList: result)
            presenter.presentSearchCountry(response: response)
        } else {
            response = CountriesListModels.SearchCountry.Response(hasSearchResult: false, searchList: [])
            presenter.presentSearchCountry(response: response)
        }
    }
}
