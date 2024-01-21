//
//  QRScanner.swift
//  stroly
//
//  Created by 大坪雄也 on 2023/12/12.
//

// メルカリQRScannerを使ってQRを読み取る処理を書く
// 参考URL: https://qiita.com/tigercat1124/items/6a4c861c58783c273706 (メルカリQRScanner使用例)
//         https://engineering.mercari.com/blog/entry/2019-12-12-094129/#QRScanner%E3%81%A8%E3%81%AF (中の人によるメルカリQRScanner仕様説明)
//         https://github.com/mercari/QRScanner (メルカリQRScannerのリポジトリ)


import SwiftUI
import UIKit
import QRScanner

struct QrCodeScanner: UIViewControllerRepresentable {

     func makeUIViewController(context: Context) -> ViewController {
         let ViewController = ViewController()
         return ViewController
     }

     func updateUIViewController(_ uiViewController: ViewController, context: Context) {}

 }


final class ViewController: UIViewController {
    var QrCodeStr: Binding<String>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let qrScannerView = QRScannerView(frame: view.bounds)
        view.addSubview(qrScannerView)
        qrScannerView.configure(delegate: self)
        qrScannerView.startRunning()
    }
}

extension ViewController: QRScannerViewDelegate {
    func qrScannerView(_ qrScannerView: QRScannerView, didFailure error: QRScannerError) {
        print(error)
    }

    func qrScannerView(_ qrScannerView: QRScannerView, didSuccess code: String) {
        QrCodeStr?.wrappedValue = code
        print(code)
        addFrineds(frinedId: code)
        dismiss(animated: true, completion: nil)
    }
}
