//
//  EpisodesTableViewController.swift
//  ScrollNavBar
//
//  Created by Ari Chou on 9/17/20.
//

import UIKit

class EpisodesTableViewController: UITableViewController {
    
    var episodes = [Episode]()
    
    var podcast: Podcast? {
        didSet {
            navigationItem.title = podcast?.trackName
            // fetch the feed item
            DispatchQueue.global(qos: .background).async {
                APIService.shared.fetchEpisodes(feedURL: self.podcast?.feedUrl) { (episodes) in
                    self.episodes = episodes
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    //MARK: -- view did load
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupNaviBarItem()
    }
    
    //MARK: -- setup tabel view
    fileprivate func setupTableView() {
        tableView.tableFooterView = UIView()
        let nib = UINib(nibName: "EpisodeCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "cell")
    }
    
    fileprivate func setupNaviBarItem() {
        
        let savedPodcasts = UserDefaults.standard.savedPodcasts()
        
        let areadyFavorited = savedPodcasts.firstIndex(where: {$0.trackName == self.podcast?.trackName
            && $0.artistName == self.podcast?.artistName
        }) == nil
        
        if areadyFavorited {
            navigationItem.rightBarButtonItems = [
                UIBarButtonItem(image: UIImage(systemName: "arrow.clockwise.circle"), style: .plain, target: self, action: #selector(handleFetchUserSavedFavorites)),
                UIBarButtonItem(image: UIImage(systemName: "plus.square"), style: .plain, target: self, action: #selector(handleNavAdd)),
            ]
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "externaldrive.fill.badge.checkmark"), style: .plain, target: self, action: nil)
        }
    }

    //MARK: -- save user favorite to user defaults
    @objc func handleNavAdd() {
        guard let podcast = podcast else { return }
        
        guard let savedPodcastsData = UserDefaults.standard.data(forKey: "favoritePodcastKey") else { return }
        
        do {
            guard let savedPodcasts = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(savedPodcastsData) as? [Podcast] else { return }
            var podcastList = savedPodcasts
            podcastList.append(podcast)
            
            do {
                let data = try NSKeyedArchiver.archivedData(withRootObject: podcastList, requiringSecureCoding: false)
                UserDefaults.standard.set(data, forKey: "favoritePodcastKey")
                navigationItem.rightBarButtonItems = [UIBarButtonItem(image: UIImage(systemName: "externaldrive.fill.badge.checkmark"), style: .plain, target: self, action: nil)]
                heightLightTabBarItem()
            } catch let error {
                print("Failed to archived the data", error.localizedDescription)
            }

        } catch let error {
            print("Failed to get user saved podcasts", error.localizedDescription)
        }
    }
    
    @objc func handleFetchUserSavedFavorites() {
        guard let data = UserDefaults.standard.data(forKey: "favoritePodcastKey") else { return }
        
        do {
            let savedPodcasts = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [Podcast]
            savedPodcasts?.forEach({ (podcast) in
                
            })
        }catch let error {
            print("Failed to get the user saved favorites", error.localizedDescription)
        }
    }
    
    //height the main tab bar item
    func heightLightTabBarItem() {
        UIApplication.mainTabBarContriller()?.viewControllers?[1].tabBarItem.badgeValue = "New"
    }
}

//MARK: -- extension
extension EpisodesTableViewController {
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let activeIndicatorView = UIActivityIndicatorView(style: .large)
        activeIndicatorView.color = .darkGray
        activeIndicatorView.startAnimating()
        return activeIndicatorView
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return episodes.isEmpty ? 200 : 0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 132
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return episodes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! EpisodeCell
//      cell.backgroundColor = UIColor(red: CGFloat(arc4random_uniform(255)) / 255.0, green: CGFloat(arc4random_uniform(255)) / 255.0, blue: CGFloat(arc4random_uniform(255)) / 255.0, alpha: 1)
        let episode = episodes[indexPath.row]
        cell.episode = episode
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let episode = episodes[indexPath.row]
        let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as! MainTabBarController
            mainTabBarController.maxPlayerDetailView(episode: episode)
            mainTabBarController.tabBar.isHidden = true
    }
    
    // swipe to download the episode
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let contextItem = UIContextualAction(style: .normal, title: "Download") { [self] (UIContextualAction, UIView, bool) in
            let episode = self.episodes[indexPath.row]
            UserDefaults.standard.downloadEpisode(episode: episode)
            APIService.shared.downloadEpisodeToLocal(episode: episode)
        }
        let swipeActions = UISwipeActionsConfiguration(actions: [contextItem])
        return swipeActions
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let downloadAction = UITableViewRowAction(style: .normal, title: "Download") { (_, _) in
           
        }
        
        return [downloadAction]
    }
}


