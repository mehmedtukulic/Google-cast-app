//
//  VideoCell.swift
//  GoogleTest
//
//  Created by Mehmed Tukulic on 25/03/2021.
//

import UIKit

class VideoCell: UITableViewCell {

    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setup(title: String, image: UIImage){
        titleLabel.text = title
        thumbnail.image = image
    }
    
}
