//
//  CountriesListViewController.swift
//  Countries

import UIKit

protocol CountriesListViewControllerOutput: AnyObject {
    func displayCountriesListFromFile(viewModel: CountriesListModels.CountriesListFromFile.ViewModel)
}

final class CountriesListViewController: UIViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var interactor: CountriesListInteractorOutput!
    var router: CountriesListRouterInput!

    private let activityView = UIActivityIndicatorView(style: .large)

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
        getCountriesListFromFile()
    }
    
    // MARK: - SetupViews
    
    private func setupViews() {
        setupTableView()
        setupSearchBar()
        setupActivityIndicator()
    }
    
    private func setupTableView() {
        let nib = UINib(nibName: "CountriesCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "countriescell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isHidden = true
    }
    
    private func setupSearchBar() {
        
    }
    
    private func setupActivityIndicator() {
        activityView.center = self.view.center
        activityView.startAnimating()
        activityView.isHidden = true
        view.addSubview(activityView)
    }

    // MARK: - Event handling

    private func getCountriesListFromFile() {
        activityView.isHidden = false
        interactor.getCountriesListFromFile(request: CountriesListModels.CountriesListFromFile.Request())
    }
    
    // MARK: - Actions
    
    // MARK: - Private func
}

// MARK: - Display logic

extension CountriesListViewController: CountriesListViewControllerOutput {
    func displayCountriesListFromFile(viewModel: CountriesListModels.CountriesListFromFile.ViewModel) {
        activityView.isHidden = true
        tableView.isHidden = false
    }
}

// MARK: - Start Any Extensions

extension CountriesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "countriescell", for: indexPath) as? CountriesCell else { return UITableViewCell() }
        cell.selectionStyle = .none
        cell.updateUI()
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
}

extension CountriesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
    }
}
