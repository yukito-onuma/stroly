//
//  camera.swift
//  stroly
//
//  Created by 大沼優希人 on 2023/11/10.
//

// 参考URL : https://qiita.com/SNQ-2001/items/2cc6e7e35ab98ba02397 （カメラの使用自体）
//          https://superhahnah.com/swift-request-authorization/   (カメラの使用許可降りなかった時の処理)

import SwiftUI
import AVFoundation

public struct CameraView: UIViewControllerRepresentable {
    @Binding private var image: UIImage?
    @Binding private var isExitImage: Bool
    @Environment(\.dismiss) private var dismiss


    public init(image: Binding<UIImage?>, isExitImage: Binding<Bool>) {
        self._image = image
        self._isExitImage = isExitImage
        let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        if status != AVAuthorizationStatus.authorized {
            AVCaptureDevice.requestAccess(for: .video, completionHandler: notAllowed)
        }
    }
    
    
    // AVCaptureDevice.requestAccessでカメラ使用許可が出なかったらこの関数に行く
    public func notAllowed(_: Bool) -> Void {
        let title: String = "Failed to take pictures"
        let message: String = "Allow this app to access Camera."
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: "Settings", style: .default, handler: { (_) -> Void in
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString ) else {
                return
        }
        UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
        })
        let closeAction: UIAlertAction = UIAlertAction(title: "Close", style: .cancel, handler: nil)
        alert.addAction(settingsAction)
        alert.addAction(closeAction)
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(self, isExitImage: $isExitImage)
    }

    public func makeUIViewController(context: Context) -> UIImagePickerController {
        let viewController = UIImagePickerController()
        viewController.delegate = context.coordinator
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            viewController.sourceType = .camera
        }

        return viewController
    }
    public func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}

extension CameraView {
    public class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraView
        @Binding private var isExitImage: Bool
        var fileName = ""

        init(_ parent: CameraView , isExitImage: Binding<Bool>) {
            self.parent = parent
            self._isExitImage = isExitImage
        }

        public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                self.parent.image = uiImage
            }
            self.isExitImage = true
            self.parent.dismiss()
        }
        

        public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            self.parent.dismiss()
        }
    }
}
