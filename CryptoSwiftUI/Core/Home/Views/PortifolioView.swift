//
//  PortifolioView.swift
//  CryptoSwiftUI
//
//  Created by Marcylene Barreto on 23/06/22.
//

import SwiftUI

struct PortifolioView: View {
    @EnvironmentObject private var vm: HomeViewModel
    @State private var selectedCoin: CoinModel? = nil
    @State private var quantatyText: String = ""
    @State private var showCheckmark: Bool = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    SearchBarView(searchText: $vm.searchText)
                    coinLogoList
                    
                    if selectedCoin != nil {
                        portifolioInputSectionView
                    }
                }
            }
            .navigationTitle("Edit Portifolio")
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarLeading) {
                    XMarkButton()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    trailingNavBar
                }
            })
            .onChange(of: vm.searchText) { newValue in
                if newValue == "" {
                    removeSelectedCoin()
                }
            }
        }
    }
}

struct PortifolioView_Previews: PreviewProvider {
    static var previews: some View {
        PortifolioView()
    }
}


extension PortifolioView {
    
    private var coinLogoList: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 10) {
                ForEach(vm.searchText.isEmpty ? vm.portifolioCoins : vm.allCoins) { coin in
                    CoinLogoView(coin: coin)
                        .frame(width: 75)
                        .padding(4)
                        .onTapGesture {
                            withAnimation(.easeIn) {
                                updateSelectedCoin(coin: coin)
                            }
                        }
                        .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(selectedCoin?.id == coin.id ? Color.theme.greenColor : Color.clear, lineWidth: 1)
                        )
                }
            }
            .frame(height: 120)
            .padding(.leading)
        }
    }
    
    private func updateSelectedCoin(coin: CoinModel) {
        selectedCoin = coin
        if let portfolioCoin = vm.portifolioCoins.first(where: { $0.id == coin.id }),
        let amount = portfolioCoin.currentHoldings {
            quantatyText = "\(amount)"
        } else {
            quantatyText = ""
        }
    }
    
    private var portifolioInputSectionView: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Cuurent price of \(selectedCoin?.symbol.uppercased() ?? ""):")
                Spacer()
                Text(selectedCoin?.currentPrice.asCurrencyWith6Decimals() ?? "")
            }
            Divider()
            HStack {
                Text("Amount holding:")
                Spacer()
                TextField("Ex: 1.4", text: $quantatyText)
                    .multilineTextAlignment(.trailing)
                    .keyboardType(.decimalPad)
            }
            Divider()
            HStack {
                Text("Current value:")
                Spacer()
                Text(getCurrentValue().asCurrencyWith2Decimals())
            }
        }
        .animation(.none)
        .padding()
        .font(.headline)
    }
    
    private func getCurrentValue() -> Double {
        if let quantity = Double(quantatyText) {
            return quantity * (selectedCoin?.currentPrice ?? 0)
        }
        return 0
    }
    
    private var trailingNavBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark")
                .opacity(showCheckmark ? 1.0 : 0.0)
            Button(action: { saveButtonPressed() }) {
                Text("save".uppercased())
            }
            .opacity(
                (selectedCoin != nil && selectedCoin?.currentHoldings != Double(quantatyText)) ? 1.0 : 0.0
            )
        }
        .font(.headline)
    }
    
    private func saveButtonPressed() {
        guard
            let coin = selectedCoin,
            let amount = Double(quantatyText)
        else {return}
        
        //save to portfolio
        vm.updatePortfolio(coin: coin, amount: amount)
        
        //show checkmark
        withAnimation(.easeIn) {
            showCheckmark = true
            removeSelectedCoin()
        }
        // hide keyboard
        UIApplication.shared.endEditing()
        
        // hide checkmark
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeOut) {
                showCheckmark = false
            }
        }
    }
    
    private func removeSelectedCoin() {
        selectedCoin = nil
        vm.searchText = ""
    }
}
