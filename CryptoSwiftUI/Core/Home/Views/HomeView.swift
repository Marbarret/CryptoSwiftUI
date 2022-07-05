//
//  HomeView.swift
//  CryptoSwiftUI
//
//  Created by Marcylene Barreto on 21/06/22.
//

import SwiftUI

struct HomeView: View {
    @State private var showPortifolio: Bool = false
    @State private var showPortifolioView: Bool = false //new view
    @State private var showSettingsView: Bool = false //
    @EnvironmentObject private var vm: HomeViewModel
    
    @State private var selectedCoin: CoinModel? = nil
    @State private var showDetailView: Bool = false
    
    var body: some View {
        ZStack {
            Color.theme.background
                .ignoresSafeArea()
            // new view
                .sheet(isPresented: $showPortifolioView) {
                    PortifolioView()
                }
            VStack {
                homeHeader
                HomeStatsView(showPortifolio: $showPortifolio)
                SearchBarView(searchText: $vm.searchText)
                
                columnList
                
                if !showPortifolio {
                    allCoinList
                        .transition(.move(edge: .leading))
                }
                if showPortifolio {
                    portifolioCoinList
                        .transition(.move(edge: .trailing))
                }
                
                Spacer(minLength: 0)
            }
            .sheet(isPresented: $showSettingsView) {
                SettingsView()
            }
        }
        .background(
            NavigationLink(
                destination: LoadingDetailsView(coin: $selectedCoin),
                isActive: $showDetailView,
                label: { EmptyView() })
        )
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HomeView()
                .navigationBarHidden(true)
        }
        .environmentObject(dev.homeVM)
    }
}

extension HomeView {
    private var homeHeader: some View {
        HStack {
            CircleButtonView(iconName: showPortifolio ? "plus" : "info")
                .animation(.none)
            // proxima view
                .onTapGesture {
                    if showPortifolio {
                        showPortifolioView.toggle()
                    } else {
                        showSettingsView.toggle()
                    }
                }
                .background(
                    ClickButtonAnimationView(animation: $showPortifolio)
                )
            Spacer()
            
            Text(showPortifolio ? "Portifolio" : "Live Prices")
                .font(.headline)
                .fontWeight(.heavy)
                .foregroundColor(Color.theme.accent)
                .animation(.none)
            
            Spacer()
            CircleButtonView(iconName: "chevron.right")
                .rotationEffect(Angle(degrees: showPortifolio ? 180 : 0))
                .onTapGesture {
                    withAnimation(.spring()) {
                        showPortifolio.toggle()
                    }
                }
        }
        .padding()
    }
    
    private var allCoinList: some View {
        List {
            ForEach(vm.allCoins) {coin in
                CoinRowView(coin: coin, showHoldingsColumn: false)
                    .listRowInsets(.init(top: 10, leading: 0, bottom: 10, trailing: 10))
                    .onTapGesture {
                        segueView(coin: coin)
                    }
            }
        }
        .listStyle(PlainListStyle())
    }
    
    private func segueView(coin: CoinModel) {
        selectedCoin = coin
        showDetailView.toggle()
    }
    
    private var portifolioCoinList: some View {
        List {
            ForEach(vm.portifolioCoins) {coin in
                CoinRowView(coin: coin, showHoldingsColumn: true)
                    .listRowInsets(.init(top: 10, leading: 0, bottom: 10, trailing: 10))
                    .onTapGesture {
                        segueView(coin: coin)
                    }
            }
        }
        .listStyle(PlainListStyle())
    }
    
    private var columnList: some View {
        HStack {
            HStack(spacing: 4) {
                Text("Coin")
                Image(systemName: "chevron.down")
                    .opacity((vm.sortOption == .rank || vm.sortOption == .rankReversed) ? 1.0 : 0.0)
                    .rotationEffect(Angle(degrees: vm.sortOption == .rank ? 0 : 180))
            }
            .onTapGesture {
                withAnimation(.default) {
                    vm.sortOption = vm.sortOption == .rank ? .rankReversed : .rank
                }
            }
            
            Spacer()
            if showPortifolio {
                HStack(spacing: 4) {
                    Text("Holding")
                    Image(systemName: "chevron.down")
                        .opacity((vm.sortOption == .holding || vm.sortOption == .holdingsReverses) ? 1.0 : 0.0)
                        .rotationEffect(Angle(degrees: vm.sortOption == .holding ? 0 : 180))
                }
                .onTapGesture {
                    withAnimation(.default) {
                        vm.sortOption = vm.sortOption == .holding ? .holdingsReverses : .holding
                    }
                }
            }
            HStack(spacing: 4) {
                Text("Price")
                Image(systemName: "chevron.down")
                    .opacity((vm.sortOption == .price || vm.sortOption == .priceReversed) ? 1.0 : 0.0)
                    .rotationEffect(Angle(degrees: vm.sortOption == .price ? 0 : 180))
            }
            .frame(width: UIScreen.main.bounds.width / 3.5, alignment: .trailing)
            .onTapGesture {
                withAnimation(.default) {
                    vm.sortOption = vm.sortOption == .price ? .priceReversed : .price
                }
            }
            
            Button {
                withAnimation {
                    vm.reloadData()
                }
            } label: {
                Image(systemName: "goforward")
            }
            .rotationEffect(Angle(degrees: vm.isLoading ? 360 : 0), anchor: .center)
            
        }
        .font(.caption)
        .foregroundColor(Color.theme.secondaryColor)
        .padding(.horizontal)
    }
}
