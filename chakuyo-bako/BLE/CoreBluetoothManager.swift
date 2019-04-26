import UIKit
import CoreBluetooth

public class CoreBluetoothManager: NSObject, CBCentralManagerDelegate, CBPeripheralManagerDelegate, CBPeripheralDelegate {
    var delegate: BluetoothDelegate?
    
    var centralManager: CBCentralManager!
    var connectedPeripheral: CBPeripheral!
    var peripherals: [CBPeripheral] = []
    var peripheralManager: CBPeripheralManager!
    var isScanning = false
    
    var i2cConfig: CBCharacteristic?
    var i2cStartStop: CBCharacteristic?
    var i2cWriteC: CBCharacteristic?
    var i2cReadParameter: CBCharacteristic?
    var i2cRead: CBCharacteristic?
    
    // BME 280　Settings
    let OSRST = 1
    let OSRSP = 1
    let OSRSH = 1           //Humidity oversampling x 1
    let NORMAL_MODE = 3           //Normal mode
    let TSB = 5         //Tstandby 1000ms
    let FILTER = 0           //Filter off
    let SPI3WEN = 0         //3-wire SPI Disable
    let ADDR_ID = 0xD0
    let ADDR_BME280: UInt8 = 0x76
    
    var readSequenceCount = 0
    var datas = [UInt8]()
    
    // TODO:  外に出したいず
    var digT1: UInt16 = 0
    var digT2: Int16 = 0
    var digT3: Int16 = 0
    var digP1: UInt16 = 0
    var digP2: Int16 = 0
    var digP3: Int16 = 0
    var digP4: Int16 = 0
    var digP5: Int16 = 0
    var digP6: Int16 = 0
    var digP7: Int16 = 0
    var digP8: Int16 = 0
    var digP9: Int16 = 0
    var digH1: Int8 = 0
    var digH2: Int16 = 0
    var digH3: Int8 = 0
    var digH4: Int16 = 0
    var digH5: Int16 = 0
    var digH6: Int8 = 0
    
    var CTRL_MEAS_REG: UInt8 = 0
    var CONFIG_REG: UInt8 = 0
    var CTRL_HUM_REG: UInt8 = 0
    
    // BME280のかキャリブレーション用グローバル変数。重要
    var tFine: Int = 0
    
    /// Save the single instance
    static private var instance : CoreBluetoothManager {
        return sharedInstance
    }

    private static let sharedInstance = CoreBluetoothManager()

    override init() {
        super.init()
        initCBCentralManager()
    }

    // MARK: Custom functions
    /**
     Initialize CBCentralManager instance
     */
    func initCBCentralManager() {
        CTRL_MEAS_REG = UInt8((OSRST << 5) | (OSRSP << 2) | NORMAL_MODE);
        CONFIG_REG    = UInt8((TSB << 5) | (FILTER << 2) | SPI3WEN);
        CTRL_HUM_REG  = UInt8(OSRSH);
        
        // Corebluetoothのマネージャーを初期化
        centralManager = CBCentralManager(delegate: self, queue: nil)
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }

    /**
     Singleton pattern method

     - returns: Bluetooth single instance
     */
    static func getInstance() -> CoreBluetoothManager {
        return instance
    }
    
    func scan() {
        centralManager?.scanForPeripherals(withServices: nil, options: nil)
    }

    func stopScanPeripheral() {
        centralManager?.stopScan()
    }

    func connect(peripheral: CBPeripheral) {
        centralManager?.connect(peripheral, options: [CBConnectPeripheralOptionNotifyOnDisconnectionKey : true])
    }
    
