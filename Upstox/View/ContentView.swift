//
//  ContentView.swift
//  Upstox
//
//  Created by Anubhav Singh on 15/02/24.
//

import SwiftUI

struct BottomTrayTextView: View {
    let title: String
    let value: Double
    
    var body: some View {
        HStack{
            Text(title)
                .bold()
            Spacer()
            Text("₹ \(value, specifier: "%.2f")")
        }
    }
}

struct ContentView: View {
    // MARK: - Properties
        
    // State property to control bottom tray view visibility
    @State private var bottomTrayView: Bool = false
    
    // Observed object to manage view model data
    @StateObject private var viewModel = ViewModel()
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            VStack{
                List{
                    ForEach(viewModel.responseData?.userHolding ?? [], id: \.self){ holding in
                        cellForHolding(with: holding)
                    }
                }
                VStack{
                    extendedView()
                }.safeAreaPadding(.all)
            }
            .overlay(
                Group {
                    if viewModel.isLoading {
                        ProgressView()
                    }
                }
            )
            .listStyle(PlainListStyle())
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("Upstox Holding")
                        .bold()
                        .foregroundColor(.white)
                }
            }
            .toolbarBackground(Color(red: 107/255, green: 29/255, blue: 140/255), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }.task {
            await viewModel.fetchData()
        }
    }
    
    // MARK: - Private Methods
      
    // Creates a cell for holding data in the list
    
    private func cellForHolding(with holding: UserHolding) -> some View {
        VStack(spacing: 20){
            HStack{
                Text("\(holding.symbol)")
                    .bold()
                Spacer()
                Text("LTP:") + Text(" ₹ \(holding.ltp, specifier: "%.2f")").bold()
            }
            HStack{
                Text("\(holding.quantity)")
                Spacer()
                Text("P/L:") + Text(" ₹ \(holding.pnl, specifier: "%.2f")").bold()
            }
        }
    }
    
    // Creates the extended view with bottom tray
    private func extendedView() -> some View {
        VStack(spacing: 15){
            Button(action: {
                withAnimation{
                    bottomTrayView.toggle()
                }
            }){
                Image(systemName: bottomTrayView ? "arrowtriangle.down.fill" : "arrowtriangle.up.fill")
                    .tint(Color(red: 157/255, green: 49/255, blue: 212/255))
            }
            if bottomTrayView {
                BottomTrayTextView(title: "Current Value:", value: viewModel.totalCurrentValue)
                BottomTrayTextView(title: "Total Investment:", value: viewModel.totalInvestmentValue)
                BottomTrayTextView(title: "Today's Profit & Loss:", value: viewModel.todayTotalPNL)
                    .padding(.bottom, 15)
            }
            BottomTrayTextView(title: "Profit & Loss:", value: viewModel.totalPNL)
        }
    }
}

#Preview {
    ContentView()
}
