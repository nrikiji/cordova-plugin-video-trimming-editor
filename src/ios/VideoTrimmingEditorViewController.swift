import UIKit
import AVFoundation
import Photos
import PryntTrimmerView

class VideoTrimmingEditorViewController: UIViewController {
    
    var maxDuration: Double = 30

    let margin: CGFloat = 20.0
    
    var playerView = UIView()
    var trimmerView = TrimmerView()
    var duration = UILabel()
    var cancelBtn = UIButton()
    var trimmingBtn = UIButton()
    var inputPath: String!
    
    var player: AVPlayer?
    
    var playbackTimeCheckerTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black
        
        self.loadAsset()
        
        playerView.backgroundColor = UIColor.lightGray
        playerView.frame = CGRect(x: margin, y: 50, width: view.frame.width - margin*2, height: view.frame.height - 240)
        view.addSubview(playerView)
        
        duration.textColor = UIColor.white
        duration.font = UIFont.systemFont(ofSize: 16)
        duration.textAlignment = NSTextAlignment.center
        duration.frame = CGRect(x: 0, y: view.frame.height - 180, width: view.frame.width, height: 20)
        view.addSubview(duration)
        
        trimmerView.handleColor = UIColor.white
        trimmerView.mainColor = UIColor.darkGray
        trimmerView.positionBarColor = UIColor.red
        trimmerView.maxDuration = maxDuration
        trimmerView.frame = CGRect(x: margin, y: view.frame.height - 150, width: view.frame.width - margin*2, height: 100)
        trimmerView.delegate = self
        view.addSubview(trimmerView)
        
        // let systemBlueColor = UIColor(red: 0, green: 122 / 255, blue: 1, alpha: 1)
        
        cancelBtn.setTitle("Cancel", for: UIControl.State.normal)
        cancelBtn.setTitleColor(UIColor.white, for: UIControl.State.normal)
        cancelBtn.frame = CGRect(x: 20, y: view.frame.height - 30, width: 120, height: 20)
        cancelBtn.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        cancelBtn.addTarget(self, action: #selector(onCancel(sender:)), for: .touchUpInside)
        view.addSubview(cancelBtn)
        
        trimmingBtn.setTitle("Finish", for: UIControl.State.normal)
        trimmingBtn.setTitleColor(UIColor.white, for: UIControl.State.normal)
        trimmingBtn.frame = CGRect(x: view.frame.width - 140, y: view.frame.height - 30, width: 120, height: 20)
        trimmingBtn.addTarget(self, action: #selector(onTrimming(sender:)), for: .touchUpInside)
        trimmingBtn.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.right
        view.addSubview(trimmingBtn)
    }
    
    @objc func itemDidFinishPlaying(_ notification: Notification) {
        guard let startTime = trimmerView.startTime else { return }
        player?.seek(to: startTime)
    }
    
    @objc func onCancel(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func onTrimming(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

    private func loadAsset() {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let inputURL = URL(fileURLWithPath: self.inputPath)
            let avAsset = AVURLAsset(url: inputURL, options: nil)
            
            let formatter = DateComponentsFormatter()
            formatter.unitsStyle = .positional
            formatter.allowedUnits = [.minute, .second]
            formatter.zeroFormattingBehavior = [.pad]
            
            var endTime = self.maxDuration
            if avAsset.duration.seconds < self.maxDuration {
                endTime = avAsset.duration.seconds
            }
            self.duration.text = "0.00 〜 \(formatter.string(from: endTime)!)"
            
            self.trimmerView.asset = avAsset
            let playerItem = AVPlayerItem(asset: avAsset)
            self.player = AVPlayer(playerItem: playerItem)
            
            NotificationCenter.default.addObserver(self, selector: #selector(VideoTrimmingEditorViewController.itemDidFinishPlaying(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
            
            let layer: AVPlayerLayer = AVPlayerLayer(player: self.player)
            layer.backgroundColor = UIColor.white.cgColor
            layer.frame = CGRect(x: 0, y: 0, width: self.playerView.frame.width, height: self.playerView.frame.height)
            layer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            self.playerView.layer.sublayers?.forEach({$0.removeFromSuperlayer()})
            self.playerView.layer.addSublayer(layer)
        }
        
    }
    
    func startPlaybackTimeChecker() {
        stopPlaybackTimeChecker()
        playbackTimeCheckerTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(VideoTrimmingEditorViewController.onPlaybackTimeChecker), userInfo: nil, repeats: true)
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

extension VideoTrimmingEditorViewController: TrimmerViewDelegate {
    
    func positionBarStoppedMoving(_ playerTime: CMTime) {
        player?.seek(to: playerTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
        player?.play()
        startPlaybackTimeChecker()
    }
    
    func didChangePositionBar(_ playerTime: CMTime) {
        stopPlaybackTimeChecker()
        player?.pause()
        player?.seek(to: playerTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
        
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = [.pad]
        let startTime = formatter.string(from: trimmerView.startTime!.seconds)!
        let endTime = formatter.string(from: trimmerView.endTime!.seconds)!
        duration.text = "\(startTime) 〜 \(endTime)"
    }
}
