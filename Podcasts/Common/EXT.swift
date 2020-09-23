//
//  EXT.swift
//  ScrollNavBar
//
//  Created by Ari Chou on 9/17/20.
//

import UIKit
import AVKit

extension Date {
    public func dateFormatter(for date: Date) -> String {
        let dateFormmater = DateFormatter()
        dateFormmater.dateFormat = "MMM dd, yyyy"
        let dateString = dateFormmater.string(from: date)
        return dateString
    }
}

extension String {
    public func secureURL() -> String {
        return self.contains("https") ? self : self.replacingOccurrences(of: "http", with: "https")
    }
}

extension CMTime {
    public func toDisplayString() -> String {
        if CMTimeGetSeconds(self).isNaN {
            return "--:--"
        }
        let totalSecends = Int(CMTimeGetSeconds(self))
        let seconds = totalSecends % 60
        let minutes = totalSecends / 60
        let timeStringFormat = String(format: "%02d:%02d", minutes, seconds)
        return timeStringFormat
    }
}


extension UIView {
    public func initFromNib(name: String) -> UIView {
        return Bundle.main.loadNibNamed(name, owner: self, options: nil)?.first as! UIView
    }
}


extension UIApplication {
    static func mainTabBarContriller() -> MainTabBarController? {
        return shared.keyWindow?.rootViewController as? MainTabBarController
    }
}


extension UserDefaults {
    
    static let favoritedPodcastKey = "favoritePodcastKey"
    static let downloadEpisodeKey = "downloadEpisodeKey"
    
    //MARK: --  save the episode to user default
    func downloadEpisode(episode: Episode) {
        do {
            var episodeList = downlodedEpisode()
            episodeList.append(episode)
            
            let data = try JSONEncoder().encode(episodeList)
            UserDefaults.standard.setValue(data, forKey: UserDefaults.downloadEpisodeKey)
        } catch let error {
            print("Failed to encode the episode", error.localizedDescription)
        }
    }
    
    //MARK: -- get the user saved episode and put in download page (download the episode and put in download page)
    func downlodedEpisode() -> [Episode] {
        guard let downloadEpisodeData = UserDefaults.standard.data(forKey: UserDefaults.downloadEpisodeKey) else { return []}
        do {
            let episodes = try JSONDecoder().decode([Episode].self, from: downloadEpisodeData)
            return episodes
        } catch let error {
            print("Failed to decode the episodes", error.localizedDescription)
        }
        return []
    }
    
    //MARK: -- delete user downoad from user default
    func deleteUserDownload(episode: Episode) {
        var userDownloadEpisodes = downlodedEpisode()
        let fileteredEpisodes = userDownloadEpisodes.filter { (e) -> Bool in
            return e.title != episode.title
        }
        
        do {
            let data = try JSONEncoder().encode(fileteredEpisodes)
            UserDefaults.standard.setValue(data, forKey: UserDefaults.downloadEpisodeKey)
        } catch let error {
            print("Failed to encode filetered episode to user default", error)
        }
    }
    
    //MARK: --  get saved podcasts
    func savedPodcasts() -> [Podcast] {
        guard let savedPodcastsData = UserDefaults.standard.data(forKey: UserDefaults.favoritedPodcastKey) else { return [] }
        var savedPodcastList = [Podcast]()
        do {
            let savedPodcasts = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(savedPodcastsData) as? [Podcast]
            guard let savedPodcast = savedPodcasts else { return []}
           savedPodcastList = savedPodcast
        } catch let error {
            print("Failed to get user saved podcasts", error.localizedDescription)
        }
        return savedPodcastList
    }
}


