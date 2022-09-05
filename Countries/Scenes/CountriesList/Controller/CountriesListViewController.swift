//
//  CountriesListViewController.swift
//  Countries

import UIKit
import RxSwift

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
    
    var viewModel = CountriesListViewModel()
    var disposeBag = DisposeBag()
    
    private let activityPageView = UIActivityIndicatorView(style: .large)
    private let activityContentView = UIActivityIndicatorView(style: .large)
    private let loadMoreSpinner = UIActivityIndicatorView(style: .medium)
    private var loadingBgView: UIView!
    private var searchList: [Countries]?
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        setupViews()
        viewModel.output.getCountriesListFromFile()
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
        loadMoreSpinner.startAnimating()
        loadMoreSpinner.tintColor = .systemGray3
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
    
    // MARK: - Actions
    
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
        guard let data = searchList?[indexPath.row] else { return }
        navigateToMaps(lat: data.coord.lat , lon: data.coord.lon)
    }
}

extension CountriesListViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        let threshold = maximumOffset - 120
        if currentOffset > threshold && viewModel.output.getCanLoadMore() {
            tableView.tableFooterView = loadMoreSpinner
            viewModel.output.loadMoreCountries()
        }
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
            perform(#selector(handleSearchCountry), with: nil, afterDelay: 1)
        }
        return true
    }
    
    @objc private func handleSearchCountry() {
        viewModel.input.searchCountry(keyword: searchBar.text ?? "")
    }
}

extension CountriesListViewController {
    func navigateToMaps(lat: Double, lon: Double) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Maps", bundle: nil)
        guard let vc = storyBoard.instantiateViewController(withIdentifier: "MapsViewController") as? MapsViewController else { return }
        let viewModel = MapsViewModel(lat: lat, lon: lon)
        vc.config(viewModel: viewModel)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
}

extension CountriesListViewController {
    private func bindViewModel() {
        showLoading()
        hideLoading()
        didKeywordEmpty()
        didSearchCountrySuccess()
        didSearchCountryEmpty()
        didLoadMoreCountriesSuccess()
    }
    
    private func showLoading() {
        self.viewModel
            .output
            .showLoading
            .subscribe(onNext: {
                DispatchQueue.main.async {
                    self.loadingBgView.isHidden = false
                }
            }, onDisposed: nil).disposed(by: self.disposeBag)
    }
    
    private func hideLoading() {
        self.viewModel
            .output
            .hideLoading
            .subscribe(onNext: {
                DispatchQueue.main.async {
                    self.loadingBgView.isHidden = true
                }
            }, onDisposed: nil).disposed(by: self.disposeBag)
    }
    
    private func didKeywordEmpty() {
        self.viewModel
            .output
            .didKeywordEmpty
            .subscribe(onNext: {
                self.emptyListLabel.isHidden = true
                self.tableView.isHidden = true
            }, onDisposed: nil).disposed(by: disposeBag)
    }
    
    private func didSearchCountrySuccess() {
        self.viewModel
            .output
            .didSearchCountrySuccess
            .subscribe(onNext: { coutries in
                DispatchQueue.main.async {
                    self.activityContentView.isHidden = true
                    self.tableView.setContentOffset(.zero, animated: false)
                    self.searchList = coutries.searchList
                    self.tableView.reloadData()
                    self.tableView.isHidden = false
                }
            }, onDisposed: nil).disposed(by: disposeBag)
    }
    
    private func didSearchCountryEmpty() {
        self.viewModel
            .output
            .didSearchCountryEmpty
            .subscribe(onNext: {
                self.emptyListLabel.isHidden = false
            }, onDisposed: nil).disposed(by: disposeBag)
    }
    
    private func didLoadMoreCountriesSuccess() {
        self.viewModel
            .output
            .didLoadMoreCountriesSuccess
            .subscribe(onNext: { coutries in
                DispatchQueue.main.async {
                    self.tableView.tableFooterView = nil
                    self.searchList = coutries
                    self.tableView.reloadData()
                }
            }, onDisposed: nil).disposed(by: disposeBag)
    }
}
