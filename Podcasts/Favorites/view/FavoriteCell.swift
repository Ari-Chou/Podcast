//
//  FavoriteCell.swift
//  Podcasts
//
//  Created by AriCHou on 9/20/20.
//

import UIKit
import SDWebImage

class FavoriteCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var artistName: UILabel!
    
    var podcast: Podcast! {
        didSet {
            let url = URL(string: podcast.artworkUrl100 ?? "")
            imageView.sd_setImage(with: url, completed: nil)
            nameLabel.text = podcast.trackName
            artistName.text = podcast.artistName
        }
    }
    
//    let imageView = UIImageView(image: UIImage(systemName: "airplayaudio"))
//    let nameLabel = UILabel()
//    let artistNameLabel = UILabel()
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        self.backgroundColor = .yellow
//        setupCell()
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//}
//
//
//extension FavoriteCell {
//    fileprivate func setupCell() {
//        let cellStackView = UIStackView(arrangedSubviews: [imageView, nameLabel, artistNameLabel])
//        cellStackView.axis = .vertical
//        cellStackView.translatesAutoresizingMaskIntoConstraints = false
//        addSubview(cellStackView)
//
//        nameLabel.text = "Episode Title"
//        artistNameLabel.text = "Artist Name"
//
//        NSLayoutConstraint.activate([
//            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor),
//            cellStackView.topAnchor.constraint(equalTo: self.topAnchor),
//            cellStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
//            cellStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
//            cellStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
//        ])
//    }
}
