import Flutter
import UIKit
import PaymobSDK

@main
@objc class AppDelegate: FlutterAppDelegate, PaymobSDKDelegate {
  private var pendingResult: FlutterResult?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let paymobChannel = FlutterMethodChannel(name: "paymob_sdk_flutter",
                                              binaryMessenger: controller.binaryMessenger)
    
    paymobChannel.setMethodCallHandler({
      [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      guard call.method == "payWithNativeSdk" else {
        result(FlutterMethodNotImplemented)
        return
      }
      
      self?.pendingResult = result
      
      if let args = call.arguments as? Dictionary<String, Any>,
         let publicKey = args["publicKey"] as? String,
         let clientSecret = args["clientSecret"] as? String {
         
         let appName = args["appName"] as? String ?? "Doctor Appointment"
         
         let intent = PaymobIntent(publicKey: publicKey, clientSecret: clientSecret)
         intent.appName = appName
         
         PaymobSDK.shared.delegate = self
         PaymobSDK.shared.presentPaymobController(with: intent, from: controller)
      } else {
         result(FlutterError(code: "INVALID_ARGS", message: "Missing arguments", details: nil))
      }
    })

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  func transactionAccepted(withTransactionId transactionId: String) {
    pendingResult?("Successfull")
    pendingResult = nil
  }
  
  func transactionRejected(withReason reason: String) {
    pendingResult?("Rejected")
    pendingResult = nil
  }
  
  func transactionPending() {
    pendingResult?("Pending")
    pendingResult = nil
  }
}
