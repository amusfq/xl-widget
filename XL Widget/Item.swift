//
//  Item.swift
//  XL Widget
//
//  Created by Achmad Musyaffa on 3/28/26.
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
