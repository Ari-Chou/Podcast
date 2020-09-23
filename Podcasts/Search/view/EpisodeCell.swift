//
//  EpisodeCell.swift
//  ScrollNavBar
//
//  Created by Ari Chou on 9/17/20.
//

import UIKit
import SDWebImage

class EpisodeCell: UITableViewCell {
    
    @IBOutlet weak var episodeImageView: UIImageView!
    @IBOutlet weak var pubDateLabel: UILabel!
    @IBOutlet weak var episodeTitleLabel: UILabel!
    @IBOutlet weak var episodeDescriptionLabel: UILabel!
    
    var episode: Episode! {
        didSet {
            pubDateLabel.text = Date().dateFormatter(for: episode.pubDate!)
            episodeTitleLabel.text = episode.title
            episodeDescriptionLabel.text = episode.description
            
            let url = URL(string: episode.imageUrl ?? "")
            print(">>>>>>>>>>>>>>>",url)
            episodeImageView.sd_setImage(with: url, completed: nil)
        }
    }
}
