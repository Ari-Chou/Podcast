//
//  SearchVC.swift
//  ScrollNavBar
//
//  Created by Ari Chou on 9/16/20.
//

import UIKit
import Alamofire

class PodcastsSearchController: UITableViewController {

    var podcasts = [Podcast]()
    
    var timer: Timer?
    
    let searchController = UISearchController(searchResultsController: nil)
    
//    let searchingView = Bundle.main.loadNibNamed("SearchingView", owner: self, options: nil)?.first as! UIView

    
    //MARK: -- view did load
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupNavItem()
        setupSearchBar()
    }
    
    //MARK: -- setup nav item
    fileprivate func setupNavItem() {
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    //MARK: -- search bar
    fileprivate func setupSearchBar() {
        self.definesPresentationContext = true
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
    }
    
    //MARK: -- table view
    fileprivate func setupTableView() {
        tableView.tableFooterView = UIView()
        let nib = UINib.init(nibName: "PodcastCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "cell")
    }
}

//MARK: -- extensition
extension PodcastsSearchController: UISearchBarDelegate {
    // table view
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 132
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return podcasts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! PodcastCell
        let podcast = podcasts[indexPath.row]
        cell.podcast = podcast
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = EpisodesTableViewController()
        vc.podcast = self.podcasts[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = "Please enter a Search Term."
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        return label
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.podcasts.count > 0 ? 0 : 250
    }
    
//    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        return searchingView
//    }
    
//    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return self.podcasts.isEmpty && searchController.searchBar.text?.isEmpty == false ? view.frame.height : 0
//    }
    
    
    // search bar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { (_) in
            APIService.shared.fetchPodcats(searchText: searchText) {[weak self] (podcats) in
                self?.podcasts = podcats
                self?.tableView.reloadData()
            }
        })
        
    }
}
