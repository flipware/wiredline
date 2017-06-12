//
//  hluserlistcellTableViewCell.swift
//  hotwire
//
//  Created by flidap on 2015/07/07.
//  Copyright © 2015年 flidap. All rights reserved.
//

import UIKit

class hluserlistcellTableViewCell: UITableViewCell {
    
    @IBOutlet weak var usernamelabel: UILabel!
    @IBOutlet weak var iconview: UIImageView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
