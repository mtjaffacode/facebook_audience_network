import Foundation
import Flutter
import FBAudienceNetwork

class FANPluginFactory: NSObject {
    let channel: FlutterMethodChannel
    
    init(_channel: FlutterMethodChannel) {
        print("FANPluginFactory > init")
        
        channel = _channel
        
        super.init()
        
        channel.setMethodCallHandler { (call, result) in
            switch call.method{
            case "init":
                print("FANPluginFactory > init")
                result(true)
            default:
                result(FlutterMethodNotImplemented)
            }
        }
        
        print("FacebookAudienceNetworkInterstitialAdPlugin > init > end")
    }
}


class FANRewardedAdPluginFactory: NSObject, FBRewardedVideoAdDelegate {
    let channel: FlutterMethodChannel
    var ad: FBRewardedVideoAd?
    
    init(_channel: FlutterMethodChannel) {
        print("FANPluginFactory > init")
        
        channel = _channel
        
        super.init()
        
        channel.setMethodCallHandler { (call, result) in
            switch call.method{
            case "loadRewardedAd":
                self.ad = FBRewardedVideoAd(placementID: (call.arguments as! Dictionary)["id", default: ""])
                self.ad?.delegate = self
                self.ad?.load()
                print("FANPluginFactory > init")
                result(true)
                break
            case "showRewardedAd":
                self.ad?.show(fromRootViewController: UIApplication.shared.windows.first!.rootViewController!)
                result(true)
                break
            case "destroyRewardedAd":
                self.ad?.delegate = nil
                self.ad = nil
                result(true)
                break
            default:
                result(FlutterMethodNotImplemented)
            }
        }
        
        print("FacebookAudienceNetworkInterstitialAdPlugin > init > end")
    }
    
    func rewardedVideoAdDidLoad(_ rewardedVideoAd: FBRewardedVideoAd) {
        let dictionary : [String: Any] = [
            "placement_id": rewardedVideoAd.placementID,
            "invalited": rewardedVideoAd.isAdValid
        ]
        channel.invokeMethod("loaded", arguments: dictionary)
    }
    
    func rewardedVideoAd(_ rewardedVideoAd: FBRewardedVideoAd, didFailWithError error: Error) {
        channel.invokeMethod("error", arguments: nil)
    }
    
    func rewardedVideoAdVideoComplete(_ rewardedVideoAd: FBRewardedVideoAd) {
        channel.invokeMethod("rewarded_complete", arguments: true)
    }
    
    func rewardedVideoAdDidClose(_ rewardedVideoAd: FBRewardedVideoAd) {
        channel.invokeMethod("rewarded_closed", arguments: true)
    }
}

/*
 const String DISPLAYED_METHOD = "displayed";
 const String DISMISSED_METHOD = "dismissed";
 const String ERROR_METHOD = "error";
 const String LOADED_METHOD = "loaded";
 const String CLICKED_METHOD = "clicked";
 const String LOGGING_IMPRESSION_METHOD = "logging_impression";

 const String REWARDED_VIDEO_COMPLETE_METHOD = "rewarded_complete";
 const String REWARDED_VIDEO_CLOSED_METHOD = "rewarded_closed";
 */
