//
//  MapsViewController.swift
//  Countries

import UIKit
import MapKit

class MapsViewController: UIViewController {
    @IBOutlet weak var mkMapView: MKMapView!

    // MARK: - View lifecycle

    var viewModel: MapsViewModel? = nil {
        didSet {
            self.bindViewModel()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMaps()
    }
    
    // MARK: - SetupViews
    
    func config(viewModel: MapsViewModel) {
        self.viewModel = viewModel
    }
    
    private func setupMaps() {
        guard let lat = viewModel?.output.getLat(),
              let lon = viewModel?.output.getLat()
        else { return }
        let annotation = MKPointAnnotation()
        let coord = CLLocationCoordinate2D(latitude: CLLocationDegrees(lat),
                                           longitude: CLLocationDegrees(lon))
        annotation.coordinate = coord
        mkMapView.addAnnotation(annotation)
        mkMapView.showAnnotations([annotation], animated: true)
        mkMapView.isZoomEnabled = true
    }

    // MARK: - Actions
    
    @IBAction private func didTapCloseButton() {
        dismissVC()
    }
}

// MARK: - Start Any Extensions

extension MapsViewController {
    private func dismissVC() {
        dismiss(animated: true)
    }
}

extension MapsViewController {
    private func bindViewModel() { }
}
