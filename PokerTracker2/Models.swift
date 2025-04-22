import Foundation

struct Player: Identifiable, Codable {
    let id: UUID
    var name: String
    var buyIn: Double
    var cashOut: Double
    var finalPosition: Int? // Already present? Good!
}


struct Game: Identifiable, Codable {
    let id: UUID
    var date: Date
    var gameType: String
    var currency: String // NEW
    var players: [Player]
    
    var totalBuyIn: Double {
        players.map { $0.buyIn }.reduce(0, +)
    }

    var totalCashOut: Double {
        players.map { $0.cashOut }.reduce(0, +)
    }

    var profitLossPerPlayer: [String: Double] {
        Dictionary(uniqueKeysWithValues: players.map {
            ($0.name, $0.cashOut - $0.buyIn)
        })
    }
}
