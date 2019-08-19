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
        
        guard let videoMaxTime = params["video_max_time"] as? Int else {
            let result = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "Parameter Error")
            self.commandDelegate.send(result, callbackId:command.callbackId)
            return
        }

        let viewController = VideoTrimmingEditorViewController()
        viewController.inputPath = inputPath
        viewController.maxDuration = Double(videoMaxTime)
        viewController.successCallback = { (outputPath) in
            let data = ["output_path": outputPath]
            let result = CDVPluginResult(status: CDVCommandStatus_OK, messageAs:data as [AnyHashable : Any])
            self.commandDelegate.send(result, callbackId:command.callbackId)
        }
        viewController.errorCallback = {
            let result = CDVPluginResult(status: CDVCommandStatus_ERROR)
            self.commandDelegate.send(result, callbackId:command.callbackId)
        }
        self.viewController.present(viewController, animated: true, completion: nil)
    }
}
