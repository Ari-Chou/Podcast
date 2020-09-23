//
//  FavoriteVC.swift
//  Podcasts
//
//  Created by AriCHou on 9/20/20.
//

import UIKit

class FavoriteVC: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var savedPodcasts = [Podcast]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = .white
        setupCell()
        
        getUserSavedFavorites()
        addCollectionViewGesture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let savedPodcasts = UserDefaults.standard.savedPodcasts()
        self.savedPodcasts = savedPodcasts
        collectionView.reloadData()
        UIApplication.mainTabBarContriller()?.viewControllers?[1].tabBarItem.badgeValue = nil
    }
    
    fileprivate func setupCell() {
        let nib = UINib(nibName: "FavoriteCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "cell")
    }
    
    fileprivate func getUserSavedFavorites() {
        guard let savedData = UserDefaults.standard.data(forKey: "favoritePodcastKey") else { return }
        do {
            let savedPodcasts = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(savedData) as! [Podcast]
            self.savedPodcasts = savedPodcasts
        } catch let error {
            print("Failed to get user saved favorites", error.localizedDescription)
        }
    }
    
    fileprivate func addCollectionViewGesture() {
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(handleGesture))
        collectionView.addGestureRecognizer(gesture)
    }
    
    @objc func handleGesture(gesture: UILongPressGestureRecognizer) {
        let location = gesture.location(in: collectionView)
        guard let selectedIndexPath = collectionView.indexPathForItem(at: location) else { return }
        
        let alertController = UIAlertController(title: "This action will delete your favorite podcast?", message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: {[weak self] (_) in
            
            var savedPodcasts = UserDefaults.standard.savedPodcasts()
            
            savedPodcasts.remove(at: selectedIndexPath.item)
            self?.savedPodcasts.remove(at: selectedIndexPath.item)
            self?.collectionView.deleteItems(at: [selectedIndexPath])
            self?.savedPodcasts = savedPodcasts
            
            let deletedPodcasts = savedPodcasts
            do {
                let data = try NSKeyedArchiver.archivedData(withRootObject: deletedPodcasts, requiringSecureCoding: false)
                UserDefaults.standard.set(data, forKey: "favoritePodcastKey")
                DispatchQueue.main.async {
                    self?.collectionView.reloadData()
                }
            } catch let error {
                print("Failed to archived the data", error.localizedDescription)
            }
        }))

        alertController .addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
}

//MARK: -- extension
extension FavoriteVC {

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return savedPodcasts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! FavoriteCell
        cell.podcast = savedPodcasts[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 3 * 16) / 2
        return CGSize(width: width, height: width + 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let episodeVC = EpisodesTableViewController()
        episodeVC.podcast = self.savedPodcasts[indexPath.item]
        navigationController?.pushViewController(episodeVC, animated: true)
    }
}
