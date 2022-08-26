//
//  CountriesListPresenterTests.swift
//  CountriesTests
//
//  Created by Preeyapol Owatsuwan on 25/8/2565 BE.
//

import XCTest
@testable import Countries

class CountriesListPresenterTests: XCTestCase {
    var presenter: CountriesListPresenter!
    var viewControllerSpy: CountriesListViewControllerSpy!
    
    override func setUp() {
        super.setUp()
        setupCountriesListPresenterTests()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    private func setupCountriesListPresenterTests() {
        presenter = CountriesListPresenter()
        viewControllerSpy = CountriesListViewControllerSpy()
        presenter.viewController = viewControllerSpy
    }
    
    final class CountriesListViewControllerSpy: CountriesListViewControllerOutput {
        var displayCountriesListFromFileCalled = false
        var displaySearchCountryCalled = false
        var displayDataLoadMoreCalled = false
        
        var displayCountriesListFromFileViewModel: CountriesListModels.CountriesListFromFile.ViewModel!
        var displaySearchCountryViewModel: CountriesListModels.SearchCountry.ViewModel!
        var displayDataLoadMoreViewModel: CountriesListModels.DataLoadMore.ViewModel!
        
        func displayCountriesListFromFile(viewModel: CountriesListModels.CountriesListFromFile.ViewModel) {
            displayCountriesListFromFileCalled = true
            displayCountriesListFromFileViewModel = viewModel
        }
        
        func displaySearchCountry(viewModel: CountriesListModels.SearchCountry.ViewModel) {
            displaySearchCountryCalled = true
            displaySearchCountryViewModel = viewModel
        }
        
        func displayDataLoadMore(viewModel: CountriesListModels.DataLoadMore.ViewModel) {
            displayDataLoadMoreCalled = true
            displayDataLoadMoreViewModel = viewModel
        }
    }
    
    // MARK: - presentCountriesListFromFile Tests
    
    func testPresentCountriesListFromFile() {
        // Given
        let response = CountriesListModels.CountriesListFromFile.Response()
        
        // When
        presenter.presentCountriesListFromFile(response: response)
        
        // Then
        XCTAssertTrue(viewControllerSpy.displayCountriesListFromFileCalled)
    }
    
    // MARK: - presentSearchCountry Tests
    
    func testPresentSearchCountryWithSuccessCase() {
        // Given
        typealias Response = CountriesListModels.SearchCountry.Response
        let searchList = [Countries(country: "Test", name: "Test", _id: 1, coord: LatLong(lat: 0.0, lon: 0.0))]
        let response = Response(
            isTextEmpty: false,
            hasSearchResult: true,
            searchList: searchList)

        // When
        presenter.presentSearchCountry(response: response)
        
        // Then
        XCTAssertTrue(viewControllerSpy.displaySearchCountryCalled)
        if let viewModel = viewControllerSpy.displaySearchCountryViewModel {
            switch viewModel.data {
            case .success(let countries):
                if let first = countries.first,
                   let searchFirst = searchList.first {
                    XCTAssertEqual(first.country, searchFirst.country)
                    XCTAssertEqual(first.name, searchFirst.name)
                    XCTAssertEqual(first._id, searchFirst._id)
                    XCTAssertEqual(first.coord.lat, searchFirst.coord.lat)
                    XCTAssertEqual(first.coord.lon, searchFirst.coord.lon)
                } else {
                    XCTFail("countries should have data")
                }
            default: XCTFail("ViewModel should be success")
            }
        } else {
            XCTFail("ViewModel is nil")
        }
    }
    
    func testPresentSearchCountryWithEmptyTextCase() {
        // Given
        typealias Response = CountriesListModels.SearchCountry.Response
        let response = Response(
            isTextEmpty: true,
            hasSearchResult: false,
            searchList: [])

        // When
        presenter.presentSearchCountry(response: response)
        
        // Then
        XCTAssertTrue(viewControllerSpy.displaySearchCountryCalled)
        if let viewModel = viewControllerSpy.displaySearchCountryViewModel {
            XCTAssertTrue(XCTAssertEnumCase(viewModel.data, .searchTextEmpty))
        } else {
            XCTFail("ViewModel is nil")
        }
    }
    
    func testPresentSearchCountryWithEmptyListCase() {
        // Given
        typealias Response = CountriesListModels.SearchCountry.Response
        let response = Response(
            isTextEmpty: false,
            hasSearchResult: false,
            searchList: [])

        // When
        presenter.presentSearchCountry(response: response)
        
        // Then
        XCTAssertTrue(viewControllerSpy.displaySearchCountryCalled)
        if let viewModel = viewControllerSpy.displaySearchCountryViewModel {
            XCTAssertTrue(XCTAssertEnumCase(viewModel.data, .emptyList))
        } else {
            XCTFail("ViewModel is nil")
        }
    }


    // MARK: - presentDataLoadMore Tests
    
    func testPresentDataLoadMore() {
        // Given
        let countries = [Countries(country: "Test", name: "Test", _id: 1, coord: LatLong(lat: 0.0, lon: 0.0))]
        let response = CountriesListModels.DataLoadMore.Response(loadMoreItems: countries)
        
        // When
        presenter.presentDataLoadMore(response: response)
        
        // Then
        XCTAssertTrue(viewControllerSpy.displayDataLoadMoreCalled)
        if let viewModel = viewControllerSpy.displayDataLoadMoreViewModel {
            if let first = viewModel.loadMoreItems.first,
               let searchFirst = countries.first {
                XCTAssertEqual(first.country, searchFirst.country)
                XCTAssertEqual(first.name, searchFirst.name)
                XCTAssertEqual(first._id, searchFirst._id)
                XCTAssertEqual(first.coord.lat, searchFirst.coord.lat)
                XCTAssertEqual(first.coord.lon, searchFirst.coord.lon)
            } else {
                XCTFail("countries should have data")
            }
        } else {
            XCTFail("ViewModel is nil")
        }
    }
}

extension XCTest {
    func XCTAssertEnumCase(_ testValue: CountriesListModels.SearchCountry.SearchStatus,
                           _ expectedValue: CountriesListModels.SearchCountry.SearchStatus) -> Bool {
        switch (testValue, expectedValue) {
        case (.searchTextEmpty, .searchTextEmpty):
            return true
        case (.emptyList, .emptyList):
            return true
        default:
            return false
        }
    }
}
