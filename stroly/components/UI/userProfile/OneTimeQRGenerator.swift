//
//  OneTimeQRGenerator.swift
//  stroly
//
//  Created by 大坪雄也 on 2023/12/12.
//

//参考URL: https://dev.classmethod.jp/articles/swift-generate-qr-code/ (QR画像の生成)

// 概要: フレンド認証用の”合言葉”をQRコード化してimageとして返す処理

// まだやってない部分: "合言葉"の生成処理、サーバーに”合言葉”を送る処理

import SwiftUI



struct QRCodeGenerator {

    func generate(with inputText: String) -> UIImage? {

        // 今後、今のinputTextの部分を、dateやuserNameを組み合わせたりして文字列を生成する.

        guard let qrFilter = CIFilter(name: "CIQRCodeGenerator")
        else { return nil }

        let inputData = inputText.data(using: .utf8)
        qrFilter.setValue(inputData, forKey: "inputMessage")
        // 誤り訂正レベルをHに指定
        qrFilter.setValue("H", forKey: "inputCorrectionLevel")

        guard let ciImage = qrFilter.outputImage
        else { return nil }

        // CIImageは小さい為、任意のサイズに拡大
        let sizeTransform = CGAffineTransform(scaleX: 10, y: 10)
        let scaledCiImage = ciImage.transformed(by: sizeTransform)

        // CIImageだとSwiftUIのImageでは表示されない為、CGImageに変換
        let context = CIContext()
        guard let cgImage = context.createCGImage(scaledCiImage,
                                                  from: scaledCiImage.extent)
        else { return nil }

        return UIImage(cgImage: cgImage)
    }
}
