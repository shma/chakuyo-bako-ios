//
//  ViewController.swift
//  chakuyo-bako
//
//  Created by Matsuno Shunya on 2019/04/21.
//  Copyright © 2019年 Matsuno Shunya. All rights reserved.
//

import UIKit
import CoreBluetooth
import NVActivityIndicatorView


class ScanViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, BluetoothDelegate  {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var scanButton: UIButton!
    @IBOutlet weak var searchingLabel: UILabel!
    @IBOutlet weak var emptyStateView: UIView!
    
    var peripheralList:[CBPeripheral] = []
    var isScanning = false
    var isConnecting = false
    
    let bluetoothManager = CoreBluetoothManager.getInstance()
    var connectingView: LoadingView!
    
    override func viewWillAppear(_ animated: Bool) {
        emptyStateView.isHidden = false
        bluetoothManager.delegate = self
        isScanning = false
        
        if bluetoothManager.connectedPeripheral != nil {
            print("connect something")
            bluetoothManager.disconnectPeripheral()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        connectingView = Bundle.main.loadNibNamed("LoadingView", owner: self, options: nil)!.first! as! LoadingView
        connectingView.backgroundColor = UIColor.clear
        connectingView.messageLabel.text = "接続中です"
        connectingView.frame = self.view.frame
        self.view.addSubview(connectingView)
        connectingView.isHidden = true
        
        
        tableView.register(UINib(nibName: "ScanTableViewCell", bundle: nil), forCellReuseIdentifier: "ScanTableViewCell")
        tableView.backgroundColor = UIColor(red: 241/255, green: 242/255, blue: 244/255, alpha: 1)
        tableView.tableFooterView = UIView(frame: .zero)
        
        scanButton.backgroundColor = UIColor(red: 29 / 255, green: 150 / 255, blue: 120 / 255, alpha: 1)
        scanButton.layer.cornerRadius = scanButton.frame.height / 2
        scanButton.layer.shadowOpacity = 0.25
        scanButton.layer.shadowRadius = 5
        scanButton.layer.shadowOffset = CGSize(width: 0, height: 10)
        
        //　ナビゲーションバーの背景色
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 29 / 255, green: 150 / 255, blue: 120 / 255, alpha: 1)
        self.navigationController?.navigationBar.tintColor = .white
    }

    @IBAction func scanButtonDidPush(_ sender: Any) {
        if isScanning {
            stopScan()
        } else {
            startScan()
        }
        isScanning = !isScanning
    }
    
    private func connecting() {
        connectingView.isHidden = false
    }
    
    private func stopScan() {
        bluetoothManager.stopScanPeripheral()
        scanButton.setImage(UIImage(named: "SearchIcon"), for: .normal)
        searchingLabel.text = ""
    }
    
    private func startScan() {
        peripheralList = []
        tableView.reloadData()
        bluetoothManager.scan()
        scanButton.setImage(UIImage(named: "IconPause"), for: .normal)
        searchingLabel.text = "検索中です"
    }
    
    // MARK: Table View Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peripheralList.count
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        bluetoothManager.connect(peripheral: peripheralList[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: true)
        connecting()
    }
    
    // MARK: Table View Datasource
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ScanTableViewCell = tableView.dequeueReusableCell(withIdentifier: "ScanTableViewCell", for: indexPath) as! ScanTableViewCell
        cell.identifierName.text = peripheralList[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.clear
    }
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.clear
    }
    
    // MARK: - BluetoothDelegate
    func didDiscoverPeripheral(_ peripheral: CBPeripheral, advertisementData: [String : Any], RSSI: NSNumber) {
        emptyStateView.isHidden = true
        peripheralList.append(peripheral)
        tableView.reloadData()
    }
    
    func didDiscoverServices(_ peripheral: CBPeripheral) {
        let next = storyboard!.instantiateViewController(withIdentifier: "DashboardViewController") as? DashboardViewController
        let navigationController = UINavigationController(rootViewController: next!)

        self.present(navigationController,animated: true, completion: { () in
            self.peripheralList = []
            self.tableView.reloadData()
            self.stopScan()
            self.connectingView.isHidden = true
        })
    }
}

