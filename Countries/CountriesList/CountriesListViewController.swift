//
//  CountriesListViewController.swift
//  Countries

import UIKit

protocol CountriesListViewControllerOutput: AnyObject {
}

final class CountriesListViewController: UIViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
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
        setupViews()
    }
    
    // MARK: - SetupViews
    
    private func setupViews() {
        setupTableView()
        setupSearchBar()
    }
    
    private func setupTableView() {
        let nib = UINib(nibName: "CountriesCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "countriescell")
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func setupSearchBar() {
        
    }

    // MARK: - Event handling

    // MARK: - Actions
    
    // MARK: - Private func
}

// MARK: - Display logic

extension CountriesListViewController: CountriesListViewControllerOutput {
    
}

// MARK: - Start Any Extensions

extension CountriesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "countriescell", for: indexPath) as? CountriesCell else { return UITableViewCell() }
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}

extension CountriesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
    }
}
