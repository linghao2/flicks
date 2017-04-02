//
//  FlickTableViewCell.swift
//  Flicks
//
//  Created by LING HAO on 3/30/17.
//  Copyright © 2017 CodePath. All rights reserved.
//

import UIKit

class FlickTableViewCell: UITableViewCell {

    @IBOutlet var titleLabel: UILabel!
    
    @IBOutlet var overviewLabel: UILabel!
    
    @IBOutlet var posterImageView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
