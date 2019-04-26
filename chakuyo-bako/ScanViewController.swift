//
//  ViewController.swift
//  chakuyo-bako
//
//  Created by Matsuno Shunya on 2019/04/21.
//  Copyright © 2019年 Matsuno Shunya. All rights reserved.
//

import UIKit
import CoreBluetooth

class ScanViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, BluetoothDelegate  {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var scanButton: UIButton!
    
    var peripheralList:[CBPeripheral] = []
    
    let bluetoothManager = CoreBluetoothManager.getInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if bluetoothManager.connectedPeripheral != nil {
            print("connect something")
            //            bluetoothManager.disconnectPeripheral()
        }
        bluetoothManager.delegate = self
    }

    @IBAction func scanButtonDidPush(_ sender: Any) {
        print("scan pushed")
        bluetoothManager.scan()
    }
    
    // MARK: Table View Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peripheralList.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        bluetoothManager.connect(peripheral: peripheralList[indexPath.row])
    }
    
    // MARK: Table View Datasource
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel!.text = peripheralList[indexPath.row].name
        return cell
    }
    
    // MARK: - BluetoothDelegate
    func didDiscoverPeripheral(_ peripheral: CBPeripheral, advertisementData: [String : Any], RSSI: NSNumber) {
        peripheralList.append(peripheral)
        tableView.reloadData()
    }
    
    func didDiscoverServices(_ peripheral: CBPeripheral) {
        let next = storyboard!.instantiateViewController(withIdentifier: "DashboardViewController") as? DashboardViewController
        self.present(next!,animated: true, completion: { () in
            // next?.textField2.text = self.textField.text
            // next?.bluetoothManager = self.bluetoothManager
        })
    }
    
    func didReadValueForCharacteristic(_ characteristic: CBCharacteristic) {
//        let next = storyboard!.instantiateViewController(withIdentifier: "DashboardViewController") as? DashboardViewController
//        self.present(next!,animated: true, completion: { () in
//            // next?.textField2.text = self.textField.text
//        })
    }
}

