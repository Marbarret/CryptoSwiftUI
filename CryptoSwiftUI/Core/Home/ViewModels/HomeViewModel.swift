//
//  HomeViewModel.swift
//  CryptoSwiftUI
//
//  Created by Marcylene Barreto on 22/06/22.
//

import Foundation
import Combine

class HomeViewModel: ObservableObject {
    
    @Published var statistic: [StatisticModel] = []
    
    @Published var allCoins: [CoinModel] = []
    @Published var portifolioCoins: [CoinModel] = []
    @Published var searchText: String = ""
    @Published var isLoading: Bool = false
    @Published var sortOption: SortOption = .holding
    
    private let coinDataService = CoinDataService()
    private let marketDataService = MarketDataService()
    private let portfolioDataService = PortifolioDataService()
    private var cancellables = Set<AnyCancellable>()
    
    enum SortOption {
        case rank, rankReversed, holding, holdingsReverses, price, priceReversed
    }
    
    init() {
        addSubscribers()
    }
    
    func addSubscribers() {
        // update allCoins
        $searchText
            .combineLatest(coinDataService.$allCoins, $sortOption)
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .map(filterAndSortCoins)
            .sink { [weak self] (returnedCoins) in
                self?.allCoins = returnedCoins
            }
            .store(in: &cancellables)
        
        //update portfolioCoins
        $allCoins
            .combineLatest(portfolioDataService.$savedEntities)
            .map(mapAllCoinsToPortfolioCoins)
            .sink { [weak self] (returnedCoins) in
                guard let self = self else { return }
                self.portifolioCoins = self.sortPortifolioCoinsIfNeeded(coins: returnedCoins)
            }
            .store(in: &cancellables)
        
        // update marketData
        marketDataService.$marketData
            .combineLatest($portifolioCoins)
            .map(mapGlobalMarketData)
            .sink { [weak self] (returnedStats) in
                self?.statistic = returnedStats
                self?.isLoading = false
            }
            .store(in: &cancellables)
    }
    
    func updatePortfolio(coin: CoinModel, amount: Double) {
        portfolioDataService.updatePortfolio(coin: coin, amount: amount)
    }
    
    func reloadData() {
        isLoading = true
        coinDataService.getCoins()
        marketDataService.getData()
        HapticManager.notification(type: .success)
    }
    
    
    private func mapAllCoinsToPortfolioCoins(allCoins: [CoinModel], portfolioEntityCoins: [PortfolioEntity]) -> [CoinModel] {
        allCoins
            .compactMap { (coin) -> CoinModel? in
                guard let entity = portfolioEntityCoins.first(where: { $0.coinID == coin.id }) else { return nil }
                return coin.updateHoldings(amount: entity.amount)
            }
    }
    
    private func filterAndSortCoins(text: String, coins: [CoinModel], sort: SortOption) -> [CoinModel] {
        var updateCoins = filterCoins(text: text, coins: coins)
        // sort
        sortCoins(sort: sort, coins: &updateCoins)
        return updateCoins
    }
    
    private func sortCoins(sort: SortOption, coins: inout [CoinModel]) {
        switch sort {
        case .rank, .holding:
            coins.sort(by: { $0.rank < $1.rank })
        case .rankReversed, .holdingsReverses:
            coins.sort(by: { $0.rank > $1.rank })
        case .price:
            coins.sort(by: { $0.currentPrice > $1.currentPrice })
        case .priceReversed:
            coins.sort(by: { $0.currentPrice < $1.currentPrice })
        }
    }
    
    private func sortPortifolioCoinsIfNeeded(coins: [CoinModel]) -> [CoinModel] {
        switch sortOption {
        case .holding:
            return coins.sorted(by: { $0.currentHoldingsValue > $1.currentHoldingsValue })
        case .holdingsReverses:
            return coins.sorted(by: { $0.currentHoldingsValue < $1.currentHoldingsValue })
        default:
            return coins
        }
    }
    
    private func filterCoins(text: String, coins: [CoinModel]) -> [CoinModel] {
        guard !text.isEmpty else {
            return coins
        }
        
        let lowercasedText = text.lowercased()
        
        return coins.filter { (coin) -> Bool in
            return coin.name.lowercased().contains(lowercasedText) ||
            coin.symbol.lowercased().contains(lowercasedText) ||
            coin.id.lowercased().contains(lowercasedText)
        }
    }
    
    private func mapGlobalMarketData(markeDataModel: MarketDataModel?, portfolioCoins: [CoinModel]) -> [StatisticModel] {
        var stats: [StatisticModel] = []
        guard let data = markeDataModel else {
            return stats
        }
        
        let marketCap = StatisticModel(title: "Market Cap", value: data.marketCap, percentageChange: data.marketCapChangePercentage24HUsd)
        let volume = StatisticModel(title: "24h Volume", value: data.volume)
        let btcDominance = StatisticModel(title: "BTC Dominance", value: data.btcDominance)
        
        
        let portfolioValue = portfolioCoins
            .map( { $0.currentHoldingsValue } )
            .reduce(0, +)
        
        let previousValue = portfolioCoins
            .map { (coin) -> Double in
                let currentValue = coin.currentHoldingsValue
                let percentChange = (coin.priceChangePercentage24H ?? 0) / 100
                let previousValue = currentValue / (1 + percentChange)
                return previousValue
            }
            .reduce(0, +)
        
        let percentageChange = ((portfolioValue - previousValue) / previousValue) * 100
        
        let protifolio = StatisticModel(title: "Portifolio Value", value: portfolioValue.asCurrencyWith2Decimals(), percentageChange: percentageChange)
        
        stats.append(contentsOf: [
            marketCap,
            volume,
            btcDominance,
            protifolio
        ])
        return stats
    }
}
