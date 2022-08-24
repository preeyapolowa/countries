//
//  CountriesCell.swift
//  Countries
//
//  Created by Preeyapol Owatsuwan on 24/8/2565 BE.
//

import Foundation
import UIKit

struct CountriesCellModel {
    let country: String
    let name: String
    let lat: Double
    let long: Double
}

class CountriesCell: UITableViewCell {
    @IBOutlet weak var bgView: UIView!
    
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var latLongLabel: UILabel!
    
    private var urlImage = "https://countryflagsapi.com/png/"
    private let imageLoader = ImageLoader()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    private func setupUI() {
        bgView.setCornerRadius()
        iconImage.setCornerRadius()
        DispatchQueue.main.async {
            self.bgView.dropShadow(edge: .all)
        }
    }
    
    func updateUI(model: CountriesCellModel) {
        titleLabel.text = "\(model.name), \(model.country)"
        latLongLabel.text = "\(model.lat), \(model.long)"
        if let url = URL(string: "\(urlImage)\(model.country)") {
            imageLoader.downloadImage(from: url) { image in
                self.iconImage.image = image
            }
        } else {
            iconImage.image = UIImage(named: "ic_world_flag_default")
        }
    }
}