    // MARK: - CentralManager Delegate
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        //TODO: Status OKの時にしか接続しに行かないとうの処理を入れます。
        print("state: \(central.state)")
    }
    
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        guard let _ = advertisementData["kCBAdvDataLocalName"] else {
            return
        }
        
        if !peripherals.contains(peripheral) {
            peripherals.append(peripheral)
        }
        
        delegate?.didDiscoverPeripheral(peripheral, advertisementData: advertisementData, RSSI: RSSI)
    }
    
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
        connectedPeripheral = peripheral
        peripheral.delegate = self
        let serviceId = CBUUID(string: "229BFF00-03FB-40DA-98A7-B0DEF65C2D4B")
        peripheral.discoverServices([serviceId])
    }
    
    // MARK: - PeripheralManager Delegate
    public func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        print("peripheral state : \(peripheral.state)")
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else {
            print("no services found")
            return
        }
        
        services.forEach{service in
            peripheral.discoverCharacteristics(nil, for: service)
        }
        
        delegate?.didDiscoverServices(peripheral)
    }
    
        func discoverCharacteristics() {
            guard let connectedPeripheral = connectedPeripheral else {
                return
            }
    
            let services = connectedPeripheral.services
            if services == nil || services!.count < 1 { // Validate service array
                return;
            }
    
            for service in services! {
                connectedPeripheral.discoverCharacteristics(nil, for: service)
            }
        }
    
    // Characteristicsを登録する
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characteristics = service.characteristics {
            // Characteristicsを登録
            characteristics.forEach{characteristic in
                switch characteristic.uuid.uuidString {
                case "229B300B-03FB-40DA-98A7-B0DEF65C2D4B":
                    i2cConfig = characteristic
                    break
                case "229B300C-03FB-40DA-98A7-B0DEF65C2D4B":
                    i2cStartStop = characteristic
                    break
                case "229B300D-03FB-40DA-98A7-B0DEF65C2D4B":
                    i2cWriteC = characteristic
                    break
                case "229B300E-03FB-40DA-98A7-B0DEF65C2D4B":
                    i2cReadParameter = characteristic
                    break
                case "229B300F-03FB-40DA-98A7-B0DEF65C2D4B":
                    i2cRead = characteristic
                    break
                default:
                    break
                }
            }
            
            readEnvironmentData()
        }
    }
    
    public func readEnvironmentData() {
        // 前回読み込みが失敗していても、強い気持ちで読みにいく。
        self.readSequenceCount = 0
        
        guard let i2cConfig = i2cConfig,
            let i2cRead = i2cRead
            else {
                return
        }
        
        // KonashiをI2Cモードに
        writeValue(uData: [0x01], characteristic: i2cConfig)
        
        
        i2cWrite([CTRL_HUM_REG], address: 0xF2);
        i2cWrite([CTRL_MEAS_REG], address: 0xF4);
        i2cWrite([CONFIG_REG], address: 0xF5);
        
        i2cWrite([0x88])
        i2cReadRequest(readLength: 0x08)
        connectedPeripheral.readValue(for: i2cRead)
        
        i2cWrite([0x90])
        i2cReadRequest(readLength: 8)
        connectedPeripheral.readValue(for: i2cRead)
        
        i2cWrite([0x98])
        i2cReadRequest(readLength: 8)
        connectedPeripheral.readValue(for: i2cRead)
        
        i2cWrite([CTRL_HUM_REG], address: 0xF2);
        i2cWrite([CTRL_MEAS_REG], address: 0xF4);
        i2cWrite([CONFIG_REG], address: 0xF5);
        
        i2cWrite([0xA1])
        i2cReadRequest(readLength: 1)
        connectedPeripheral.readValue(for: i2cRead)
        
        i2cWrite([CTRL_HUM_REG], address: 0xF2);
        i2cWrite([CTRL_MEAS_REG], address: 0xF4);
        i2cWrite([CONFIG_REG], address: 0xF5);
        
        i2cWrite([0xE1])
        i2cReadRequest(readLength: 7)
        connectedPeripheral.readValue(for: i2cRead)
        
        // しつこく書き込む
        i2cWrite([CTRL_HUM_REG], address: 0xF2);
        i2cWrite([CTRL_MEAS_REG], address: 0xF4);
        i2cWrite([CONFIG_REG], address: 0xF5);
        
        // 気温・気圧・湿度をくださいリクエスト
        i2cWrite([0xF7])
        i2cReadRequest(readLength: 8)
        connectedPeripheral.readValue(for: i2cRead)
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard let data = characteristic.value else {return}
        
        switch readSequenceCount {
        case 0:
            datas = datas + data[0...7]
            readSequenceCount += 1
            break
        case 1:
            datas = datas + data[0...7]
            readSequenceCount += 1
            break
        case 2:
            datas = datas + data[0...7]
            readSequenceCount += 1
            break
        case 3:
            datas = datas + [data[0]]
            readSequenceCount += 1
            break
        case 4:
            datas = datas + data[0...6]
            readSequenceCount += 1

            let d = datas

            // 全てのデータが揃ったら操作しやすいように配列に格納
            self.digT1 = (UInt16(d[1]) << 8) | UInt16(d[0])
            self.digT2 = (Int16(d[3]) << 8) | Int16(d[2])
            self.digT3 = (Int16(d[5]) << 8) | Int16(d[4])
            self.digP1 = (UInt16(d[7]) << 8) | UInt16(d[6])
            self.digP2 = (Int16(d[9]) << 8) | Int16(d[8])
            self.digP3 = (Int16(d[11]) << 8) | Int16(d[10])
            self.digP4 = (Int16(d[13]) << 8) | Int16(d[12])
            self.digP5 = (Int16(d[15]) << 8) | Int16(d[14])
            self.digP6 = (Int16(d[17]) << 8) | Int16(d[16])
            self.digP7 = (Int16(d[19]) << 8) | Int16(d[18])
            self.digP8 = (Int16(d[21]) << 8) | Int16(d[20])
            self.digP9 = (Int16(d[23]) << 8) | Int16(d[22])
            self.digH1 = Int8(d[24])
            self.digH2 = (Int16(d[26]) << 8) | Int16(d[25])
            self.digH3 = Int8(d[27])
            self.digH4 = (Int16(d[28]) << 4) | (0x0F & Int16(d[29]))
            self.digH5 = (Int16(d[30]) << 4) | ((Int16(d[29]) >> 4) & 0x0F)
            self.digH6 = Int8(d[31]);
            break

        case 5:
            var environmentData = [Int]()
            //UInt8でくるのでキャリブレーション用にIntにキャスト
            environmentData = data[0...7].map{Int($0)}

            let presRaw = (environmentData[0] << 12) | (environmentData[1] << 4) | (environmentData[2] >> 4)
            let tempRaw = ((environmentData[3] << 12) | (environmentData[4] << 4) | (environmentData[5] >> 4))
            let humRaw  = ((environmentData[6] << 8) | environmentData[7])

            // キャリブレーションをかける。
            let tempCal = Double(calibratedT(tempRaw)) / 100.0
            let presCal = Double(calibratedP(Int32(presRaw))) / 100.0
            let humCal = Double(calibrationH(humRaw)) / 1024.0
            
            self.delegate?.didReadEnvironmentData(tempCal: tempCal, presCal: presCal, humCal: humCal)

            self.readSequenceCount = 0
            self.datas.removeAll()
            break
        default:
            break
        }
    }
    
    // MARK: - Private Functions
    private func writeValue(uData: [UInt8], characteristic: CBCharacteristic) {
        let data = Data(bytes: uData)
        connectedPeripheral.writeValue(data, for: characteristic, type: .withoutResponse)
    }
    
    private func i2cWrite(_ uData: [UInt8], address: UInt8? = nil) {
        i2cStartCondition()
        
        var writeAddress:[UInt8] = [(0x76 << 1) & 0b11111110]
        
        if address != nil {
            writeAddress.append(address!)
        }
        
        let writeData = writeAddress + uData
        let dataCount = UInt8(writeData.count)
        
        let data = [dataCount] + writeData
        
        writeValue(uData: data, characteristic: i2cWriteC!)
        i2cStopCondition()
    }
    
    private func i2cReadRequest(readLength: UInt8) {
        i2cStartCondition()
        let request = Data(bytes: [readLength, ((0x76 << 1) | 0x1)])
        connectedPeripheral.writeValue(request, for: i2cReadParameter!, type: .withoutResponse)
        i2cStopCondition()
    }
    
    private func i2cStartCondition() {
        writeValue(uData: [0x01], characteristic: i2cStartStop!)
    }
    
    private func i2cStopCondition() {
        writeValue(uData: [0x00], characteristic: i2cStartStop!)
    }
    
    func calibratedT(_ rawT: Int) -> Int {
        var var1: Int
        var var2: Int
        var T: Int
        var1 = ((((rawT >> 3) - (Int(digT1) << 1))) * (Int(digT2))) >> 11;
        
        // 計算式が複雑すぎるとコンパイラに怒られるので分割する
        let tmp1: Int = ((rawT >> 4) - Int(digT1)) * ((rawT >> 4) - Int(digT1))
        let tmp2: Int = tmp1 >> 12
        var2 = (tmp2 * Int(digT3)) >> 14;
        tFine = var1 + var2;
        
        T = (tFine * 5 + 128) >> 8;
        return T;
    }
    
    
    func calibratedP(_ rawP: Int32) -> UInt32 {
        
        var var1: Int32
        var var2: Int32
        var P: UInt32
        
        var1 = ((Int32(tFine))>>1) - Int32(64000);
        
        var2 = (((var1 >> 2) * (var1 >> 2)) >> 11) * (Int32(digP6));
        var2 = var2 + ((var1 * (Int32(digP5))) << 1);
        var2 = (var2 >> 2) + ((Int32(digP4)) << 16);
        let tmp1 = ((Int32(digP3) * (((var1 >> 2) * (var1 >> 2)) >> 13)) >> 3)
        var1 = (tmp1 + (((Int32(digP2)) * var1)>>1)) >> 18;
        
        var1 = ((((32768 + var1)) * (Int32(digP1)))>>15);
        if (var1 == 0) {
            return 0;
        }
        
        P = ((UInt32(((Int32(1048576) - rawP)) - (var2 >> 12)))) * 3125;
        
        if(P < 0x80000000) {
            P = (P << 1) / (UInt32(var1));
        } else {
            P = (P / UInt32(var1)) * 2;
        }
        
        var1 = ((Int32(digP9)) * (Int32(((P >> 3) * (P >> 3))>>13))) >> 12;
        var2 = ((Int32(P>>2)) * (Int32(digP8)))>>13;
        
        P = UInt32(Int32(P) + ((var1 + var2 + Int32(digP7)) >> 4));
        return P;
    }
    
    
    func calibrationH(_ adc_H: Int) -> UInt {
        var vX1: Int
        
        vX1 = (tFine - (76800));
        vX1 = (((((adc_H << 14) - ((Int(digH4)) << 20) - ((Int(digH5)) * vX1)) +
            (16384)) >> 15) * (((((((vX1 * (Int(digH6))) >> 10) *
                (((vX1 * (Int(digH3))) >> 11) + (32768))) >> 10) + (2097152)) *
                (Int(digH2)) + 8192) >> 14));
        vX1 = (vX1 - (((((vX1 >> 15) * (vX1 >> 15)) >> 7) * (Int(digH1))) >> 4));
        vX1 = (vX1 < 0 ? 0 : vX1);
        vX1 = (vX1 > 419430400 ? 419430400 : vX1);
        return UInt(vX1 >> 12);
    }
}
