//
//  savePostsFunc.swift
//  stroly
//
//  Created by 長濱聖英 on 2024/01/16.
//

import Foundation
import UIKit
import SwiftData


// 自分の投稿をバックグランドで保存する関数
func saveMyPostsData(context: ModelContext)  {
    let fetchDescriptor = FetchDescriptor<MyPosts>()
    print("saving")
    let baseURL = "https://backend.2xseitest.workers.dev/api/"
    // myPostsのkeyからダウンロードして本体に保存する
    fetchMyPostsData(completion: { (posts) in
        for post in posts {
            // ModelContainerに保存
            let myPost = MyPosts(id: post.id, userId: post.userId, title: post.title, key: post.key, createdAt: post.createdAt, latitude: post.latitude, longitude: post.longitude,isPublic: post.isPublic,isFriendsOnly: post.isFriendsOnly, userName: post.userName, isPrivate: post.isPrivate)
            context.insert(myPost)
            let fileName = post.key
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let pictureURL = documentsURL.appendingPathComponent(fileName)
            let imageUrl = baseURL + post.key
            print(imageUrl)
            print(pictureURL)
            let url = URL(string: imageUrl)!
            URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data, error == nil else { return }
                print(response?.suggestedFilename ?? url.lastPathComponent)
                print("Download Finished")
                try! data.write(to: pictureURL)
            }.resume()
        }
        do {
            try context.save()
            let count = try context.fetchCount(fetchDescriptor)
            print("count: \(count)")
            saveFriendsData(context: context)
            return
        }
        catch {
            print("count error")
            return
        }
    })
    return
}
