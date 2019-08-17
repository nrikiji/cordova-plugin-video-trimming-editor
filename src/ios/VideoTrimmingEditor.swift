import UIKit
import AVFoundation
import Photos
import PryntTrimmerView

class VideoTrimmingEditorViewController: UIViewController {

    let margin: CGFloat = 20.0
    
    var playerView = UIView()
    var trimmerView = TrimmerView()
    var loadAssetBtn = UIButton()
    var durationVideo = UILabel()
    
    var player: AVPlayer?
    var fetchNo: Int?
    
    var playbackTimeCheckerTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        
        playerView.backgroundColor = UIColor.lightGray
        playerView.frame = CGRect(x: margin, y: 50, width: view.frame.width - margin*2, height: view.frame.height / 1.5)
        view.addSubview(playerView)
        
        trimmerView.handleColor = UIColor.white
        trimmerView.mainColor = UIColor.darkGray
        trimmerView.positionBarColor = UIColor.red
        trimmerView.maxDuration = 30
        trimmerView.frame = CGRect(x: margin, y: view.frame.height - 150, width: view.frame.width - margin*2, height: 100)
        trimmerView.delegate = self
        view.addSubview(trimmerView)
        
        loadAssetBtn.setTitle("Next", for: UIControl.State.normal)
        loadAssetBtn.setTitleColor(UIColor.blue, for: UIControl.State.normal)
        loadAssetBtn.frame = CGRect(x: 20, y: view.frame.height - 30, width: 120, height: 20)
        loadAssetBtn.addTarget(self, action: #selector(onLoadAsset(sender:)), for: .touchUpInside)
        view.addSubview(loadAssetBtn)
        
        durationVideo.text = ""
        durationVideo.textColor = UIColor.blue
        durationVideo.frame = CGRect(x: view.frame.width - 120, y: view.frame.height - 30, width: 120, height: 20)
        view.addSubview(durationVideo)
    }
    
    @objc func itemDidFinishPlaying(_ notification: Notification) {
        guard let startTime = trimmerView.startTime else { return }
        player?.seek(to: startTime)
    }
    
    @objc func onLoadAsset(sender: UIButton) {
        self.loadAsset()
    }
    
    private func loadAsset() {
        let fetchResult = PHAsset.fetchAssets(with: .video, options: nil)
        if self.fetchNo == nil || self.fetchNo! < 0 {
            self.fetchNo = fetchResult.count - 1
        } else {
            self.fetchNo = self.fetchNo! - 1
        }
        let asset: PHAsset = fetchResult.object(at: self.fetchNo!)
        PHCachingImageManager().requestAVAsset(forVideo: asset, options: nil) { (avAsset, _, _) in
            DispatchQueue.main.async {
                guard let avAsset = avAsset else { return }
                
                let duration = avAsset.duration
                let durationTime = Int(CMTimeGetSeconds(duration))
                self.durationVideo.text = "\(durationTime)s"
                
                let inputURL = URL(fileURLWithPath: "path/to/video")
                let avAsset2 = AVURLAsset(url: inputURL, options: nil)
                self.trimmerView.asset = avAsset2
                
                self.trimmerView.asset = avAsset
                let playerItem = AVPlayerItem(asset: avAsset)
                self.player = AVPlayer(playerItem: playerItem)
                
                NotificationCenter.default.addObserver(self, selector: #selector(VIdeoTrimmingEditorViewController.itemDidFinishPlaying(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
                
                let layer: AVPlayerLayer = AVPlayerLayer(player: self.player)
                layer.backgroundColor = UIColor.white.cgColor
                layer.frame = CGRect(x: 0, y: 0, width: self.playerView.frame.width, height: self.playerView.frame.height)
                layer.videoGravity = AVLayerVideoGravity.resizeAspectFill
                self.playerView.layer.sublayers?.forEach({$0.removeFromSuperlayer()})
                self.playerView.layer.addSublayer(layer)
            }
        }
    }
    
    func startPlaybackTimeChecker() {
        stopPlaybackTimeChecker()
        playbackTimeCheckerTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(ViewController.onPlaybackTimeChecker), userInfo: nil, repeats: true)
    }
    
    func stopPlaybackTimeChecker() {
        playbackTimeCheckerTimer?.invalidate()
        playbackTimeCheckerTimer = nil
    }
    
    @objc func onPlaybackTimeChecker() {
        
        guard let startTime = trimmerView.startTime, let endTime = trimmerView.endTime, let player = player else { return }
        
        let playBackTime = player.currentTime()
        trimmerView.seek(to: playBackTime)
        
        if playBackTime >= endTime {
            player.seek(to: startTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
            trimmerView.seek(to: startTime)
        }
    }
}

extension VIdeoTrimmingEditorViewController: TrimmerViewDelegate {
    
    func positionBarStoppedMoving(_ playerTime: CMTime) {
        player?.seek(to: playerTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
        player?.play()
        startPlaybackTimeChecker()
    }
    
    func didChangePositionBar(_ playerTime: CMTime) {
        stopPlaybackTimeChecker()
        player?.pause()
        player?.seek(to: playerTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
        // let duration = (trimmerView.endTime! - trimmerView.startTime!).seconds
        // print(duration)
        print("\(trimmerView.startTime!.seconds) - \(trimmerView.endTime!.seconds)")
    }
}
