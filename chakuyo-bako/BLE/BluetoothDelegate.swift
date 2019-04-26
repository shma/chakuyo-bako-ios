//
//  BluetoothDelegate.swift
//  chakuyo-bako
//
//  Created by Matsuno Shunya on 2019/04/24.
//  Copyright © 2019年 Matsuno Shunya. All rights reserved.
//
//  Based on :
//  BluetoothDelegate.swift
//  Swift-LightBlue
//
//  Created by Pluto Y on 16/1/11.
//  Copyright © 2016年 Pluto-y. All rights reserved.
//

import CoreBluetooth

public protocol BluetoothDelegate : NSObjectProtocol {
    /**
     The callback function when the bluetooth has updated.
     
     - parameter state: The newest state
     */
    func didUpdateState(_ state: CBManagerState)
    
    /**
     The callback function when peripheral has been found.
     
     - parameter peripheral:        The peripheral has been found.
     - parameter advertisementData: The advertisement data.
     - parameter RSSI:              The signal strength.
     */
    func didDiscoverPeripheral(_ peripheral: CBPeripheral, advertisementData: [String : Any], RSSI: NSNumber)
    
    /**
     The callback function when central manager connected the peripheral successfully.
     
     - parameter connectedPeripheral: The peripheral which connected successfully.
     */
    func didConnectedPeripheral(_ connectedPeripheral: CBPeripheral)
    
    /**
     The callback function when central manager failed to connect the peripheral.
     
     - parameter connectedPeripheral: The peripheral which connected failure.
     - parameter error:               The connected failed error message.
     */
    func failToConnectPeripheral(_ peripheral: CBPeripheral, error: Error)
    
    /**
     The callback function when the services has been discovered.
     
     - parameter peripheral: Peripheral which provide this information and contain services information
     */
    func didDiscoverServices(_ peripheral: CBPeripheral)
    
    /**
     The callback function when the peripheral disconnected.
     
     - parameter peripheral: The peripheral which provide this action
     */
    func didDisconnectPeripheral(_ peripheral: CBPeripheral)
    
    /**
     The callback function when interrogate the peripheral is timeout
     
     - parameter peripheral: The peripheral which is failed to discover service
     */
    func didFailedToInterrogate(_ peripheral: CBPeripheral)
    
    /**
     The callback function when discover characteritics successfully.
     
     - parameter service: The service information include characteritics.
     */
    func didDiscoverCharacteritics(_ service: CBService)
    
    /**
     The callback function when peripheral failed to discover charateritics.
     
     - parameter error: The error information.
     */
    func didFailToDiscoverCharacteritics(_ error: Error)
    
    /**
     The callback function when discover descriptor for characteristic successfully
     
     - parameter characteristic: The characteristic which has the descriptor
     */
    func didDiscoverDescriptors(_ characteristic: CBCharacteristic)
    
    /**
     The callback function when failed to discover descriptor for characteristic
     
     - parameter error: The error message
     */
    func didFailToDiscoverDescriptors(_ error: Error)
    
    /**
     The callback function invoked when peripheral read value for the characteristic successfully
     
     - parameter characteristic: The characteristic withe the value
     */
    func didReadValueForCharacteristic(_ characteristic: CBCharacteristic)
    
    /**
     The callback function invoked when failed to read value for the characteristic
     
     - parameter error: The error message
     */
    func didFailToReadValueForCharacteristic(_ error: Error)

    // Konashi Original ここにあるの微妙
    func didReadEnvironmentData(tempCal: Double, presCal: Double, humCal: Double)
}

extension BluetoothDelegate {

    func didUpdateState(_ state: CBManagerState) {}
    
    func didDiscoverPeripheral(_ peripheral: CBPeripheral, advertisementData: [String : Any], RSSI: NSNumber) {}
    
    func didConnectedPeripheral(_ connectedPeripheral: CBPeripheral) {}

    func failToConnectPeripheral(_ peripheral: CBPeripheral, error: Error) {}
    

    func didDiscoverServices(_ peripheral: CBPeripheral) {}

    func didDisconnectPeripheral(_ peripheral: CBPeripheral) {}
    

    func didFailedToInterrogate(_ peripheral: CBPeripheral) {}
    

    func didDiscoverCharacteritics(_ service: CBService) {}
    

    func didFailToDiscoverCharacteritics(_ error: Error) {}
    

    func didDiscoverDescriptors(_ characteristic: CBCharacteristic) {}
    

    func didFailToDiscoverDescriptors(_ error: Error) {}
    

    func didReadValueForCharacteristic(_ characteristic: CBCharacteristic) {}
    

    func didFailToReadValueForCharacteristic(_ error: Error) {}


    func didReadEnvironmentData(tempCal: Double, presCal: Double, humCal: Double) {}
}
