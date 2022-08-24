//
//  CountriesListViewController.swift
//  Countries

import UIKit

protocol CountriesListViewControllerOutput: AnyObject {
}

final class CountriesListViewController: UIViewController {
    var interactor: CountriesListInteractorOutput!
    var router: CountriesListRouterInput!

    // MARK: - Object lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()

        let router = CountriesListRouter()
        router.viewController = self

        let presenter = CountriesListPresenter()
        presenter.viewController = self

        let interactor = CountriesListInteractor()
        interactor.presenter = presenter

        self.interactor = interactor
        self.router = router
    }

    // MARK: - View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - SetupViews

    // MARK: - Event handling

    // MARK: - Actions
    
    // MARK: - Private func
}

// MARK: - Display logic

extension CountriesListViewController: CountriesListViewControllerOutput {
    
}

// MARK: - Start Any Extensions
