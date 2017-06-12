//
//  wiredTransferlistTableViewCell.swift
//  wiredline
//
//  Created by HiraoKazumasa on 2016/12/04.
//  Copyright © 2016 flidap. All rights reserved.
//

import UIKit

class wiredTransferlistTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var progress: UIProgressView!
    @IBOutlet weak var speedsize: UILabel!
    @IBOutlet weak var filename: UILabel!
    @IBOutlet weak var transfertype: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
