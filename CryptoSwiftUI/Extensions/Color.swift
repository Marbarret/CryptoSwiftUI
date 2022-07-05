//
//  Color.swift
//  CryptoSwiftUI
//
//  Created by Marcylene Barreto on 21/06/22.
//

import Foundation
import SwiftUI

extension Color {
    static let theme = ColorTheme()
    static let launch = LaunchTheme()
}

struct ColorTheme {
    let accent = Color("AccentColor")
    let background = Color("Background")
    let greenColor = Color("GreenColor")
    let redColor = Color("RedColor")
    let secondaryColor = Color("SecondaryColor")
}

struct LaunchTheme {
    let launchAccent = Color("LaunchAccentColor")
    let launchBackground = Color("LaunchBackground")
}
