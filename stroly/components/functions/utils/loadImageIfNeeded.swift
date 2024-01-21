//
//  loadImageIfNeeded.swift
//  stroly
//
//  Created by 大沼優希人 on 2024/01/14.
//

import Foundation
import UIKit

// ディスクキャッシュ用のヘルパーメソッド
extension FileManager {
    static func getDiskCacheURL(for key: String) -> URL? {
        guard let cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else { return nil }
        return cacheDirectory.appendingPathComponent("\(key.hash)")
    }
}

public func loadImageIfNeeded(imageUrl: String) -> UIImage? {
    guard let url = URL(string: imageUrl) else { return nil }
    var image: UIImage?

    // ディスクキャッシュから画像を取得
    if let fileURL = FileManager.getDiskCacheURL(for: imageUrl),
       let diskCachedImage = UIImage(contentsOfFile: fileURL.path) {
        image = diskCachedImage
    } else {
        // 画像がキャッシュにない場合、非同期で読み込む
        loadImageAsync(from: url) { loadedImage in
            if let loadedImage = loadedImage, let fileURL = FileManager.getDiskCacheURL(for: imageUrl) {
                try? loadedImage.pngData()?.write(to: fileURL, options: [.atomicWrite])
            }
        }
    }

    return image
}

// この関数を非同期的に呼び出す
func loadImageAsync(from url: URL, completion: @escaping (UIImage?) -> Void) {
    URLSession.shared.dataTask(with: url) { data, response, error in
        guard let data = data, error == nil, let image = UIImage(data: data) else {
            DispatchQueue.main.async {
                completion(nil)
            }
            return
        }
        DispatchQueue.main.async {
            completion(image)
        }
    }.resume()
}
