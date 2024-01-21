//
//  CustomAnnotationView.swift
//  stroly
//
//  Created by 大沼優希人 on 2023/12/16.
//

import SwiftUI
import MapKit

class CustomAnnotationView: MKAnnotationView {
    // クラスタリング判定を受けるサイズ
    let width = 20
    let height = 20
    
    var imageUrl: String?
    var subview: UIView?

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        frame = CGRect(x: 0, y: 0, width: width, height: height)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForDisplay() {
        super.prepareForDisplay()

        // 古いsubviewがあれば削除
        subview?.removeFromSuperview()

        var vc: UIHostingController<CustomAnnotation>

        if let clusterAnnotation = annotation as? MKClusterAnnotation {
            let annotations = clusterAnnotation.memberAnnotations
            let firstAnnotation = annotations.first as? CustomPointAnnotation
            // isInPolygon パラメータを追加
            vc = UIHostingController(rootView: CustomAnnotation(count: clusterAnnotation.memberAnnotations.count, imageUrl: firstAnnotation?.imageUrl ?? ""))
        } else if let customAnnotation = annotation as? CustomPointAnnotation {
            imageUrl = customAnnotation.imageUrl
            // isInPolygon パラメータを追加
            vc = UIHostingController(rootView: CustomAnnotation(count: 0, imageUrl: imageUrl ?? ""))
        } else {
            return
        }

        vc.view.frame = bounds
        vc.view.backgroundColor = UIColor.clear
        subview = vc.view
        addSubview(vc.view)
    }
}
