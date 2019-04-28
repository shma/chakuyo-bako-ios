//
//  DashboardViewController.swift
//  chakuyo-bako
//
//  Created by Matsuno Shunya on 2019/04/24.
//  Copyright © 2019年 Matsuno Shunya. All rights reserved.
//

import UIKit
import CoreBluetooth
import RealmSwift
import Charts

enum Environment: Int {
    case temperature = 0
    case humidity = 1
    case pressure = 2
}

class DashboardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, BluetoothDelegate {    

    let bluetoothManager = CoreBluetoothManager.getInstance()

    @IBOutlet weak var tableView: UITableView!
    
    var isViewAppear = true
    
    var intervalTimer: Timer?
    var tempCal: Double = 0.0
    var humCal: Double = 0.0
    var presCal: Double = 0.0
    
    let realm = try! Realm()
    let calendar = Calendar(identifier: .gregorian)
    var date: Date = Date()
    var measuringDate: MeasuringDate = MeasuringDate()
    
    var connectingView: LoadingView!
    
    var backgroundTaskIdentifier: UIBackgroundTaskIdentifier = UIBackgroundTaskIdentifier(rawValue: 0)
    
    let formatter = DateFormatter()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        formatter.dateFormat = "HH:mm"
        formatter.locale = Locale(identifier: "ja_JP")
        initView()
        
