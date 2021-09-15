////
////  LocalDataCenter.swift
////  Vibe
////
////  Created by Edmund Feng on 2021/4/14.
////

import Foundation


class LocalDataCenter {
    var stickers: [StickerData] {
        get {
            if let jsonData = (UserDefaults.standard.object(forKey: "LocalDataCenter") as? Data) {
                return try! JSONDecoder().decode([StickerData].self, from: jsonData)
            } else {
                return []
            }
        }
        set {
            let jsonData = try! JSONEncoder().encode(newValue)
//            let jsonString = String(data: jsonData, encoding: .utf8)
//            print(jsonString)
            UserDefaults.standard.setValue(jsonData, forKey: "LocalDataCenter")
        }
    }
}
