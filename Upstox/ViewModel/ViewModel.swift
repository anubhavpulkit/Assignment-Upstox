//
//  ViewModel.swift
//  Upstox
//
//  Created by Anubhav Singh on 15/02/24.
//

import Foundation
import UIKit
import SwiftUI

class ViewModel: ObservableObject {
    
    // MARK: - Properties
    
    // Published property to hold fetched data
    @Published var responseData: Stock?
    
    // Published property to indicate loading state
    @Published var isLoading = false
    
    // MARK: - Computed Properties
    
    // Computes the total current value of user holdings
    var totalCurrentValue: Double {
        return responseData?.userHolding.reduce(0) { $0 + $1.currentValue } ?? 0.0
    }
    
    // Computes the total investment value of user holdings
    var totalInvestmentValue: Double {
        return responseData?.userHolding.reduce(0) { $0 + $1.investmentValue } ?? 0.0
    }
    
    // Computes the total profit or loss (PNL)
    var totalPNL: Double {
        return totalCurrentValue - totalInvestmentValue
    }
    
    // Computes the total profit or loss (PNL) for today
    var todayTotalPNL: Double {
        return responseData?.userHolding.reduce(0) { $0 + $1.todayPNL } ?? 0.0
    }
    
    // MARK: - Methods
    
    // Asynchronously fetches data from API
    func fetchData() async {
        do {
            let fetchedData = try await fetchDataFromAPI()
            DispatchQueue.main.async {
                self.isLoading = false
                self.responseData = fetchedData
            }
        } catch {
            print("Error fetching data: \(error)")
        }
    }
    
    // Fetches data from the API endpoint
    private func fetchDataFromAPI() async throws -> Stock {
        isLoading = true
        let endpoint = "https://run.mocky.io/v3/bde7230e-bc91-43bc-901d-c79d008bddc8"
        guard let url = URL(string: endpoint) else {
            throw APIError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        
        do {
            return try JSONDecoder().decode(Stock.self, from: data)
        }
        catch {
            // Handle invalid data and stop loading state
            self.isLoading = false
            throw APIError.invalidData
        }
    }
}

