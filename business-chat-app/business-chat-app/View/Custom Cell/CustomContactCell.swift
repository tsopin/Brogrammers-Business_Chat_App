//
//  CustomContactCell.swift
//  business-chat-app
//
//  Created by Timofei Sopin on 2018-03-09.
//  Copyright © 2018 Brogrammers. All rights reserved.
//

import UIKit

class CustomContactCell: UITableViewCell {

    @IBOutlet weak var userPic: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userEmail: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }
    
}
