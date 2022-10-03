//
//  ShareMenueTableViewCell.swift
//  FX
//
//  Created by Apple on 07/09/22.
//

import UIKit

class ShareMenueTableViewCell: UITableViewCell {

    @IBOutlet weak var checkBoxButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    public func configure(_ text: String, selected: Bool) {
        titleLabel.text = text
        configureSelected(selected)
    }

    public func configureSelected(_ selected: Bool) {
        let image = selected ? "checked-checkbox" : "unchecked-checkbox"
        checkBoxButton.setImage(UIImage(named: image), for: .normal)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
