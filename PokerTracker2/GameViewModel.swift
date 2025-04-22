import Foundation

class GameViewModel: ObservableObject {
    @Published var games: [Game] = [] {
        didSet {
            saveGames()
        }
    }

    private let gamesKey = "SavedPokerGames"

    init() {
        loadGames()
    }

    func addGame(gameType: String, date: Date, currency: String, players: [Player]) {
        let newGame = Game(id: UUID(), date: date, gameType: gameType, currency: currency, players: players)
        games.append(newGame)
    }


    func addPlayer(to gameID: UUID, player: Player) {
        guard let index = games.firstIndex(where: { $0.id == gameID }) else { return }
        games[index].players.append(player)
    }

    func createPlayer(name: String, buyIn: Double, cashOut: Double, finalPosition: Int? = nil) -> Player {
        return Player(id: UUID(), name: name, buyIn: buyIn, cashOut: cashOut, finalPosition: finalPosition)
    }

    func totalProfitLoss(for playerName: String) -> Double {
        games.flatMap { $0.players }
            .filter { $0.name == playerName }
            .reduce(0.0) { $0 + ($1.cashOut - $1.buyIn) }
    }

    func leaderboard() -> [String: Double] {
        var playerProfits: [String: Double] = [:]
        for game in games {
            for player in game.players {
                playerProfits[player.name, default: 0] += player.cashOut - player.buyIn
            }
        }
        return playerProfits.sorted { $0.value > $1.value }.reduce(into: [:]) { result, item in
            result[item.key] = item.value
        }
    }

    // MARK: - Persistence

    private func saveGames() {
        if let encoded = try? JSONEncoder().encode(games) {
            UserDefaults.standard.set(encoded, forKey: gamesKey)
        }
    }

    private func loadGames() {
        if let savedData = UserDefaults.standard.data(forKey: gamesKey),
           let decoded = try? JSONDecoder().decode([Game].self, from: savedData) {
            games = decoded
        }
    }
}
