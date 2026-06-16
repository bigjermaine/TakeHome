//
//  AppRoutes.swift
//  TakeHome
//
//  Created by jermaine daniel on 15/06/2026.
//

import Foundation

enum AppRoute: Hashable {
    case login
    case main
}

enum ProductRoute: Hashable {
    case detail(productID: Int)
    case editor(productID: Int?)
}

enum TabRoute: Hashable {
    case products
    case favorites
    case settings
}
