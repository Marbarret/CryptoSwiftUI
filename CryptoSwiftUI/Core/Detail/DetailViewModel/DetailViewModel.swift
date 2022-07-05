//
//  DetailViewModel.swift
//  CryptoSwiftUI
//
//  Created by Marcylene Barreto on 27/06/22.
//

import Foundation
import Combine

class DetailViewModel: ObservableObject {
    
    @Published var overviewStatistics: [StatisticModel] = []
    @Published var additionalStatistics: [StatisticModel] = []
    @Published var coinDescription: String? = nil
    @Published var websiteURL: String? = nil
    @Published var redditURL: String? = nil
    
    @Published var coin: CoinModel
    private let coinDetailService: CoinDetailDataService
    private var cancellables = Set<AnyCancellable>()
    
    init(coin: CoinModel) {
        self.coin = coin
        self.coinDetailService = CoinDetailDataService(coin: coin)
        self.addSubscribers()
    }
    
    private func addSubscribers() {
        coinDetailService.$coinDetails
            .combineLatest($coin)
            .map(mapDataToStatistics)
            .sink { [weak self] (returnedCoins) in
                self?.overviewStatistics = returnedCoins.overview
                self?.additionalStatistics = returnedCoins.additional
            }
            .store(in: &cancellables)
        
        coinDetailService.$coinDetails
            .sink { [weak self] (returnedDetailCoins) in
                self?.coinDescription = returnedDetailCoins?.readableDescription
                self?.websiteURL = returnedDetailCoins?.links?.homepage?.first
                self?.websiteURL = returnedDetailCoins?.links?.subredditURL
            }
            .store(in: &cancellables)
    }
    
    private func mapDataToStatistics(coinDetailModel: CoinDetailModel?, coinModel: CoinModel) -> (overview: [StatisticModel], additional: [StatisticModel]) {
        
        let overviewArray = createOverviewArray(coinModel: coinModel)
        let additionalArray = createAdditionalArray(coinDetailModel: coinDetailModel, coinModel: coinModel)
        return (overviewArray, additionalArray)
    }
    
    private func createOverviewArray(coinModel: CoinModel) -> [StatisticModel] {
        let price = coinModel.currentPrice.asCurrencyWith6Decimals()
        let pricePercentChange = coinModel.priceChangePercentage24H
        let priceStat = StatisticModel(title: "Current Price", value: price, percentageChange: pricePercentChange)
        
        let marketCap = "$" + (coinModel.marketCap?.formattedWithAbbreviations() ?? "")
        let marketCapChange = coinModel.marketCapChangePercentage24H
        let marketCapStat = StatisticModel(title: "Market Capitalization", value: marketCap, percentageChange: marketCapChange)
        
        let rank = "\(coinModel.rank)"
        let rankStat = StatisticModel(title: "Rank", value: rank)
        
        let volume = "$" + (coinModel.totalVolume?.formattedWithAbbreviations() ?? "" )
        let volumeStat = StatisticModel(title: "Volume", value: volume)
        
        let overviewArray: [StatisticModel] = [
            priceStat, marketCapStat, rankStat, volumeStat
        ]
        
        return overviewArray
    }
    
    private func createAdditionalArray(coinDetailModel: CoinDetailModel?, coinModel: CoinModel) -> [StatisticModel] {
        
        let high = coinModel.high24H?.asCurrencyWith6Decimals() ?? "n/a"
        let highStat = StatisticModel(title: "24h high", value: high)
        
        let low = coinModel.low24H?.asCurrencyWith6Decimals() ?? "n/a"
        let lowStat = StatisticModel(title: "24h low", value: low)
        
        let priceChange = coinModel.priceChange24H?.asCurrencyWith6Decimals() ?? "n/a"
        let priceChangePercent = coinModel.priceChangePercentage24H
        let priceChangeStat = StatisticModel(title: "24h Price Change", value: priceChange, percentageChange: priceChangePercent)
        
        let marketChange = "$" + (coinModel.marketCapChange24H?.formattedWithAbbreviations() ?? "" )
        let marketChangePercent2 = coinModel.marketCapChangePercentage24H
        let marketChangeStat = StatisticModel(title: "24h Market Cap Change", value: marketChange, percentageChange: marketChangePercent2)
        
        let blockTime = coinDetailModel?.blockTimeInMinutes ?? 0
        let blockTimeString = blockTime == 0 ? "n/a" : "\(blockTime)"
        let blockStat = StatisticModel(title: "Block Time", value: blockTimeString)
        
        let hashing = coinDetailModel?.hashingAlgorithm ?? "n/a"
        let hashingStat = StatisticModel(title: "Hashing Algorithm", value: hashing)
        
        let additionalArray: [StatisticModel] = [
            highStat, lowStat, priceChangeStat, marketChangeStat, blockStat, hashingStat
        ]
        
        return additionalArray
    }
}
