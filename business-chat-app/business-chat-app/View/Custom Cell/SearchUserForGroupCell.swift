//
//  SearchUserForGroupCell.swift
//  business-chat-app
//
//  Created by Timofei Sopin on 2018-03-15.
//  Copyright © 2018 Brogrammers. All rights reserved.
//

import UIKit

class SearchUserForGroupCell: UITableViewCell {
    
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var userName: UILabel!

    @IBOutlet weak var isSelectedImage: UIImageView!
    var showing = false
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            
            if showing == false {
                isSelectedImage.isHidden = false
                showing = true
                
            } else {
                self.isSelectedImage.isHidden = true
                showing = false
            }
            
        }
    }
    
    func cronfigureCell(email: String, userName: String, isSelected: Bool) {
        
        self.email.text = email
        self.userName.text = userName
        
        if isSelected {
            self.isSelectedImage.isHidden = false
            
        } else {
            self.isSelectedImage.isHidden = true
        }
        
        
        
    }
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    

    
}
