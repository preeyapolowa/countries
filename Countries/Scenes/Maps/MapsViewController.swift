//
//  MapsViewController.swift
//  Countries

import UIKit
import MapKit

protocol MapsViewControllerOutput: AnyObject {
}

final class MapsViewController: UIViewController {
    @IBOutlet weak var mkMapView: MKMapView!
    
    var interactor: MapsInteractorOutput!
    var router: MapsRouterInput!

    // MARK: - Object lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()

        let router = MapsRouter()
        router.viewController = self

        let presenter = MapsPresenter()
        presenter.viewController = self

        let interactor = MapsInteractor()
        interactor.presenter = presenter

        self.interactor = interactor
        self.router = router
    }

    // MARK: - View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupMaps()
    }
    
    // MARK: - SetupViews
    
    private func setupMaps() {
        guard let lat = interactor.lat,
              let lon = interactor.lon
        else { return }
        let annotation = MKPointAnnotation()
        let coord = CLLocationCoordinate2D(latitude: CLLocationDegrees(lat),
                                           longitude: CLLocationDegrees(lon))
        annotation.coordinate = coord
        mkMapView.addAnnotation(annotation)
        mkMapView.showAnnotations([annotation], animated: true)
        mkMapView.isZoomEnabled = true
    }

    // MARK: - Event handling

    // MARK: - Actions
    
    @IBAction private func didTapCloseButton() {
        router.dismissVC()
    }
    
    // MARK: - Private func
}

// MARK: - Display logic

extension MapsViewController: MapsViewControllerOutput {
    
}

// MARK: - Start Any Extensions
