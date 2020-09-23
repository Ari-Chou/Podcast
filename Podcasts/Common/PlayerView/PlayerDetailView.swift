//
//  PlayerDetailView.swift
//  ScrollNavBar
//
//  Created by Ari Chou on 9/17/20.
//

import UIKit
import MediaPlayer
import AVFoundation
import SDWebImage

class PlayerDetailView: UIView {

    //MARK: -- episode property
    var episode: Episode! {
        didSet {
            // max player view
            let url = URL(string: episode.imageUrl ?? "")
            episodeImageView.sd_setImage(with: url, completed: nil)
            episodeTitleLabel.text = episode.title
            artistNameLabel.text = episode.author
            playEpisode(url: episode.streamUrl)
            
            //mini player view
            miniEpisodeTitleLabel.text = episode.title
            miniEpisodeImageView.sd_setImage(with: url) { (image, _, _, _) in
                //now playing artwork
                guard let image =  image else { return }
                var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo
                let artWork = MPMediaItemArtwork(boundsSize: image.size) { (_) -> UIImage in
                    return image
                }
                print(">>>>>>>>>>>", artWork)
                nowPlayingInfo?[MPMediaItemPropertyArtwork] = artWork
                MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
            }
           
            // lock screen playing info
            setupNowPlayingInfo()
        }
    }
    
    //MARK: -- player
    let player: AVPlayer = {
       let player = AVPlayer()
        player.automaticallyWaitsToMinimizeStalling = false
        return player
    }()
    
    let isPlaying = false
    
