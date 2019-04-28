//
//  ScanTableViewCell.swift
//  chakuyo-bako
//
//  Created by Matsuno Shunya on 2019/04/27.
//  Copyright © 2019年 Matsuno Shunya. All rights reserved.
//

import UIKit

class ScanTableViewCell: UITableViewCell {

    @IBOutlet weak var identifierName: UILabel!
    
    @IBOutlet weak var parentView: UIView!
    @IBOutlet weak var cellView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.backgroundColor = UIColor.clear
        self.layer.shadowOpacity = 0.25
        self.layer.shadowRadius = 5
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
    
        self.cellView.backgroundColor = .white
        self.cellView.layer.cornerRadius = 10.0
        self.cellView.layer.masksToBounds = true

        
        self.parentView.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
