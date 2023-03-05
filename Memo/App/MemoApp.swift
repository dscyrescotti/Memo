//
//  MemoApp.swift
//  Memo
//
//  Created by Aye Chan on 3/2/23.
//

import SwiftUI

@main
struct MemoApp: App {
    init() {
        let thumbImage = UIImage(named: "thumbImage")
        UISlider.appearance().setThumbImage(thumbImage, for: .normal)
    }

    var body: some Scene {
        WindowGroup {
            RecorderView()
        }
    }
}