        // 自動で読み取り
        backgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask {
            UIApplication.shared.endBackgroundTask(self.backgroundTaskIdentifier)
        }
        intervalTimer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(update), userInfo: nil, repeats: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Init Realm Database
        let startDate = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: Date())
        let endDate = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: Date())
        guard let newDate = realm.objects(MeasuringDate.self).filter("date >= %@ AND date < %@", startDate!, endDate!).first else {
            let newDate = MeasuringDate()
            newDate.date = date
            
            try! realm.write {
                realm.add(newDate)
            }
            
            self.measuringDate = newDate
            
            return
        }
        
        self.measuringDate = newDate
        
        isViewAppear = true
        bluetoothManager.delegate = self
        update()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        isViewAppear = false
    }
    
    @objc func update() {
        if isViewAppear {
            connectingView.isHidden = false
        }
        bluetoothManager.readEnvironmentData()
    }
    
    private func initView() {
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 29 / 255, green: 150 / 255, blue: 120 / 255, alpha: 1)
        self.navigationController?.navigationBar.tintColor = .white
        
        connectingView = Bundle.main.loadNibNamed("LoadingView", owner: self, options: nil)!.first! as? LoadingView
        connectingView.backgroundColor = UIColor.clear
        connectingView.messageLabel.text = "データ取得中"
        connectingView.frame = self.view.frame
        self.view.addSubview(connectingView)
        connectingView.isHidden = false
        
        tableView.register(UINib(nibName: "DashboardTableViewCell", bundle: nil), forCellReuseIdentifier: "DashboardTableViewCell")
        tableView.backgroundColor = UIColor(red: 241/255, green: 242/255, blue: 244/255, alpha: 1)
        tableView.tableFooterView = UIView(frame: .zero)
    }
    
    /*
     * Chartを表示
     * chartViewにdataを詰める
     */
    private func drawChart(chartView: LineChartView, type: Environment) {
        
        
        var dates: [String] = []
        let values = self.measuringDate.environmentData.enumerated().map {(arg) -> ChartDataEntry in
            let (index, envData) = arg
            var yVal: Double = 0.0
            
            let date = formatter.string(from: envData.measuringDate!)
            dates.append(date)
            
            switch type {
            case .humidity :
                yVal = envData.humidity
                break
            case .temperature:
                yVal = envData.temperture
                break
            case .pressure:
                yVal = envData.pressure
                break
            }
            return ChartDataEntry(x: Double(index), y: yVal)
        }
        
        
        let set1 = LineChartDataSet(entries: values, label: "気温")
        set1.axisDependency = .left
        
        var color: UIColor!
        switch type {
        case .humidity :
            color = UIColor(red: 0/255, green: 144/255, blue: 232/255, alpha: 1)
            break
        case .temperature:
            color = UIColor(red: 255/255, green: 90/255, blue: 95/255, alpha: 1)
            break
        case .pressure:
            color = UIColor(red: 237/255, green: 174/255, blue: 73/255, alpha: 1)
            break
        }
        
        set1.setColor(color)
        set1.fillColor = color
        set1.lineWidth = 1.5
        set1.drawCirclesEnabled = false
        set1.drawValuesEnabled = false
        set1.drawFilledEnabled = true
        set1.fillAlpha = 1.0
        set1.mode = .cubicBezier

        set1.highlightColor = UIColor(red: 244/255, green: 117/255, blue: 117/255, alpha: 1)
        set1.drawCircleHoleEnabled = false
        
        let data = LineChartData(dataSet: set1)
        data.setValueTextColor(.white)
        data.setValueFont(.systemFont(ofSize: 9, weight: .light))
        
        chartView.xAxis.valueFormatter = IndexAxisValueFormatter(values:dates)
        chartView.xAxis.granularity = 10
        chartView.data = data

    }
    
    
    /**
     * MARK - BluetoothDelegate
    **/
    func didReadEnvironmentData(tempCal: Double, presCal: Double, humCal: Double) {
        date = Date()
        
        let environmentData = EnvironmentData()
        environmentData.humidity = humCal
        environmentData.pressure = presCal
        environmentData.temperture = tempCal
        environmentData.measuringDate = date
        
        let startDate = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: Date())
        let endDate = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: Date())
        guard let _ = realm.objects(MeasuringDate.self).filter("date >= %@ AND date < %@", startDate!, endDate!).first else {
            let newDate = MeasuringDate()
            newDate.date = date
            
            try! realm.write {
                newDate.environmentData.append(environmentData)
                realm.add(newDate)
            }
            self.measuringDate = newDate
            return
        }
        
        try! realm.write {
            measuringDate.environmentData.append(environmentData)
            realm.add(measuringDate)
        }
        
        self.tempCal = tempCal
        self.humCal = humCal
        self.presCal = presCal
        
        print("isViewAppear", isViewAppear)
        
        if isViewAppear {
            connectingView.isHidden = true
            tableView.reloadData()
        }
    }
    
    @IBAction func settingButtonPushed(_ sender: Any) {
        let next = storyboard!.instantiateViewController(withIdentifier: "SettingViewController") as? SettingViewController
        let navigationController = UINavigationController(rootViewController: next!)
        
        self.present(navigationController,animated: true, completion: nil)
        // bluetoothManager.disconnectPeripheral()
    }
    

    
    func didDisconnectPeripheral(_ peripheral: CBPeripheral) {
        intervalTimer?.invalidate()
        
        // 切断されたら通知を送る。
        let notificationManager = NotificationManager()
        notificationManager.notificationDisconnect()
        
        bluetoothManager.delegate = nil
        self.dismiss(animated: true, completion: nil)
    }
    
    /**
     * MARK - TableViewDelegate
     **/
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let next = storyboard!.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController
        next?.type = Environment(rawValue: indexPath.row)
        self.navigationController?.pushViewController(next!, animated: true)
    }
    
    // MARK: Table View Datasource
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: DashboardTableViewCell = tableView.dequeueReusableCell(withIdentifier: "DashboardTableViewCell", for: indexPath) as! DashboardTableViewCell

        switch indexPath.row {
        case Environment.temperature.rawValue:
            cell.environmentLabel.text = "気温"
            cell.valueLabel.text = String(ceil(tempCal*100)/100) + "℃"
            self.drawChart(chartView: cell.chartView, type: .temperature)
        case Environment.humidity.rawValue:
            cell.environmentLabel.text = "湿度"
            cell.valueLabel.text = String(ceil(humCal*100)/100) + "%"
            self.drawChart(chartView: cell.chartView, type: .humidity)
        case Environment.pressure.rawValue:
            cell.environmentLabel.text = "気圧"
            cell.valueLabel.text = String(ceil(presCal*100)/100) + "hPa"
            self.drawChart(chartView: cell.chartView, type: .pressure)
        default:
            break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 240
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.clear
    }
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.clear
    }
}
