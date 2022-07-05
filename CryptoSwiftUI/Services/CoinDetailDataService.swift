//
//  CoinDetailDataService.swift
//  CryptoSwiftUI
//
//  Created by Marcylene Barreto on 27/06/22.
//

import Foundation
import Combine

class CoinDetailDataService {
    
    @Published var coinDetails: CoinDetailModel? = nil
    var coinDetailSubcription: AnyCancellable?
    let coin: CoinModel
    
    init(coin: CoinModel) {
        self.coin = coin
        getCoinDetails()
    }
    
    func getCoinDetails() {
        guard let url = URL(string: "https://api.coingecko.com/api/v3/coins/\(coin.id)?localization=false&tickers=false&market_data=false&community_data=false&developer_data=false&sparkline=false") else {return}
        
        coinDetailSubcription = NetworkingManager.download(url: url)
            .decode(type: CoinDetailModel.self, decoder: JSONDecoder())
            .sink(receiveCompletion: NetworkingManager.handleCompletion, receiveValue: { [weak self] (returnDetailsCoins) in
                self?.coinDetails = returnDetailsCoins
                self?.coinDetailSubcription?.cancel()
            })
    }
}
