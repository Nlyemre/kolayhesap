import UIKit
import Flutter
import Firebase
import FirebaseMessaging
import UserNotifications
import AVFoundation

@main
@objc class AppDelegate: FlutterAppDelegate {
    private let CHANNEL = "notification_settings"
    private let SOUND_CHANNEL = "com.kolayhesap.app/sound"
    private var soundManager: SoundManager?
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // 1. Firebase konfigürasyonu (ilk sırada)
        FirebaseApp.configure()
        
        // 2. Flutter plugin kaydı
        GeneratedPluginRegistrant.register(with: self)
        
        // 3. Bildirim delegasyonları
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
        
        // 4. Bildirim MethodChannel kurulumu
        setupMethodChannel()

        // SoundManager'ı başlat
        soundManager = SoundManager()
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    // MARK: - MethodChannel Kurulumu (bildirimler için)
    private func setupMethodChannel() {
    guard let controller = window?.rootViewController as? FlutterViewController else { return }
    
    let channel = FlutterMethodChannel(
        name: CHANNEL,
        binaryMessenger: controller.binaryMessenger
    )

    // Ses MethodChannel
     let soundChannel = FlutterMethodChannel(
            name: SOUND_CHANNEL,
            binaryMessenger: controller.binaryMessenger
        )
    
    channel.setMethodCallHandler { [weak self] (call, result) in
        switch call.method {
        case "checkPermission":
            self?.checkNotificationPermission(result: result)
        case "openNotificationSettings":
            self?.openNotificationSettings(result: result)
        case "checkAlarmPermission":
            result(true)
        case "openAlarmPermissionSettings":
            self?.openAlarmSettings(result: result)
        case "scheduleTaskNotification":
            self?.scheduleNotification(call: call, result: result)
        case "cancelTaskNotification":
            self?.cancelNotification(call: call, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    // Ses MethodChannel dinleyicisi
     soundChannel.setMethodCallHandler { [weak self] (call, result) in
            switch call.method {
            case "playSound":
                guard let args = call.arguments as? [String: Any],
                      let frequency = args["frequency"] as? Int,
                      let volume = args["volume"] as? Double else {
                    result(FlutterError(code: "INVALID_ARGS", message: "frequency: Int, volume: Double gereklidir", details: nil))
                    return
                }
                self?.soundManager?.playSound(frequency: frequency, volume: Float(volume))
                result(nil)
                
            case "stopSound":
                self?.soundManager?.stopSound()
                result(nil)
                
            case "updateFrequency":
                guard let frequency = (call.arguments as? [String: Any])?["frequency"] as? Int else {
                    result(FlutterError(code: "INVALID_ARGS", message: "frequency: Int gereklidir", details: nil))
                    return
                }
                self?.soundManager?.updateFrequency(newFrequency: frequency)
                result(nil)
                
            case "updateVolume":
                guard let volume = (call.arguments as? [String: Any])?["volume"] as? Double else {
                    result(FlutterError(code: "INVALID_ARGS", message: "volume: Double gereklidir", details: nil))
                    return
                }
                self?.soundManager?.updateVolume(newVolume: Float(volume))
                result(nil)
                
            default:
                result(FlutterMethodNotImplemented)
            }
        }
}
    
    private func checkNotificationPermission(result: @escaping FlutterResult) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            result(settings.authorizationStatus == .authorized)
        }
    }

    private func openNotificationSettings(result: @escaping FlutterResult) {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url, options: [:])
        }
        result(nil)
    }

    private func openAlarmSettings(result: @escaping FlutterResult) {
        openNotificationSettings(result: result)
    }

    private func scheduleNotification(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let taskId = args["taskId"] as? String,
              let title = args["title"] as? String,
              let body = args["body"] as? String,
              let timestamp = args["timestamp"] as? Double else {
            result(FlutterError(code: "INVALID_ARGS", message: "Geçersiz argümanlar", details: nil))
            return
        }

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.categoryIdentifier = "TASK_REMINDER"

        let triggerDate = Date(timeIntervalSince1970: timestamp / 1000)
        let dateComponents = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: triggerDate
        )

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(
            identifier: taskId,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                result(FlutterError(code: "SCHEDULE_FAILED", message: error.localizedDescription, details: nil))
            } else {
                result(nil)
            }
        }
    }

    private func cancelNotification(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let taskId = args["taskId"] as? String else {
            result(FlutterError(code: "INVALID_ARGS", message: "Geçersiz argümanlar", details: nil))
            return
        }

        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [taskId])
        result(nil)
    }

    override func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        Messaging.messaging().apnsToken = deviceToken
        super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    }

    override func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }

    override func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        completionHandler()
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        if let token = fcmToken {
            print("FCM Token: \(token)")
        }
    }
}