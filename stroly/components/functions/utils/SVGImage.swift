//
//  SVGImage.swift
//  stroly
//
//  Created by 小平暖太 on 2024/01/17.
//

import SwiftUI

struct SVGImage: UIViewControllerRepresentable {
    
    let controller: Coordinator
    var imageColor: UIColor?

    init(name: String) {
        controller = Coordinator(name: name)
    }

    func makeCoordinator() -> Coordinator {
        controller
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<SVGImage>) -> UIViewController {
        let viewController = UIViewController()
                // 初期設定などを行う
                updateImageColor()
                return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<SVGImage>) {
        uiViewController.view = controller.imageView
                updateImageColor()
    }

    func scaledToFill() -> Self {
        controller.contentMode(.scaleAspectFill)
        return self
    }

    func scaledToFit() -> Self {
        controller.contentMode(.scaleAspectFit)
        return self
    }

    func renderingMode(_ renderingMode: Image.TemplateRenderingMode?) -> Self {
        switch renderingMode {
        case .original:
            controller.renderingMode(.alwaysOriginal)
        case .template:
            controller.renderingMode(.alwaysTemplate)
        default:
            controller.renderingMode(.automatic)
        }
        return self
    }

    func imageColor(_ color: Color) -> Self {
        let uiColor = UIColor(color)
        controller.imageColor(uiColor)
        return self
    }

    func imageColor(_ color: UIColor) -> Self {
        controller.imageColor(color)
        return self
    }
    
    private func updateImageColor() {
           if let color = imageColor {
               controller.imageColor(color)
           }
       }

    class Coordinator {
        let name: String
        let imageView = UIImageView()

        init(name: String) {
            self.name = name
            imageView.image = UIImage(named: name)
        }

        func contentMode(_ mode: UIView.ContentMode) {
            imageView.contentMode = mode
        }

        func renderingMode(_ renderingMode: UIImage.RenderingMode) {
            imageView.image = imageView.image?.withRenderingMode(renderingMode)
        }

        func imageColor(_ color: UIColor) {
            imageView.tintColor = color
            renderingMode(.alwaysTemplate)
        }
    }
}
