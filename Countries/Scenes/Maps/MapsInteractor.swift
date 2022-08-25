//
//  MapsInteractor.swift
//  Countries

import UIKit

protocol MapsInteractorOutput: AnyObject {
    var lat: Double? { get set }
    var lon: Double? { get set }
}

final class MapsInteractor: MapsInteractorOutput {
    var presenter: MapsPresenterOutput!
    // MARK: - Business logic
    
    var lat: Double?
    var lon: Double?
}
