//
//  CountriesListViewModel.swift
//  Countries
//
//  Created by Preeyapol Owatsuwan on 5/9/2565 BE.
//

import Foundation
import RxSwift

protocol CountriesListProtocolInput {
    func searchCountry(keyword: String)
}

protocol CountriesListProtocolOutput {
    func getCountriesListFromFile()
    func loadMoreCountries()
    func getCanLoadMore() -> Bool
    
    var showLoading: PublishSubject<Void> { get set }
    var hideLoading: PublishSubject<Void> { get set }
    var didKeywordEmpty: PublishSubject<Void> { get set }
    var didSearchCountrySuccess: PublishSubject<CountriesListModels.SearchCountry> { get set }
    var didSearchCountryEmpty: PublishSubject<Void> { get set }
    var didLoadMoreCountriesSuccess: PublishSubject<[Countries]> { get set }
}

protocol CountriesListProtocol: CountriesListProtocolInput, CountriesListProtocolOutput {
    var input: CountriesListProtocolInput { get }
    var output: CountriesListProtocolOutput { get }
}

class CountriesListViewModel: CountriesListProtocol {
    var input: CountriesListProtocolInput { return self }
    var output: CountriesListProtocolOutput { return self }
    
    var showLoading: PublishSubject<Void> = PublishSubject<Void>()
    var hideLoading: PublishSubject<Void> = PublishSubject<Void>()
    var didGetCountriesListSuccess: PublishSubject<[Countries]> = PublishSubject<[Countries]>()
    var didGetCountriesListFailed: PublishSubject<Void> = PublishSubject<Void>()
    var didKeywordEmpty: PublishSubject<Void> = PublishSubject<Void>()
    var didSearchCountrySuccess: PublishSubject<CountriesListModels.SearchCountry> = PublishSubject<CountriesListModels.SearchCountry>()
    var didSearchCountryEmpty: PublishSubject<Void> = PublishSubject<Void>()
    var didLoadMoreCountriesSuccess: PublishSubject<[Countries]> = PublishSubject<[Countries]>()
    
    // Properties
    let fileJsonName = "cities"
    var countriesList: [Countries]?
    var searchResult: [Countries]?
    var displayItemsList: [Countries] = []
    var startIndex = 0
    var countItems = 10
    var canLoadMore = false
    var isLoadMore = false
    
    // Unit Tests
    var loadMoreTests = false
    var isRunningTests: Bool {
        return ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
    }
}

extension CountriesListViewModel: CountriesListProtocolInput {
    func searchCountry(keyword: String) {
        typealias Model = CountriesListModels.SearchCountry
        
        // Reset
        searchResult = []
        displayItemsList = []
        startIndex = 0
        countItems = 10
        canLoadMore = false
        guard let countriesList = countriesList, !keyword.isEmpty else {
            didKeywordEmpty.onNext(())
            return
        }

        DispatchQueue.global(qos: .background).async {
            if keyword.count > 2 {
                self.searchResult = countriesList.filter {
                    if $0.name.hasPrefix(keyword, caseSensitive: false) {
                        return true
                    }
                    return false
                }
                self.searchResult = self.searchResult?.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
            } else {
                var nameList = countriesList.filter {
                    return $0.name.hasPrefix(keyword, caseSensitive: false)
                }
                var countryList = countriesList.filter {
                    return $0.country.hasPrefix(keyword, caseSensitive: false)
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
                    if self.loadMoreTests {
                        self.canLoadMore = result.count >= self.countItems
                        self.countItems = result.count >= self.countItems ? self.countItems : result.count
                        for index in self.startIndex...self.countItems - 1 {
                            self.displayItemsList.append(result[index])
                        }
                    } else {
                        for index in self.startIndex...result.count - 1 {
                            self.displayItemsList.append(result[index])
                        }
                    }
                } else {
                    self.canLoadMore = result.count >= self.countItems
                    self.countItems = result.count >= self.countItems ? self.countItems : result.count
                    for index in self.startIndex...self.countItems - 1 {
                        self.displayItemsList.append(result[index])
                    }
                }
            }
            
            if !self.displayItemsList.isEmpty {
                self.didSearchCountrySuccess.onNext(Model(hasSearchResult: true, searchList: self.displayItemsList))
            } else {
                self.didSearchCountryEmpty.onNext(())
            }
        }
    }
}

extension CountriesListViewModel: CountriesListProtocolOutput {
    func getCountriesListFromFile() {
        showLoading.onNext(())
        DispatchQueue.global(qos: .background).async {
            do {
                guard let fileUrl = Bundle.main.url(forResource: self.fileJsonName, withExtension: "json") else { fatalError() }
                let data = try Data(contentsOf: fileUrl)
                let countriesJson = try JSONDecoder().decode([Countries].self, from: data)
                self.countriesList = countriesJson
                self.hideLoading.onNext(())
            } catch {
                self.hideLoading.onNext(())
            }
        }
    }
    
    func loadMoreCountries() {
        startIndex = countItems
        countItems = countItems + 10
        if let result = self.searchResult {
            self.canLoadMore = result.count >= self.countItems
            DispatchQueue.global(qos: .background).async {
                self.countItems = result.count >= self.countItems ? self.countItems : result.count
                for index in self.startIndex...self.countItems - 1 {
                    self.displayItemsList.append(result[index])
                }
                self.didLoadMoreCountriesSuccess.onNext(self.displayItemsList)
            }
        }
    }
    
    func getCanLoadMore() -> Bool {
        return canLoadMore
    }
}
