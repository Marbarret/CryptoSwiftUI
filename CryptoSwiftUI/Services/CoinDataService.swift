//
//  CoinDataService.swift
//  CryptoSwiftUI
//
//  Created by Marcylene Barreto on 22/06/22.
//

import Foundation
import Combine

class CoinDataService {
    
    @Published var allCoins: [CoinModel] = []
    var coinSubcription: AnyCancellable?
    
    init() {
        getCoins()
    }
    
    func getCoins() {
        guard let url = URL(string: "https://api.coingecko.com/api/v3/coins/markets?vs_currency=brl&order=market_cap_desc&per_page=100&page=1&sparkline=true&price_change_percentage=24h") else {return}
        
        coinSubcription = NetworkingManager.download(url: url)
            .decode(type: [CoinModel].self, decoder: JSONDecoder())
            .sink(receiveCompletion: NetworkingManager.handleCompletion, receiveValue: { [weak self] (returnCoins) in
                self?.allCoins = returnCoins
                self?.coinSubcription?.cancel()
            })
    }
}
