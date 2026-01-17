//
//  Item.swift
//  what2wear
//
//  Created by Ann Hsu on 1/17/26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
