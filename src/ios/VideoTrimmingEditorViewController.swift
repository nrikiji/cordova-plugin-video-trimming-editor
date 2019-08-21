import UIKit
import AVFoundation
import Photos
import PryntTrimmerView

class VideoTrimmingEditorViewController: UIViewController {
    
    var maxDuration: Double
    var inputPath: String! // 入力ファイルパス（内部的にはURLスキームありの前提で）
    var outputBasePath: String! // 出力ファイルパス(拡張子なし)
    var outputVideoPath: String! // 出力動画ファイルパス
    var outputThumbnailPath: String! // 出力画像ファイルパス
    var avAsset: AVURLAsset!

    var requiredScheme: Bool = false // 戻り値にURLスキーマを追加するか（入力値と合わせる）

    let margin: CGFloat = 20.0
    
    var playerView = UIView()
    var trimmerView = TrimmerView()
    var duration = UILabel()
    var cancelBtn = UIButton()
    var playBtn = UIImageView()
    var pauseBtn = UIImageView()
    var trimmingBtn = UIButton()
    
    var player: AVPlayer?
    
    var playbackTimeCheckerTimer: Timer?
    var startCallback: (() -> Void)?
    var successCallback: (((String, String)) -> Void)?
    var errorCallback: (() -> Void)?

    init(_ inputPath: String, maxDuration: Int) {
        self.inputPath = inputPath
        self.maxDuration = Double(maxDuration)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setView()
        initializeData()
        loadAsset()
    }
    
