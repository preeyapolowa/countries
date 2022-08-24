//
//  Extension+UIImageView.swift
//  Countries
//
//  Created by Preeyapol Owatsuwan on 24/8/2565 BE.
//

import UIKit
import Foundation

class ImageLoader {
    static let shared = ImageLoader()
    var oldImages: [URL: UIImage] = [:]

    func downloadImage(from url: URL, completion: @escaping ((UIImage) -> Void)) {
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            if self.oldImages[url.absoluteURL] == UIImage(data: data) {
                DispatchQueue.main.async {
                    completion(self.oldImages[url.absoluteURL] ?? UIImage())
                }
            } else {
                DispatchQueue.main.async {
                    completion(UIImage(data: data) ?? UIImage())
                }
            }
            self.oldImages[url.absoluteURL] = UIImage(data: data)
        }
    }

    private func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        DispatchQueue.global(qos: .background).async {
            URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
        }
    }
}
