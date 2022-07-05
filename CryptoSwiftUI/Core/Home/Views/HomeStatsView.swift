//
//  HomeStatsView.swift
//  CryptoSwiftUI
//
//  Created by Marcylene Barreto on 23/06/22.
//

import SwiftUI

struct HomeStatsView: View {
    @EnvironmentObject private var vm: HomeViewModel
    @Binding var showPortifolio: Bool
    
    var body: some View {
        HStack {
            ForEach(vm.statistic) { statistic in
                StatisticView(stat: statistic)
                    .frame(width: UIScreen.main.bounds.width / 3)
            }
        }
        .frame(width: UIScreen.main.bounds.width,
               alignment: showPortifolio ? .trailing : .leading
        )
    }
}

struct HomeStatsView_Previews: PreviewProvider {
    static var previews: some View {
        HomeStatsView(showPortifolio: .constant(false))
            .environmentObject(dev.homeVM)
    }
}
