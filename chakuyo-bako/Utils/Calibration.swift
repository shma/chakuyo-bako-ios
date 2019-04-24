////
////  Calibration.swift
////  chakuyo-bako
////
////  Created by Matsuno Shunya on 2019/04/24.
////  Copyright © 2019年 Matsuno Shunya. All rights reserved.
////
//
//import Foundation
//
//class Calibration {
//    
//    
//    func calibratedT(_ rawT: Int) -> Int {
//        var var1: Int
//        var var2: Int
//        var T: Int
//        var1 = ((((rawT >> 3) - (Int(digT1) << 1))) * (Int(digT2))) >> 11;
//        
//        // 計算式が複雑すぎるとコンパイラに怒られるので分割する
//        let tmp1: Int = ((rawT >> 4) - Int(digT1)) * ((rawT >> 4) - Int(digT1))
//        let tmp2: Int = tmp1 >> 12
//        var2 = (tmp2 * Int(digT3)) >> 14;
//        tFine = var1 + var2;
//        
//        T = (tFine * 5 + 128) >> 8;
//        return T;
//    }
//    
//    
//    func calibratedP(_ rawP: Int32) -> UInt32 {
//        
//        var var1: Int32
//        var var2: Int32
//        var P: UInt32
//        
//        var1 = ((Int32(tFine))>>1) - Int32(64000);
//        
//        var2 = (((var1 >> 2) * (var1 >> 2)) >> 11) * (Int32(digP6));
//        var2 = var2 + ((var1 * (Int32(digP5))) << 1);
//        var2 = (var2 >> 2) + ((Int32(digP4)) << 16);
//        let tmp1 = ((Int32(digP3) * (((var1 >> 2) * (var1 >> 2)) >> 13)) >> 3)
//        var1 = (tmp1 + (((Int32(digP2)) * var1)>>1)) >> 18;
//        
//        var1 = ((((32768 + var1)) * (Int32(digP1)))>>15);
//        if (var1 == 0) {
//            return 0;
//        }
//        
//        P = ((UInt32(((Int32(1048576) - rawP)) - (var2 >> 12)))) * 3125;
//        
//        if(P < 0x80000000) {
//            P = (P << 1) / (UInt32(var1));
//        } else {
//            P = (P / UInt32(var1)) * 2;
//        }
//        
//        var1 = ((Int32(digP9)) * (Int32(((P >> 3) * (P >> 3))>>13))) >> 12;
//        var2 = ((Int32(P>>2)) * (Int32(digP8)))>>13;
//        
//        P = UInt32(Int32(P) + ((var1 + var2 + Int32(digP7)) >> 4));
//        return P;
//    }
//    
//    
//    func calibrationH(_ adc_H: Int) -> UInt {
//        var vX1: Int
//        
//        vX1 = (tFine - (76800));
//        vX1 = (((((adc_H << 14) - ((Int(digH4)) << 20) - ((Int(digH5)) * vX1)) +
//            (16384)) >> 15) * (((((((vX1 * (Int(digH6))) >> 10) *
//                (((vX1 * (Int(digH3))) >> 11) + (32768))) >> 10) + (2097152)) *
//                (Int(digH2)) + 8192) >> 14));
//        vX1 = (vX1 - (((((vX1 >> 15) * (vX1 >> 15)) >> 7) * (Int(digH1))) >> 4));
//        vX1 = (vX1 < 0 ? 0 : vX1);
//        vX1 = (vX1 > 419430400 ? 419430400 : vX1);
//        return UInt(vX1 >> 12);
//    }
//}