    //MARK: -- mini and max player view
    @IBOutlet weak var miniPlayerView: UIView!
    @IBOutlet weak var maxPlayerView: UIStackView!
    //MARK: -- mini player items
    @IBOutlet weak var miniEpisodeImageView: UIImageView!
    @IBOutlet weak var miniEpisodeTitleLabel: UILabel!
    @IBOutlet weak var miniPlayerPlayAndPuseButton: UIButton! {
        didSet {
            miniPlayerPlayAndPuseButton.addTarget(self, action: #selector(handlePlayAndPuse), for: .touchUpInside)
        }
    }
    
    @IBAction func miniPlayerForwardButton(_ sender: Any) {
        handleForward()
    }
    //MARK: -- max player items
    @IBOutlet weak var currentTimeSlider: UISlider!
    @IBOutlet weak var currentPlayerTime: UILabel!
    @IBOutlet weak var durationTime: UILabel!
    @IBOutlet weak var episodeTitleLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var volumeSlider: UISlider!
    
    @IBOutlet weak var episodeImageView: UIImageView! {
        didSet {
            episodeImageView.layer.cornerRadius = 10
            episodeImageView.clipsToBounds = true
            episodeImageView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        }
    }
    
    //MARK: -- max player item action
    @IBAction func handleDismiss(_ sender: Any) {
      let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as! MainTabBarController
        mainTabBarController.minPLayerDetailView()
    }
    
    @IBAction func handleCurrentTimeSliderChange(_ sender: Any) {
        handleCurrentTimeSliderChange()
    }
    
    @IBAction func handleRewin(_ sender: Any) {
        handleRewin()
    }
    @IBAction func handleForward(_ sender: Any) {
        handleForward()
    }
    @IBAction func handleVolumeChange(_ sender: Any) {
        handleVolumeSliderChange()
    }
    
    @IBOutlet weak var episodePlayAndPuse: UIButton! {
        didSet {
            episodePlayAndPuse.addTarget(self, action: #selector(handlePlayAndPuse), for: .touchUpInside)
        }
    }
    
    //MARK: -- awake from nib
    override func awakeFromNib() {
        super.awakeFromNib()
        let time = CMTimeMake(value: 1, timescale: 3)
        let times = [NSValue(time: time)]
        player.addBoundaryTimeObserver(forTimes: times, queue: .main) {[weak self] in
            self?.enlargeEpisodeImageView()
        }
        
        setupAudioSession()
        setupRemoteControl()
       
        observePlayerCurrentTime()
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapMaxPlayerDetailView)))
    }
    
    
    
    fileprivate func enlargeEpisodeImageView() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1, options: .curveEaseOut) {[weak self] in
            self?.episodeImageView.transform = .identity
        } completion: { (_) in
        }
    }
    
    fileprivate func shrinkEpisodeImageView() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1, options: .curveEaseOut) {[weak self] in
            self?.episodeImageView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        } completion: { (_) in
        }
    }
    
    fileprivate func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setActive(true)
            try AVAudioSession.sharedInstance().setCategory(.playback)
        }catch let error {
        print("Failed to setup audio session")
        }
    }
    
    fileprivate func setupRemoteControl() {
        UIApplication.shared.beginReceivingRemoteControlEvents()
        let commondCenter = MPRemoteCommandCenter.shared()
        commondCenter.playCommand.isEnabled = true
        commondCenter.playCommand.addTarget {[weak self] (_) -> MPRemoteCommandHandlerStatus in
            self?.player.play()
            self?.episodePlayAndPuse.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            self?.miniPlayerPlayAndPuseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            return .success
        }
        
        commondCenter.pauseCommand.isEnabled = true
        commondCenter.pauseCommand.addTarget {[weak self] (_) -> MPRemoteCommandHandlerStatus in
            self?.player.pause()
            self?.episodePlayAndPuse.setImage(UIImage(systemName: "play.fill"), for: .normal)
            self?.miniPlayerPlayAndPuseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            return .success
        }
        
        commondCenter.togglePlayPauseCommand.isEnabled = true
        commondCenter.togglePlayPauseCommand.addTarget {[weak self] (_) -> MPRemoteCommandHandlerStatus in
            self?.handlePlayAndPuse()
            return .success
        }
    }
    
    fileprivate func setupNowPlayingInfo() {
        var nowPlayingInfo = [String: Any]()
            nowPlayingInfo[MPMediaItemPropertyTitle] = episode.title
            nowPlayingInfo[MPMediaItemPropertyArtist] = episode.author
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
       
    }
    
    fileprivate func playEpisode(url: String) {
        guard  let url = URL(string: url) else { return }
        let playItem = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: playItem)
        episodePlayAndPuse.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        player.play()
    }
    
    @objc fileprivate func handlePlayAndPuse() {
        if player.timeControlStatus == .playing {
            player.pause()
            shrinkEpisodeImageView()
            episodePlayAndPuse.setImage(UIImage(systemName: "play.fill"), for: .normal)
            miniPlayerPlayAndPuseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        } else {
            player.play()
            enlargeEpisodeImageView()
            episodePlayAndPuse.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            miniPlayerPlayAndPuseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        }
    }
    
    fileprivate func observePlayerCurrentTime() {
        let interval = CMTimeMake(value: 1, timescale: 2)
        player.addPeriodicTimeObserver(forInterval: interval, queue: .main) {[weak self] (time) in
            self?.currentPlayerTime.text = time.toDisplayString()
            guard let playItemDurationTime = self?.player.currentItem?.duration else { return }
            let playItemRemainTime = playItemDurationTime - time
            self?.durationTime.text = playItemRemainTime.toDisplayString()
            self?.updateCurrentTimeSlider()
            
            //lock screen current time
            self?.setupLockScreenCurrentTime()
        }
    }
    
    fileprivate func setupLockScreenCurrentTime() {
        var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo
        guard let playingItemDuration = player.currentItem?.duration else { return }
        let playingItemDurationInSeconds = CMTimeGetSeconds(playingItemDuration)
        
        let elalsedTime = CMTimeGetSeconds(player.currentTime())
        
        nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = elalsedTime
        nowPlayingInfo?[MPMediaItemPropertyPlaybackDuration] = playingItemDurationInSeconds
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    fileprivate func updateCurrentTimeSlider() {
        let currentPlayerSeconds = CMTimeGetSeconds(player.currentTime())
        let currentPlayerItemDuration = CMTimeGetSeconds(player.currentItem!.duration)
        
        let timePercentage = currentPlayerSeconds / currentPlayerItemDuration
        self.currentTimeSlider.value = Float(timePercentage)
        print(timePercentage)
    }
    
    // update the playback time when change the slider value
    fileprivate func handleCurrentTimeSliderChange() {
        let percentage = self.currentTimeSlider.value
        
        guard let playerItemDuration = player.currentItem?.duration else { return }
        let playerItemDurationInSeconds = CMTimeGetSeconds(playerItemDuration)
        
        let seekTimeInSeconds = Float64(percentage) * playerItemDurationInSeconds
        let seekTime = CMTimeMakeWithSeconds(seekTimeInSeconds, preferredTimescale: Int32(NSEC_PER_SEC))
        player.seek(to: seekTime)
    }
    
    // rewin
    fileprivate func handleRewin() {
        let fifteenSeconds = CMTimeMake(value: -15, timescale: 1)
        let seekTime = CMTimeAdd(player.currentTime(), fifteenSeconds)
        player.seek(to: seekTime)
    }
    
    // forward
    fileprivate func handleForward() {
        let fifteenSeconds = CMTimeMake(value: 15, timescale: 1)
        let seekTime = CMTimeAdd(player.currentTime(), fifteenSeconds)
        player.seek(to: seekTime)
    }
    
    // volume slider change
    fileprivate func handleVolumeSliderChange() {
        player.volume = volumeSlider.value
    }
    
    @objc fileprivate func handleTapMaxPlayerDetailView() {
        let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as! MainTabBarController
        mainTabBarController.maxPlayerDetailView(episode: nil)
        mainTabBarController.tabBar.isHidden = true
    }
}
