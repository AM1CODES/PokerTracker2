import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = GameViewModel()
    @State private var showingNewGameSheet = false

    var body: some View {
        NavigationView {
            List(viewModel.games) { game in
                VStack(alignment: .leading, spacing: 6) {
                    Text(game.gameType)
                        .font(.headline)
                    Text("Date: \(formattedDate(game.date))")
                        .font(.subheadline)
                    Text("Currency: \(game.currency)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    ForEach(game.players) { player in
                        HStack {
                            Text(player.name)
                            Spacer()
                            Text("\(game.currency) \(player.cashOut - player.buyIn, specifier: "%.2f")")
                                .foregroundColor((player.cashOut - player.buyIn) >= 0 ? .green : .red)
                        }
                        .font(.subheadline)
                    }

                    Divider()

                    Text("Total Buy-in: \(game.currency) \(game.totalBuyIn, specifier: "%.2f") | Total Cash-out: \(game.currency) \(game.totalCashOut, specifier: "%.2f")")
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 6)
            }
            .navigationTitle("Poker Games")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingNewGameSheet = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingNewGameSheet) {
                NewGameView { newGame in
                    viewModel.games.append(newGame)
                }
            }
        }
    }

    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
