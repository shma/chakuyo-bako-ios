//
//  EnvironmentData.swift
//  chakuyo-bako
//
//  Created by Matsuno Shunya on 2019/04/27.
//  Copyright © 2019年 Matsuno Shunya. All rights reserved.
//

import Foundation
import RealmSwift

class EnvironmentData: Object {
    @objc dynamic var pressure = 0.0
    @objc dynamic var humidity = 0.0
    @objc dynamic var temperture = 0.0
    @objc dynamic var measuringDate: Date?
}

class MeasuringDate: Object {
    @objc dynamic var date: Date?
    let environmentData = List<EnvironmentData>()
    
//    override static func primaryKey() -> String? {
//        return "date"
//    }
}
