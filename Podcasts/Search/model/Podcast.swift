//
//  Podcast.swift
//  ScrollNavBar
//
//  Created by Ari Chou on 9/16/20.
//

import Foundation
import FeedKit

class Podcast:NSObject, Decodable, NSCoding {
    
    func encode(with coder: NSCoder) {
        coder.encode(trackName ?? "", forKey: "trackNameKey")
        coder.encode(artistName ?? "", forKey: "artistNameKey")
        coder.encode(artworkUrl100 ?? "", forKey: "artworkUrl100Key")
        coder.encode(feedUrl ?? "", forKey: "feedUrlKey")
    }
    
    required init?(coder: NSCoder) {
        self.trackName = coder.decodeObject(forKey: "trackNameKey") as? String
        self.artistName = coder.decodeObject(forKey: "artistNameKey") as? String
        self.artworkUrl100 = coder.decodeObject(forKey: "artworkUrl100Key") as? String
        self.feedUrl = coder.decodeObject(forKey: "feedUrlKey") as? String
    }
    
    var trackName: String?
    var artistName: String?
    var artworkUrl100: String?
    var trackCount: Int?
    var feedUrl: String?
}

struct SearchResults: Decodable {
    let resultCount: Int
    let results: [Podcast]
}

struct Episode: Codable {
    var title: String?
    var pubDate: Date?
    var description: String?
    var imageUrl: String?
    var author: String?
    var streamUrl: String
    
    init(feedItem: RSSFeedItem) {
        self.title = feedItem.title
        self.pubDate = feedItem.pubDate
        self.description = feedItem.iTunes?.iTunesSubtitle ?? feedItem.description ?? ""
        self.imageUrl = feedItem.iTunes?.iTunesImage?.attributes?.href
        self.author = feedItem.iTunes?.iTunesAuthor
        self.streamUrl = (feedItem.enclosure?.attributes?.url)!
        
    }
}
