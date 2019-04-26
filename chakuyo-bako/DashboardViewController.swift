//
//  DashboardViewController.swift
//  chakuyo-bako
//
//  Created by Matsuno Shunya on 2019/04/24.
//  Copyright © 2019年 Matsuno Shunya. All rights reserved.
//

import UIKit
import CoreBluetooth

class DashboardViewController: UIViewController, BluetoothDelegate {

    let bluetoothManager = CoreBluetoothManager.getInstance()
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var presLabel: UILabel!
    @IBOutlet weak var humLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
         bluetoothManager.delegate = self
//          bluetoothManager.readEnvironmentData()
        // Do any additional setup after loading the view.
        
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true, block: {_ in
            self.bluetoothManager.readEnvironmentData()
        })
    }
        
    // MARK - BluetoothDelegate
    func didReadEnvironmentData(tempCal: Double, presCal: Double, humCal: Double) {
        tempLabel.text = String(tempCal)
        presLabel.text = String(presCal)
        humLabel.text = String(humCal)
    }

}
