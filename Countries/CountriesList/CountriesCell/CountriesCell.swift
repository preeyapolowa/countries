//
//  CountriesCell.swift
//  Countries
//
//  Created by Preeyapol Owatsuwan on 24/8/2565 BE.
//

import Foundation
import UIKit

class CountriesCell: UITableViewCell {
    @IBOutlet weak var bgView: UIView!
    
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var latLongLabel: UILabel!
    
    private var urlImage = "https://countryflagsapi.com/png/"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        iconImage.image = nil
    }
    
    private func setupUI() {
        bgView.setCornerRadius()
        iconImage.setCornerRadius()
        DispatchQueue.main.async {
            self.bgView.dropShadow(edge: .all)
        }
    }
    
    func updateUI() {
        urlImage = urlImage + "AU"
        if let url = URL(string: urlImage) {
            iconImage.downloadImage(from: url)
        } else {
            
        }
    }
}
