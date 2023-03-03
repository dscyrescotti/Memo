//
//  Double++.swift
//  Memo
//
//  Created by Aye Chan on 3/3/23.
//

import Foundation

extension Double {
    var decimals: Int {
        return Int(modf(self).1.round(to: 2) * 100) % 100
    }
    var second: Int {
        Int(self) % 60
    }
    var minute: Int {
        Int(self) / 60
    }
    var hour: Int {
        Int(self) / 3600
    }

    func round(to places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
