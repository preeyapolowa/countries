//
//  MapsViewModel.swift
//  Countries
//
//  Created by Preeyapol Owatsuwan on 5/9/2565 BE.
//

import Foundation
import RxSwift

protocol MapsViewModelProtocolInput {
}

protocol MapsViewModelProtocolOutput {
    func getLat() -> Double
    func getLon() -> Double
}

protocol MapsViewModelProtocol: MapsViewModelProtocolInput, MapsViewModelProtocolOutput {
    var input: MapsViewModelProtocolInput { get }
    var output: MapsViewModelProtocolOutput { get }
}

class MapsViewModel: MapsViewModelProtocol {
    var input: MapsViewModelProtocolInput { return self }
    var output: MapsViewModelProtocolOutput { return self }
    
    let lat: Double
    let lon: Double
    init(lat: Double,
         lon: Double) {
        self.lat = lat
        self.lon = lon
    }
}

extension MapsViewModel: MapsViewModelProtocolInput {
    
}

extension MapsViewModel: MapsViewModelProtocolOutput {
    func getLat() -> Double {
        return lat
    }
    
    func getLon() -> Double {
        return lon
    }
}
