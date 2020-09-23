//
//  MainTabBarController.swift
//  ScrollNavBar
//
//  Created by Ari Chou on 9/16/20.
//

import UIKit

class MainTabBarController: UITabBarController {

    let playerDetaileView = Bundle.main.loadNibNamed("PlayerDetailView", owner: self, options: nil)?.first as! PlayerDetailView
    
    var maxTopAnchorConstraint: NSLayoutConstraint!
    var minTopAnchorConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UINavigationBar.appearance().prefersLargeTitles = true
        tabBar.tintColor = .black
        
        let layout = UICollectionViewFlowLayout()
        let favoriteVC = FavoriteVC(collectionViewLayout: layout)
        
        viewControllers = [
            generateNavigationController(for: PodcastsSearchController(), title: "Search", image: UIImage(systemName: "magnifyingglass")!),
            generateNavigationController(for: favoriteVC, title: "Favorites", image: UIImage(systemName: "externaldrive.badge.timemachine")!),
            generateNavigationController(for: DownloadVC(), title: "Downloads", image: UIImage(systemName: "square.and.arrow.down")!),
        ]
        
        setUpPlayerDetailView()
//        perform(#selector(maxPlayerDetailView), with: nil, afterDelay: 1)
    }
    
    
    fileprivate func generateNavigationController(for rootViewController: UIViewController, title: String, image: UIImage) -> UIViewController {
        let navController = UINavigationController(rootViewController: rootViewController)
        rootViewController.navigationItem.title = title
        navController.tabBarItem.title = title
        navController.tabBarItem.image = image
        return navController
    }
    
    fileprivate func setUpPlayerDetailView() {
        view.insertSubview(playerDetaileView, belowSubview: tabBar)
        playerDetaileView.translatesAutoresizingMaskIntoConstraints = false
        
        
        maxTopAnchorConstraint = playerDetaileView.topAnchor.constraint(equalTo: view.topAnchor, constant: view.frame.height)
        maxTopAnchorConstraint.isActive = true
        
        minTopAnchorConstraint = playerDetaileView.topAnchor.constraint(equalTo: tabBar.topAnchor, constant: -64)
        
        
        playerDetaileView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        playerDetaileView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        playerDetaileView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        print(2)
    }
    
    func maxPlayerDetailView(episode: Episode?) {
        print(1)
        maxTopAnchorConstraint.isActive = true
        maxTopAnchorConstraint.constant = 0
        minTopAnchorConstraint.isActive = false
        if episode != nil {
            self.playerDetaileView.episode = episode
        }
        playerDetaileView.miniPlayerView.alpha = 0
        playerDetaileView.maxPlayerView.alpha = 1
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    func minPLayerDetailView() {
        maxTopAnchorConstraint.isActive = false
        minTopAnchorConstraint.isActive = true
        playerDetaileView.maxPlayerView.alpha = 0
        playerDetaileView.miniPlayerView.alpha = 1
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
            self.tabBar.isHidden = false
        }, completion: nil)
    }

}
