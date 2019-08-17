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
    var playBtn = UIImageView()
    var pauseBtn = UIImageView()
    var trimmingBtn = UIButton()
    var inputPath: String!
    
    var player: AVPlayer?
    
    var playbackTimeCheckerTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white

        self.loadAsset()
        
        playerView.backgroundColor = UIColor.lightGray
        playerView.frame = CGRect(x: margin, y: 50, width: view.frame.width - margin*2, height: view.frame.height - 240)
        view.addSubview(playerView)
        
        duration.textColor = UIColor.black
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
        cancelBtn.setTitleColor(UIColor.black, for: UIControl.State.normal)
        cancelBtn.frame = CGRect(x: 20, y: view.frame.height - 30, width: 120, height: 20)
        cancelBtn.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        cancelBtn.addTarget(self, action: #selector(onCancel(sender:)), for: .touchUpInside)
        view.addSubview(cancelBtn)
        
        playBtn.image = UIImage(named: "ic_video_play_black.png")?.withRenderingMode(.alwaysTemplate)
        playBtn.contentMode = UIView.ContentMode.scaleAspectFit
        playBtn.frame = CGRect(x: view.frame.width/2 - 10, y: view.frame.height - 30, width: 20, height: 20)
        playBtn.isUserInteractionEnabled = true
        playBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onPlay(sender:))))
        playBtn.tintColor = UIColor.black
        view.addSubview(playBtn)

        pauseBtn.image = UIImage(named: "ic_video_pause_black.png")?.withRenderingMode(.alwaysTemplate)
        pauseBtn.contentMode = UIView.ContentMode.scaleAspectFit
        pauseBtn.frame = CGRect(x: view.frame.width/2 - 10, y: view.frame.height - 30, width: 20, height: 20)
        pauseBtn.isUserInteractionEnabled = true
        pauseBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onPause(sender:))))
        pauseBtn.isHidden = true
        pauseBtn.tintColor = UIColor.black
        view.addSubview(pauseBtn)

        trimmingBtn.setTitle("Finish", for: UIControl.State.normal)
        trimmingBtn.setTitleColor(UIColor.black, for: UIControl.State.normal)
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
            player.seek(to: startTime, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
            trimmerView.seek(to: startTime)
        }
    }
    
    @objc func onPlay(sender: UITapGestureRecognizer) {
        player?.play()
        playBtn.isHidden = true
        pauseBtn.isHidden = false
    }
    
    @objc func onPause(sender: UITapGestureRecognizer) {
        player?.pause()
        playBtn.isHidden = false
        pauseBtn.isHidden = true
    }
}

extension VideoTrimmingEditorViewController: TrimmerViewDelegate {
    
    func positionBarStoppedMoving(_ playerTime: CMTime) {
        player?.seek(to: playerTime, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
        startPlaybackTimeChecker()
    }
    
    func didChangePositionBar(_ playerTime: CMTime) {
        stopPlaybackTimeChecker()
        player?.pause()
        player?.seek(to: playerTime, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
        playBtn.isHidden = false
        pauseBtn.isHidden = true

        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = [.pad]
        let startTime = formatter.string(from: trimmerView.startTime!.seconds)!
        let endTime = formatter.string(from: trimmerView.endTime!.seconds)!
        duration.text = "\(startTime) 〜 \(endTime)"
    }
}
