//
//  Int++.swift
//  Memo
//
//  Created by Aye Chan on 3/3/23.
//

import Foundation

extension Int {
    func digits() -> [Int] {
        var digits: [Int] = []
        var num = self
        digits.append(num % 10)
        while num >= 10  {
            num = num / 10
            digits.append(num % 10)
        }
        return digits.reversed()
    }
}
