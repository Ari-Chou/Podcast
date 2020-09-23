//
//  DownloadVC.swift
//  Podcasts
//
//  Created by AriCHou on 9/21/20.
//

import UIKit

class DownloadVC: UITableViewController {
    
    var episodes = UserDefaults.standard.downlodedEpisode()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = .white
        setupTableViewCell()
    }
    
    fileprivate func setupTableViewCell() {
        tableView.tableFooterView = UIView()
        let nib = UINib(nibName: "EpisodeCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "cell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       episodes = UserDefaults.standard.downlodedEpisode()
        tableView.reloadData()
    }
}

extension DownloadVC {

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 132
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(episodes.count)
        return episodes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! EpisodeCell
        cell.episode = episodes[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let contextItem = UIContextualAction(style: .normal, title: "Delete") { [self] (UIContextualAction, UIView, bool) in
            let episode = self.episodes[indexPath.row]
            episodes.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            UserDefaults.standard.deleteUserDownload(episode: episode)
        }
        let swipeActions = UISwipeActionsConfiguration(actions: [contextItem])
        return swipeActions
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let episode = episodes[indexPath.row]
        UIApplication.mainTabBarContriller()?.maxPlayerDetailView(episode: episode)
        UIApplication.mainTabBarContriller()?.tabBar.isHidden = true
    }
}
