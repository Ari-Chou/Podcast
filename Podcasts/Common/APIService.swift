//
//  APIService.swift
//  ScrollNavBar
//
//  Created by Ari Chou on 9/17/20.
//

import UIKit
import Alamofire
import FeedKit

class APIService {
    static let shared = APIService()
    
    private let podcastURL = "https://itunes.apple.com/search"
    
    //MARK: -- get podcasts
    public func fetchPodcats(searchText: String, completionHandler: @escaping ([Podcast]) -> ()) {
       
        let parameters = ["term" : searchText, "media": "podcast"]
        
        AF.request(podcastURL, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil).response {(responseData) in
            if let error = responseData.error {
                print("Failed to get response", error.localizedDescription)
            }
            guard let data = responseData.data else { return }
            
            do {
                let searchResults = try JSONDecoder().decode(SearchResults.self, from: data)
                completionHandler(searchResults.results)
            } catch let decodeError {
                print("Failed to decode search results", decodeError.localizedDescription)
            }
        }
    }
    
    //MARK: -- get podcast episodes
    public func fetchEpisodes(feedURL: String?, completionHandler: @escaping ([Episode])-> ()) {
        guard let feedURL = feedURL else { return }
        let secureFeedUrl = feedURL.contains("https") ? feedURL : feedURL.replacingOccurrences(of: "http", with: "https")
        guard let url = URL(string: secureFeedUrl) else { return }
        let parser = FeedParser(URL: url)
        parser.parseAsync { (result) in
            switch result {
            case .success(let feed):
                switch feed {
                case .atom(_):
                    break
                case let .rss(feed):
                    let imageUrl = feed.iTunes?.iTunesImage?.attributes?.href
                    var episodes = [Episode]()
                    feed.items?.forEach({ (feedItem) in
                        var episode = Episode(feedItem: feedItem)
                        if episode.imageUrl == nil {
                            episode.imageUrl = imageUrl
                        }
                        episodes.append(episode)
                        completionHandler(episodes)
                    })
                    break
                case .json(_):
                    break
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    //MARK: -- Download episode file to user local space
    public func downloadEpisodeToLocal(episode: Episode) {
//        let destination = DownloadRequest.suggestedDownloadDestination()
        AF.download(episode.streamUrl).downloadProgress { (progress) in
            print(">>>>>>>>>>>>>>>")
        }
    }
}
