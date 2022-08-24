//
//  CountriesListModels.swift
//  Countries

import UIKit

struct CountriesListModels {
    enum CountriesListFromFile {
        struct Request { }
        struct Response { }
        struct ViewModel { }
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
