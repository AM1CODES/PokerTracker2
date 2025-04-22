import SwiftUI

struct NewGameView: View {
    @Environment(\.dismiss) var dismiss

    // Game-level inputs
    @State private var gameType: String = "Texas Hold'em"
    @State private var gameDate: Date = Date()
    @State private var selectedCurrency: String = "USD"

    // Player form inputs
    @State private var newPlayerName: String = ""
    @State private var newPlayerBuyIn: String = ""
    @State private var newPlayerCashOut: String = ""
    @State private var newPlayerFinalPosition: String = ""

    // Game-level player list
    @State private var players: [Player] = []

    // Currency list
    let availableCurrencies = ["USD", "INR", "EUR", "GBP", "JPY"]

    // Callback when saved
    var onSave: (Game) -> Void

    var body: some View {
        NavigationView {
            Form {
                // Game Info
                Section(header: Text("Game Info")) {
                    TextField("Game Type", text: $gameType)
                    DatePicker("Date", selection: $gameDate, displayedComponents: .date)
                    Picker("Currency", selection: $selectedCurrency) {
                        ForEach(availableCurrencies, id: \.self) { currency in
                            Text(currency)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                // Add Player Form
                Section(header: Text("Add Player")) {
                    TextField("Name", text: $newPlayerName)
                    TextField("Buy-in (\(selectedCurrency))", text: $newPlayerBuyIn)
                        .keyboardType(.decimalPad)
                    TextField("Cash-out (\(selectedCurrency))", text: $newPlayerCashOut)
                        .keyboardType(.decimalPad)
                    TextField("Final Position (e.g. 1, 2, 3)", text: $newPlayerFinalPosition)
                        .keyboardType(.numberPad)

                    Button(action: addPlayer) {
                        Label("Add Player", systemImage: "plus.circle.fill")
                    }
                    .disabled(!canAddPlayer())
                }

                // Player List Preview
                Section(header: Text("Players")) {
                    if players.isEmpty {
                        Text("No players added yet.")
                            .foregroundColor(.gray)
                    } else {
                        ForEach(players) { player in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(player.name)
                                    .font(.headline)
                                Text("Buy-in: \(selectedCurrency) \(player.buyIn, specifier: "%.2f") | Cash-out: \(selectedCurrency) \(player.cashOut, specifier: "%.2f")")
                                    .font(.subheadline)
                                Text("Final Position: \(player.finalPosition.map { "\($0)" } ?? "N/A")")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .onDelete(perform: deletePlayer)
                    }
                }
            }
            .navigationTitle("New Game")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let newGame = Game(
                            id: UUID(),
                            date: gameDate,
                            gameType: gameType,
                            currency: selectedCurrency,
                            players: players
                        )
                        onSave(newGame)
                        dismiss()
                    }
                    .disabled(players.isEmpty)
                }
            }
        }
    }

    // MARK: - Helper Methods

    private func canAddPlayer() -> Bool {
        !newPlayerName.isEmpty &&
        Double(newPlayerBuyIn) != nil &&
        Double(newPlayerCashOut) != nil
    }

    private func addPlayer() {
        guard let buyIn = Double(newPlayerBuyIn),
              let cashOut = Double(newPlayerCashOut) else {
            return
        }

        let position = Int(newPlayerFinalPosition)

        let player = Player(
            id: UUID(),
            name: newPlayerName,
            buyIn: buyIn,
            cashOut: cashOut,
            finalPosition: position
        )

        players.append(player)

        // Reset input fields
        newPlayerName = ""
        newPlayerBuyIn = ""
        newPlayerCashOut = ""
        newPlayerFinalPosition = ""
    }

    private func deletePlayer(at offsets: IndexSet) {
        players.remove(atOffsets: offsets)
    }
}
