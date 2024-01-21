//
//  fetchPostsData.swift
//  stroly
//
//  Created by seiei on 2024/01/03.
//

import Foundation
import Alamofire

struct userResponse: Decodable {
    let name : String
    let userId : String
    let email : String
    let iconKey : String
    let numOfPosts : Int
    let numOfFriends : Int
    let posts : [postResponse]
}

// private let url = "https://backend.2xseitest.workers.dev/api/posts/all"から投稿の配列を受け取って返す関数

func fetchPostsData(completion: @escaping ([postResponse]) -> Void) {
    let url = "https://backend.2xseitest.workers.dev/api/posts/all"
    AF.request(url, method: .get, encoding: JSONEncoding.default).responseDecodable(completionHandler: { (response: DataResponse<[postResponse], AFError>) in
        switch response.result {
        case .success(let posts):
            completion(posts)
//            print("fetchPostsData: \(posts)")
        case .failure(let error):
            print(error)
        }
    })
}

// 左下の緯度経度、緯度経度の幅を引数にとる
// その範囲内の投稿を取得する関数
func fetchPostsDataByArea(latitude: Double, longitude: Double, latitudeDelta: Double, longitudeDelta: Double, completion: @escaping ([postResponse]) -> Void) {
    let url = "https://backend.2xseitest.workers.dev/api/posts/area?latitude=\(latitude)&longitude=\(longitude)&latitudeDelta=\(latitudeDelta)&longitudeDelta=\(longitudeDelta)"
    AF.request(url, method: .get, encoding: JSONEncoding.default).responseDecodable(completionHandler: { (response: DataResponse<[postResponse], AFError>) in
        switch response.result {
        case .success(let posts):
            completion(posts)
        case .failure(let error):
            print(error)
        }
    })
}

// 自分の投稿を取得する関数
func fetchMyPostsData(completion: @escaping ([postResponse]) -> Void) {
    let userId = UserDefaults.standard.string(forKey: "userId")!
    let url = "https://backend.2xseitest.workers.dev/api/user?isPost=true&userId=" + userId
    AF.request(url, method: .get, encoding: JSONEncoding.default).responseDecodable(completionHandler: { (response: DataResponse<[postResponse], AFError>) in
        switch response.result {
        case .success(let posts):
            completion(posts)
        case .failure(let error):
            print(response)
            print(error)
        }
    })
}
