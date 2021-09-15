//
//  Bin.swift
//  Vibe
//
//  Created by Edmund Feng on 2021/4/25.
//

import AppKit

class Bin {
    static let shared = Bin()
    
    func add(_ sticker: StickerData) {
        if _data.count > 10 {
            _data.removeFirst()
        }
        _data.append(sticker)
    }
    
    var data: [StickerData] {
        self._data
    }
    
    func clearAll() {
        _data.removeAll()
    }
    
    private var _data: [StickerData] {
        set {
            let json = try! JSONEncoder().encode(newValue)
            UserDefaults.standard.setValue(json, forKey: "bin")
        }
        get {
            if let json = UserDefaults.standard.value(forKey: "bin") as? Data{
                let value = try! JSONDecoder().decode([StickerData].self, from: json )
                return value
            } else {
                return []
            }
        }
    }
}
