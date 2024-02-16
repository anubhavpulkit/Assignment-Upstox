//
//  Stock.swift
//  Upstox
//
//  Created by Anubhav Singh on 15/02/24.
//

import Foundation

struct Stock: Codable, Hashable {
    let userHolding: [UserHolding]
}

struct UserHolding: Codable, Hashable {
    let symbol: String
    let quantity: Int
    let ltp, avgPrice: Double
    let close: Int
    var currentValue: Double {
        return ltp * Double(quantity)
    }
    var investmentValue: Double {
        return avgPrice * Double(quantity)
    }
    var pnl: Double {
        return (currentValue) - (investmentValue)
    }
    var todayPNL: Double {
        return (Double(close) - ltp) * Double(quantity)
        }
}

enum APIError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
}
