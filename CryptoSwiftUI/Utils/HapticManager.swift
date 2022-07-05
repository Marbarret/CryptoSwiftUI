//
//  HapticManager.swift
//  CryptoSwiftUI
//
//  Created by Marcylene Barreto on 24/06/22.
//

import Foundation
import SwiftUI

class HapticManager {
    static private let generator = UINotificationFeedbackGenerator()
    
    static func notification(type: UINotificationFeedbackGenerator.FeedbackType) {
        generator.notificationOccurred(type)
    }
}
