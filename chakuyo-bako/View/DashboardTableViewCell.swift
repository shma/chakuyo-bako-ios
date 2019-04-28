//
//  DashboardTableViewCell.swift
//  chakuyo-bako
//
//  Created by Matsuno Shunya on 2019/04/27.
//  Copyright © 2019年 Matsuno Shunya. All rights reserved.
//

import UIKit
import Charts

class DashboardTableViewCell: UITableViewCell {

    @IBOutlet weak var environmentLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var chartView: LineChartView!
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
        
        chartView.dragEnabled = false
        chartView.highlightPerTapEnabled = false
        
        chartView.rightAxis.enabled = false
        chartView.legend.enabled = false
        chartView.highlightPerTapEnabled = false
        chartView.doubleTapToZoomEnabled = false
        
        chartView.xAxis.enabled = true
        chartView.xAxis.axisLineWidth = 0
        chartView.xAxis.labelPosition = .bottom
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
