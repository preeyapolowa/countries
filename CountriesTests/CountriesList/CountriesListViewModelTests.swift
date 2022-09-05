//
//  CountriesListViewModelTests.swift
//  CountriesTests
//
//  Created by Preeyapol Owatsuwan on 24/8/2565 BE.
//

import XCTest
import RxSwift
@testable import Countries

class CountriesListViewModelTests: XCTestCase {
    var viewModel: CountriesListViewModel!
    let disposeBag = DisposeBag()
    
    override func setUp() {
        super.setUp()
        setupCountriesListViewModelTests()
    }
    
    override func tearDown() {
        super.tearDown()
        expectToEventually(true)
    }
    
    private func setupCountriesListViewModelTests() {
        viewModel = CountriesListViewModel()
    }
    
    // MARK: getCountriesListFromFile Tests
    
    func testGetCountriesListFromFile() {
        // Given
        
        // When
        viewModel.output.getCountriesListFromFile()
        expectToEventually(!(viewModel.countriesList?.isEmpty ?? true))
        
        // Then
        DispatchQueue.main.async {
            if let countriesJson = self.viewModel.countriesList {
                XCTAssertTrue(!countriesJson.isEmpty)
                XCTAssertEqual(countriesJson.count, 209557)
            } else {
                XCTFail("Cannot get json data from file")
            }
        }
    }
    
    // MARK: searchCountry Tests
    
    func testSearchCountryWithEmptyCountriesList() {
        // Given
        let keyword = "AU"
        
        // When
        viewModel.input.searchCountry(keyword: keyword)
        
        // Then
        viewModel
            .output
            .didKeywordEmpty
            .subscribe(onNext: {
                XCTAssertEqual(self.viewModel.searchResult?.count ?? 0, 0)
            }, onDisposed: nil).disposed(by: disposeBag)
    }
    
    func testSearchCountryWithValidNameFirstCase() {
        // Given
        let keyword = "AU"
        viewModel.output.getCountriesListFromFile()
        expectToEventually(!(viewModel.countriesList?.isEmpty ?? true))
        
        // When
        viewModel.input.searchCountry(keyword: keyword)
        expectToEventually(!(viewModel.searchResult?.isEmpty ?? true))
        
        // Then
        viewModel
            .output
            .didSearchCountrySuccess
            .subscribe(onNext: { countries in
                XCTAssertTrue(countries.hasSearchResult)
                XCTAssertFalse(countries.isTextEmpty)
                XCTAssertTrue(countries.searchList.contains { $0.name.hasPrefix(keyword, caseSensitive: false) })
                XCTAssertTrue(countries.searchList.contains { $0.country.hasPrefix(keyword, caseSensitive: false) })
            }, onDisposed: nil).disposed(by: disposeBag)
    }
    
    func testSearchCountryWithValidNameSecondCase() {
        // Given
        let keyword = "Abl"
        viewModel.output.getCountriesListFromFile()
        expectToEventually(!(viewModel.countriesList?.isEmpty ?? true))
        
        // When
        viewModel.input.searchCountry(keyword: keyword)
        expectToEventually(!(viewModel.searchResult?.isEmpty ?? true))
        
        // Then
        viewModel
            .output
            .didSearchCountrySuccess
            .subscribe(onNext: { countries in
                XCTAssertTrue(countries.hasSearchResult)
                XCTAssertFalse(countries.isTextEmpty)
                XCTAssertTrue(countries.searchList.contains { $0.name.hasPrefix(keyword) })
                XCTAssertFalse(countries.searchList.contains { $0.country.hasPrefix(keyword) })
            }, onDisposed: nil).disposed(by: disposeBag)
    }
    
    func testSearchCountryWithInValidName() {
        // Given
        let keyword = "ฟฟหกกadsadqwwqe"
        viewModel.output.getCountriesListFromFile()
        expectToEventually(!(viewModel.countriesList?.isEmpty ?? true))
        
        // When
        viewModel.input.searchCountry(keyword: keyword)
        expectToEventually((viewModel.searchResult?.isEmpty ?? false))
        
        // Then
        viewModel
            .output
            .didSearchCountrySuccess
            .subscribe(onNext: { countries in
                XCTAssertFalse(countries.hasSearchResult)
                XCTAssertFalse(countries.isTextEmpty)
                XCTAssertEqual(countries.searchList.count, 0)
            }, onDisposed: nil).disposed(by: disposeBag)
    }
    
    // MARK: getLoadMore Tests
    
    func testGetLoadMore() {
        // Given
        viewModel.loadMoreTests = true
        let keyword = "AU"
        viewModel.output.getCountriesListFromFile()
        expectToEventually(!(viewModel.countriesList?.isEmpty ?? true))
        viewModel.input.searchCountry(keyword: keyword)
        expectToEventually(!(viewModel.displayItemsList.isEmpty))
        
        // When
        viewModel.output.loadMoreCountries()
        
        // Then
        viewModel
            .output
            .didLoadMoreCountriesSuccess
            .subscribe(onNext: { coutries in
                XCTAssertEqual(coutries.count, 20)
            }, onDisposed: nil).disposed(by: disposeBag)
    }
    
    func testGetLoadMoreLastItems() {
        // Given
        viewModel.loadMoreTests = true
        let keyword = "Abl"
        viewModel.output.getCountriesListFromFile()
        expectToEventually(!(viewModel.countriesList?.isEmpty ?? true))
        viewModel.input.searchCountry(keyword: keyword)
        expectToEventually(!(viewModel.displayItemsList.isEmpty))
        
        // When
        viewModel.output.loadMoreCountries()
        
        // Then
        viewModel
            .output
            .didLoadMoreCountriesSuccess
            .subscribe(onNext: { coutries in
                XCTAssertEqual(coutries.count, 13)
                XCTAssertEqual(self.viewModel.countItems, coutries.count)
            }, onDisposed: nil).disposed(by: disposeBag)
    }
}

extension XCTest {
    func expectToEventually(_ test: @autoclosure () -> Bool, timeout: TimeInterval = 60, message: String = "") {
        let runLoop = RunLoop.current
        let timeoutDate = Date(timeIntervalSinceNow: timeout)
        repeat {
            if test() {
                return
            }
            runLoop.run(until: Date(timeIntervalSinceNow: 0.01))
        } while Date().compare(timeoutDate) == .orderedAscending // 3
        XCTFail(message)
    }
}
