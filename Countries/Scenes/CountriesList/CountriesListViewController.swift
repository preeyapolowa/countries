//
//  CountriesListViewController.swift
//  Countries

import UIKit

protocol CountriesListViewControllerOutput: AnyObject {
    func displayCountriesListFromFile(viewModel: CountriesListModels.CountriesListFromFile.ViewModel)
    func displaySearchCountry(viewModel: CountriesListModels.SearchCountry.ViewModel)
}

final class CountriesListViewController: UIViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    lazy var emptyListLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "No result"
        label.textColor = .systemGray3
        label.font = UIFont.systemFont(ofSize: 32, weight: .heavy)
        return label
    }()
    
    var interactor: CountriesListInteractorOutput!
    var router: CountriesListRouterInput!
    
    private let activityPageView = UIActivityIndicatorView(style: .large)
    private let activityContentView = UIActivityIndicatorView(style: .large)
    private var loadingBgView: UIView!
    private var searchList: [Countries]?
    
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
        setupPageLoading()
        setupContentLoading()
        setupEmptyList()
    }
    
    private func setupTableView() {
        let nib = UINib(nibName: "CountriesCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "countriescell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isHidden = true
    }
    
    private func setupSearchBar() {
        searchBar.delegate = self
    }
    
    private func setupPageLoading() {
        loadingBgView = UIView(frame: view.frame)
        activityPageView.color = .white
        activityPageView.center = self.view.center
        activityPageView.startAnimating()
        loadingBgView.isHidden = true
        loadingBgView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        loadingBgView.addSubview(activityPageView)
        view.addSubview(loadingBgView)
    }
    
    private func setupContentLoading() {
        activityContentView.color = .gray
        activityContentView.center = self.view.center
        activityContentView.startAnimating()
        activityContentView.isHidden = true
        view.addSubview(activityContentView)
    }
    
    private func setupEmptyList() {
        emptyListLabel.isHidden = true
        view.addSubview(emptyListLabel)
        emptyListLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        emptyListLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    // MARK: - Event handling
    
    private func getCountriesListFromFile() {
        loadingBgView.isHidden = false
        interactor.getCountriesListFromFile(request: CountriesListModels.CountriesListFromFile.Request())
    }
    
    private func searchCountry(keyword: String) {
        let request = CountriesListModels.SearchCountry.Request(keyword: keyword)
        interactor.searchCountry(request: request)
    }
    
    // MARK: - Actions
    
    // MARK: - Private func
}

// MARK: - Display logic

extension CountriesListViewController: CountriesListViewControllerOutput {
    func displayCountriesListFromFile(viewModel: CountriesListModels.CountriesListFromFile.ViewModel) {
        loadingBgView.isHidden = true
    }
    
    func displaySearchCountry(viewModel: CountriesListModels.SearchCountry.ViewModel) {
        activityContentView.isHidden = true
        switch viewModel.data {
        case .success(let searchList):
            self.searchList = searchList
            tableView.reloadData()
            tableView.isHidden = false
        case .searchTextEmpty:
            emptyListLabel.isHidden = true
            tableView.isHidden = true
        case .emptyList:
            emptyListLabel.isHidden = false
        }
    }
}

// MARK: - Start Any Extensions

extension CountriesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "countriescell", for: indexPath) as? CountriesCell,
              let data = searchList?[indexPath.row] else { return UITableViewCell() }
        let model = CountriesCellModel(
            country: data.country,
            name: data.name,
            lat: data.coord.lat,
            long: data.coord.lon)
        cell.selectionStyle = .none
        cell.updateUI(model: model)
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

extension CountriesListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            activityContentView.isHidden = true
            tableView.isHidden = true
            emptyListLabel.isHidden = true
        }
    }


    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text != "\n" {
            activityContentView.isHidden = false
            tableView.isHidden = true
            emptyListLabel.isHidden = true
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(handleSearchCountry), object: nil)
            perform(#selector(handleSearchCountry), with: nil, afterDelay: 0.5)
        }
        return true
    }
    
    @objc private func handleSearchCountry(keyword: String) {
        searchCountry(keyword: searchBar.text ?? "")
    }
}
