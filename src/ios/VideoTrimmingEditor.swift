import Foundation
import AVFoundation
import PryntTrimmerView

@objc(VideoTrimmingEditor) class VideoTrimmingEditor : CDVPlugin {
    
    @objc func open(_ command: CDVInvokedUrlCommand) {
        let params = command.arguments[0] as AnyObject
        
        guard let inputPath = params["input_path"] as? String else {
            let result = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "Parameter Error")
            self.commandDelegate.send(result, callbackId:command.callbackId)
            return
        }
        
        var maxDuration = 30
        if let _maxDuration = params["video_max_time"] as? Int {
            maxDuration = _maxDuration
        }
        
        let viewController = VideoTrimmingEditorViewController(inputPath, maxDuration: maxDuration)
        
        viewController.startCallback = {
            self.viewController.startIndicator()
        }

        viewController.successCallback = { (arg) in
            let (videoPath, imagePath) = arg
            DispatchQueue.main.async {
                self.viewController.dismissIndicator()
            }
            let data = ["output_path": videoPath, "thumbnail_path": imagePath]
            let result = CDVPluginResult(status: CDVCommandStatus_OK, messageAs:data as [AnyHashable : Any])
            self.commandDelegate.send(result, callbackId:command.callbackId)
        }
        
        viewController.errorCallback = {
            DispatchQueue.main.async {
                self.viewController.dismissIndicator()
            }
            let result = CDVPluginResult(status: CDVCommandStatus_ERROR)
            self.commandDelegate.send(result, callbackId:command.callbackId)
        }
        self.viewController.present(viewController, animated: true, completion: nil)
    }
}

extension UIViewController {
    
    func startIndicator() {
        
        let loadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        
        loadingIndicator.center = self.view.center
        let grayOutView = UIView(frame: self.view.frame)
        grayOutView.backgroundColor = .black
        grayOutView.alpha = 0.6
        
        loadingIndicator.tag = 999
        grayOutView.tag = 999
        
        self.view.addSubview(grayOutView)
        self.view.addSubview(loadingIndicator)
        self.view.bringSubview(toFront: grayOutView)
        self.view.bringSubview(toFront: loadingIndicator)
        
        loadingIndicator.startAnimating()
    }
    
    func dismissIndicator() {
        
        self.view.subviews.forEach {
            if $0.tag == 999 {
                $0.removeFromSuperview()
            }
        }
    }
    
}