    private func setView() {
        
        self.view.backgroundColor = UIColor.white

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
    
    private func initializeData() {
        if inputPath.contains("file://") {
            self.requiredScheme = true
        } else {
            inputPath = "file://" + inputPath
        }
        let inputURL = URL(string: inputPath)!
        
        let interval = TimeInterval(NSDate().timeIntervalSince1970)
        let time = NSDate(timeIntervalSince1970: TimeInterval(interval))
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"
        let timestamp = formatter.string(from: time as Date)
        outputBasePath = "file://" + NSTemporaryDirectory() + "VideoTrimmingEditor_\(timestamp)"
        
        outputVideoPath = outputBasePath + ".mp4"
        outputThumbnailPath = outputBasePath + ".png"
        
        self.avAsset = AVURLAsset(url: inputURL, options: nil)
    }
    
    private func loadAsset() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let formatter = DateComponentsFormatter()
            formatter.unitsStyle = .positional
            formatter.allowedUnits = [.minute, .second]
            formatter.zeroFormattingBehavior = [.pad]
            
            var endTime = self.maxDuration
            if self.avAsset.duration.seconds < self.maxDuration {
                endTime = self.avAsset.duration.seconds
            }
            self.duration.text = "0.00 〜 \(formatter.string(from: endTime)!)"
            
            self.trimmerView.asset = self.avAsset
            let playerItem = AVPlayerItem(asset: self.avAsset)
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

    @objc func itemDidFinishPlaying(_ notification: Notification) {
        guard let startTime = trimmerView.startTime else { return }
        player?.seek(to: startTime)
    }
    
    @objc func onCancel(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func onTrimming(sender: UIButton) {
        do {
            // サムネイル生成
            try createThumbnail()
            
            // 動画トリミング
            trimmingVideo(success: { (arg) in
                let (videoPath, thumbnailPath) = arg
                self.successCallback?((videoPath, thumbnailPath))
            }) {
                self.errorCallback?()
            }
        } catch {
            self.errorCallback?()
        }
    }
    
    private func createThumbnail() throws {
        let generator = AVAssetImageGenerator(asset: avAsset)
        guard let assetTrack = self.avAsset.tracks(withMediaType: AVMediaType.video).first else {
            throw VideoTrimmingEditorError.createThumbnail
        }
        
        let floatTime = Float64(self.trimmerView.startTime!.seconds)
        let time = CMTimeMakeWithSeconds(floatTime, 600)
        guard let cgImage = try? generator.copyCGImage(at: time, actualTime: nil) else {
            throw VideoTrimmingEditorError.createThumbnail
        }
        
        guard let outputURL = URL(string: outputThumbnailPath!) else {
            throw VideoTrimmingEditorError.createThumbnail
        }
        
        let degree: CGFloat!
        let transform = assetTrack.preferredTransform
        if transform.a == -1.0 && transform.b == 0.0 && transform.c == 0.0 && transform.d == -1.0 {
            degree = 180
        } else if transform.a == 0.0 && transform.b == -1.0 && transform.c == 1.0 && transform.d == 0.0 {
            degree = 270
        }else if transform.a == 0.0 && transform.b == 1.0 && transform.c == -1.0 && transform.d == 0.0 {
            degree = 90
        } else {
            degree = 0
        }
        
        do {
            let image = UIImage(cgImage: cgImage).rotatedBy(degree: degree, isCropped: false)
            let pngImageData = UIImagePNGRepresentation(image)
            try pngImageData?.write(to: outputURL)
        } catch {
            throw VideoTrimmingEditorError.createThumbnail
        }
    }

    // 非同期処理のためコールバックを引数にもつ
    private func trimmingVideo(success: @escaping ((String, String)) -> Void, failer: @escaping () -> Void) {
        self.startCallback?()
        
        let inputURL = URL(string: inputPath)!
        let outputURL = URL(string: outputVideoPath)!
        
        let videoAsset = AVURLAsset(url: inputURL)
        let audioAsset = AVURLAsset(url: inputURL)
        let composition = AVMutableComposition()
        
        let videoAssetSrcTrack = videoAsset.tracks(withMediaType: AVMediaType.video).first!
        let videoCompositionTrack = composition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: kCMPersistentTrackID_Invalid)
        let audioAssetSrcTrack = audioAsset.tracks(withMediaType: AVMediaType.audio).first!
        let audioCompositionTrack = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid)
        
        let rangeStart = CMTimeMakeWithSeconds(Float64(trimmerView.startTime!.seconds), Int32(NSEC_PER_SEC))
        let rangeDulation = CMTimeMakeWithSeconds(Float64(trimmerView.endTime!.seconds - trimmerView.startTime!.seconds), Int32(NSEC_PER_SEC))
        let outputRange: CMTimeRange = CMTimeRangeMake(rangeStart, rangeDulation)
        
        do {
            videoCompositionTrack?.preferredTransform = (videoAsset.tracks(withMediaType: AVMediaType.video).first?.preferredTransform)!
            try videoCompositionTrack?.insertTimeRange(outputRange, of: videoAssetSrcTrack, at: kCMTimeZero)
            try audioCompositionTrack?.insertTimeRange(outputRange, of: audioAssetSrcTrack, at: kCMTimeZero)
            
            guard let exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetMediumQuality) else {
                failer()
                return
            }
            
            exportSession.canPerformMultiplePassesOverSourceMediaData = true
            exportSession.outputURL = outputURL
            exportSession.outputFileType = AVFileType.mp4
            exportSession.timeRange = CMTimeRangeMake(kCMTimeZero, composition.duration)
            exportSession.outputFileType = AVFileType.mov as AVFileType
            
            exportSession.exportAsynchronously {
                if exportSession.status.rawValue == 3 {
                    success(self.formatResult())
                } else {
                    failer()
                }
            }
        } catch {
            failer()
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    private func formatResult() -> (String, String) {
        var _outputVideoPath = outputVideoPath
        var _outputThumbnailPath = outputThumbnailPath
        if !requiredScheme {
            _outputVideoPath = _outputVideoPath!.replacingOccurrences(of: "file://", with: "")
            _outputThumbnailPath = _outputVideoPath!.replacingOccurrences(of: "file://", with: "")
        }
        return (_outputVideoPath!, _outputThumbnailPath!)
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
        
        guard let startTime = trimmerView.startTime,
            let endTime = trimmerView.endTime,
            let player = player else {
                return
        }
        
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

enum VideoTrimmingEditorError: Error {
    case trimmingVideo
    case createThumbnail
    case unknown(String)
}

extension UIImage {
    func rotatedBy(degree: CGFloat, isCropped: Bool = true) -> UIImage {
        let radian = -degree * CGFloat.pi / 180
        var rotatedRect = CGRect(origin: .zero, size: self.size)
        if !isCropped {
            rotatedRect = rotatedRect.applying(CGAffineTransform(rotationAngle: radian))
        }
        UIGraphicsBeginImageContext(rotatedRect.size)
        let context = UIGraphicsGetCurrentContext()!
        context.translateBy(x: rotatedRect.size.width / 2, y: rotatedRect.size.height / 2)
        context.scaleBy(x: 1.0, y: -1.0)
        
        context.rotate(by: radian)
        context.draw(self.cgImage!, in: CGRect(x: -(self.size.width / 2), y: -(self.size.height / 2), width: self.size.width, height: self.size.height))
        
        let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return rotatedImage
    }
}
