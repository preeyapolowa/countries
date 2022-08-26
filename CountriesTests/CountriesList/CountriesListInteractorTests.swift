//
//  CountriesListInteractorTests.swift
//  CountriesTests
//
//  Created by Preeyapol Owatsuwan on 24/8/2565 BE.
//

import XCTest
@testable import Countries

class CountriesListInteractorTests: XCTestCase {
    var interactor: CountriesListInteractor!
    var presenterSpy: CoutriesListPresenterSpy!
    
    override func setUp() {
        super.setUp()
        setupCountriesListInteractorTests()
    }
    
    override func tearDown() {
        super.tearDown()
        expectToEventually(true)
    }
    
    private func setupCountriesListInteractorTests() {
        interactor = CountriesListInteractor()
        presenterSpy = CoutriesListPresenterSpy()
        interactor.presenter = presenterSpy
    }
    
    final class CoutriesListPresenterSpy: CountriesListPresenterOutput {
        var presentCountriesListFromFileCalled = false
        var presentSearchCountryCalled = false
        var presentDataLoadMoreCalled = false
        
        var presentCountriesListFromFileResponse: CountriesListModels.CountriesListFromFile.Response!
        var presentSearchCountryResponse: CountriesListModels.SearchCountry.Response!
        var presentDataLoadMoreResponse: CountriesListModels.DataLoadMore.Response!
        
        func presentCountriesListFromFile(response: CountriesListModels.CountriesListFromFile.Response) {
            presentCountriesListFromFileCalled = true
            presentCountriesListFromFileResponse = response
        }
        
        func presentSearchCountry(response: CountriesListModels.SearchCountry.Response) {
            presentSearchCountryCalled = true
            presentSearchCountryResponse = response
        }
        
        func presentDataLoadMore(response: CountriesListModels.DataLoadMore.Response) {
            presentDataLoadMoreCalled = true
            presentDataLoadMoreResponse = response
        }
    }
    
    // MARK: getCountriesListFromFile Tests
    
    func testGetCountriesListFromFile() {
        // Given
        let request = CountriesListModels.CountriesListFromFile.Request()
        
        // When
        interactor.getCountriesListFromFile(request: request)
        expectToEventually(presenterSpy.presentCountriesListFromFileCalled)
        
        // Then
        DispatchQueue.main.async {
            XCTAssertTrue(self.presenterSpy.presentCountriesListFromFileCalled)
            if let countriesJson = self.interactor.countriesList {
                XCTAssertEqual(countriesJson.count, 209557)
            } else {
                XCTFail("Cannot get json data from file")
            }
        }
    }

    // MARK: searchCountry Tests

    func testSearchCountryWithEmptyCountriesList() {
        // Given
        let searchCountryRequest = CountriesListModels.SearchCountry.Request(keyword: "AU")
        
        // When
        interactor.searchCountry(request: searchCountryRequest)
        
        XCTAssertTrue(presenterSpy.presentSearchCountryCalled)
        if let response = presenterSpy.presentSearchCountryResponse {
            XCTAssertFalse(response.hasSearchResult)
            XCTAssertFalse(response.isTextEmpty)
            XCTAssertEqual(response.searchList.count, 0)
        } else {
            XCTFail("Response is nil")
        }
    }
    
    func testSearchCountryWithValidNameFirstCase() {
        // Given
        let keyword = "AU"
        let request = CountriesListModels.CountriesListFromFile.Request()
        let searchCountryRequest = CountriesListModels.SearchCountry.Request(keyword: keyword)
        interactor.getCountriesListFromFile(request: request)
        expectToEventually(presenterSpy.presentCountriesListFromFileCalled)
        
        // When
        interactor.searchCountry(request: searchCountryRequest)
        expectToEventually(presenterSpy.presentSearchCountryCalled)
        
        
        // Then
        XCTAssertTrue(presenterSpy.presentSearchCountryCalled)
        if let response = presenterSpy.presentSearchCountryResponse {
            XCTAssertTrue(response.hasSearchResult)
            XCTAssertFalse(response.isTextEmpty)
            XCTAssertTrue(response.searchList.contains { $0.name.hasPrefix(keyword, caseSensitive: false) })
            XCTAssertTrue(response.searchList.contains { $0.country.hasPrefix(keyword, caseSensitive: false) })
        } else {
            XCTFail("Response is nil")
        }
    }
    
