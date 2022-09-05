//
//  CountriesListModels.swift
//  Countries

import UIKit

struct CountriesListModels {
    struct SearchCountry {
        let isTextEmpty: Bool
        let hasSearchResult: Bool
        let searchList: [Countries]
        
        init(isTextEmpty: Bool = false,
             hasSearchResult: Bool,
             searchList: [Countries]) {
            self.isTextEmpty = isTextEmpty
            self.hasSearchResult = hasSearchResult
            self.searchList = searchList
        }
    }
    
    enum DataLoadMore {
        struct Request { }
        struct Response {
            let loadMoreItems: [Countries]
        }
        struct ViewModel {
            let loadMoreItems: [Countries]
        }
    }
}

struct Countries: Codable {
    let country: String
    let name: String
    let _id: Int
    let coord: LatLong
    
    init(country: String,
         name: String,
         _id: Int,
         coord: LatLong) {
        self.country = country
        self.name = name
        self._id = _id
        self.coord = coord
    }
}

struct LatLong: Codable {
    let lat: Double
    let lon: Double
    
    init(lat: Double,
         lon: Double) {
        self.lat = lat
        self.lon = lon
    }
}
