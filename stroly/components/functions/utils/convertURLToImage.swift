//
//  convertURLToImage.swift
//  stroly
//
//  Created by 大坪雄也 on 2023/12/13.
//

import Foundation
import SwiftUI

// URL型からUIImageオプショナル型を作る処理
public func convertURLToImage(iconURL: URL) -> UIImage? {
    do {
        let data = try Data(contentsOf: iconURL)
            return UIImage(data: data)
        } catch {
            print("convertError")
        }
    return nil
}