    func testSearchCountryWithValidNameSecondCase() {
        // Given
        let keyword = "Abl"
        let request = CountriesListModels.CountriesListFromFile.Request()
        let searchCountryRequest = CountriesListModels.SearchCountry.Request(keyword: keyword)
        interactor.getCountriesListFromFile(request: request)
        
        // When
        expectToEventually(presenterSpy.presentCountriesListFromFileCalled)
        interactor.searchCountry(request: searchCountryRequest)
        expectToEventually(presenterSpy.presentSearchCountryCalled)
        
        // Then
        XCTAssertTrue(presenterSpy.presentSearchCountryCalled)
        if let response = presenterSpy.presentSearchCountryResponse {
            XCTAssertTrue(response.hasSearchResult)
            XCTAssertFalse(response.isTextEmpty)
            XCTAssertTrue(response.searchList.contains { $0.name.hasPrefix(keyword) })
            XCTAssertFalse(response.searchList.contains { $0.country.hasPrefix(keyword) })
        } else {
            XCTFail("Response is nil")
        }
    }
    
    func testSearchCountryWithInValidName() {
        // Given
        let keyword = "ฟฟหกกadsadqwwqe"
        let request = CountriesListModels.CountriesListFromFile.Request()
        let searchCountryRequest = CountriesListModels.SearchCountry.Request(keyword: keyword)
        interactor.getCountriesListFromFile(request: request)
        
        // When
        expectToEventually(presenterSpy.presentCountriesListFromFileCalled)
        interactor.searchCountry(request: searchCountryRequest)
        expectToEventually(presenterSpy.presentSearchCountryCalled)
        
        // Then
        XCTAssertTrue(presenterSpy.presentSearchCountryCalled)
        if let response = presenterSpy.presentSearchCountryResponse {
            XCTAssertFalse(response.hasSearchResult)
            XCTAssertFalse(response.isTextEmpty)
            XCTAssertEqual(response.searchList.count, 0)
        } else {
            XCTFail("Response is nil")
        }
    }

    // MARK: getLoadMore Tests
    
    func testGetLoadMore() {
        // Given
        interactor.loadMoreTests = true
        let keyword = "AU"
        let request = CountriesListModels.CountriesListFromFile.Request()
        let searchCountryRequest = CountriesListModels.SearchCountry.Request(keyword: keyword)
        let loadMoreRequest = CountriesListModels.DataLoadMore.Request()
        interactor.getCountriesListFromFile(request: request)
        expectToEventually(presenterSpy.presentCountriesListFromFileCalled)
        interactor.searchCountry(request: searchCountryRequest)
        expectToEventually(presenterSpy.presentSearchCountryCalled)
        
        // When
        interactor.getDataLoadMore(request: loadMoreRequest)
        expectToEventually(presenterSpy.presentDataLoadMoreCalled)
        
        // Then
        XCTAssertTrue(presenterSpy.presentDataLoadMoreCalled)
        if let response = presenterSpy.presentDataLoadMoreResponse {
            XCTAssertEqual(response.loadMoreItems.count, 20)
        } else {
            XCTFail("Response is nil")
        }
    }
    
    func testGetLoadMoreLastItems() {
        // Given
        interactor.loadMoreTests = true
        let keyword = "Abl"
        let request = CountriesListModels.CountriesListFromFile.Request()
        let searchCountryRequest = CountriesListModels.SearchCountry.Request(keyword: keyword)
        let loadMoreRequest = CountriesListModels.DataLoadMore.Request()
        interactor.getCountriesListFromFile(request: request)
        expectToEventually(presenterSpy.presentCountriesListFromFileCalled)
        interactor.searchCountry(request: searchCountryRequest)
        expectToEventually(presenterSpy.presentSearchCountryCalled)
        
        // When
        interactor.getDataLoadMore(request: loadMoreRequest)
        expectToEventually(presenterSpy.presentDataLoadMoreCalled)
        
        // Then
        XCTAssertTrue(presenterSpy.presentDataLoadMoreCalled)
        if let response = presenterSpy.presentDataLoadMoreResponse {
            XCTAssertEqual(response.loadMoreItems.count, 13)
            XCTAssertEqual(interactor.countItems, response.loadMoreItems.count)
        } else {
            XCTFail("Response is nil")
        }
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
