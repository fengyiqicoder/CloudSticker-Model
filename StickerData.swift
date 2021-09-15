//
//  StickerData.swift
//  Vibe
//
//  Created by Edmund Feng on 2021/4/14.
//
#if os(iOS)
import UIKit
#else
import AppKit
#endif
import CloudKit

struct StickerData: Codable {
    var uuid: String
    var fontSize: CGFloat
    var colorInt: Int
    var content: String

    init(uuid: String, fontSize: CGFloat, colorInt: Int, content: String) {
        self.uuid = uuid
        self.fontSize = fontSize
        self.colorInt = colorInt
        self.content = content
    }

    init(record: CKRecord) {
        uuid = record["uuid"] as! String
        fontSize = CGFloat(record["fontSize"] as! Double)
        colorInt = record["colorInt"] as! Int
        content = record["content"] as! String
    }

    static var defaultNewData: StickerData {
        StickerData(uuid: UUID().uuidString,
                    fontSize: Settings.current.stickerConfig.defualtFontSize,
                    colorInt: 0,
                    content: "")
    }

    // 只有id相等,其他的属性有不同
    static func !== (left: StickerData, right: StickerData) -> Bool {
        guard left.uuid == right.uuid else { return false }
        if left.fontSize != right.fontSize { return true }
        if left.colorInt != right.colorInt { return true }
        if left.content != right.content { return true }
        return false
    }

    // 完全相等
    static func === (left: StickerData, right: StickerData) -> Bool {
        if left.uuid == right.uuid,
           left.fontSize == right.fontSize,
           left.colorInt == right.colorInt,
           left.content == right.content {
            return true
        } else {
            return false
        }
    }
}
