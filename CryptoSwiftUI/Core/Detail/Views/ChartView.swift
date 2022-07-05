//
//  ChartView.swift
//  CryptoSwiftUI
//
//  Created by Marcylene Barreto on 27/06/22.
//

import SwiftUI

struct ChartView: View {
    private let data: [Double]
    private let maxY: Double
    private let minY: Double
    private let lineColor: Color
    private let startingDate: Date
    private let endingDate: Date
    @State private var percente: CGFloat = 0
    
    init(coin: CoinModel) {
        data = coin.sparklineIn7D?.price ?? []
        maxY = data.max() ?? 0
        minY = data.min() ?? 0
        
        let priceChange = (data.last ?? 0) - (data.first ?? 0)
        lineColor = priceChange > 0 ? Color.theme.greenColor : Color.theme.redColor
        
        endingDate = Date(coinGeckoString: coin.lastUpdated ?? "")
        startingDate = endingDate.addingTimeInterval(-7*24*60*60)
    }
    
    var body: some View {
        VStack {
            chartView
                .frame(height: 200)
                .background(lineChartGraphic)
                .overlay(chartDetail, alignment: .leading)
            
            HStack {
                Text(startingDate.asShortDateString())
                Spacer()
                Text(endingDate.asShortDateString())
            }
            .padding(.horizontal, 4)
        }
        .font(.headline)
        .foregroundColor(Color.theme.secondaryColor)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation(.linear(duration: 2.0)) {
                    percente = 1.0
                }
            }
        }
    }
}

struct ChartView_Previews: PreviewProvider {
    static var previews: some View {
        ChartView(coin: dev.coin)
    }
}

extension ChartView {
    private var chartView: some View {
        GeometryReader { geometry in
            Path { path in
                for index in data.indices {
                    let xPosition = geometry.size.width / CGFloat(data.count) * CGFloat(index + 1)
                    let yAxis = maxY - minY
                    let yPosition = (1 - CGFloat((data[index] - minY) / yAxis)) * geometry.size.height
                    if index == 0 {
                        path.move(to: CGPoint(x: xPosition, y: yPosition))
                    }
                    path.addLine(to: CGPoint(x: xPosition, y: yPosition))
                }
            }
            .trim(from: 0, to: percente)
            .stroke(lineColor, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
            .shadow(color: lineColor, radius: 5, x: 0.0, y: 5)
        }
    }
    
    private var lineChartGraphic: some View {
        VStack {
            Divider()
            Spacer()
            Divider()
            Spacer()
            Divider()
            Spacer()
        }
    }
    
    private var chartDetail: some View {
        VStack {
            Text(maxY.formattedWithAbbreviations())
            Spacer()
            let price = (maxY + minY) / 2
            Text(price.formattedWithAbbreviations())
            Spacer()
            Text(minY.formattedWithAbbreviations())
            Spacer()
        }
    }
}
