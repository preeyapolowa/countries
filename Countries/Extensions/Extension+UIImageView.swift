//
//  Extension+UIImageView.swift
//  Countries
//
//  Created by Preeyapol Owatsuwan on 24/8/2565 BE.
//

import UIKit
import Foundation

extension UIImageView {
    func downloadImage(from url: URL) {
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            if url.absoluteString.hasSuffix("svg") {
                DispatchQueue.main.async { [weak self] in
                    self?.image = UIImage(data: data)
                }
            } else {
                DispatchQueue.main.async { [weak self] in
                    self?.image = UIImage(data: data)
                }
            }
        }
    }

    private func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
}
