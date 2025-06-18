import Foundation

class Participant: Identifiable, Hashable, ObservableObject {
    let id: UUID
    var name: String

    init(id: UUID = UUID(), name: String) {
        self.id = id
        self.name = name
    }

    static func == (lhs: Participant, rhs: Participant) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

class Expense: Identifiable, ObservableObject {
    let id: UUID
    var title: String
    var amount: Double
    var paidBy: Participant
    var sharedBy: [Participant]
    var category: String
    var date: Date

    init(id: UUID = UUID(), title: String, amount: Double, paidBy: Participant, sharedBy: [Participant], category: String, date: Date = Date()) {
        self.id = id
        self.title = title
        self.amount = amount
        self.paidBy = paidBy
        self.sharedBy = sharedBy
        self.category = category
        self.date = date
    }
}

class Trip: Identifiable, ObservableObject {
    let id: UUID
    var name: String
    var participants: [Participant]
    @Published var expenses: [Expense]
    var budgetByCategory: [String: Double]

    init(id: UUID = UUID(), name: String, participants: [Participant], expenses: [Expense] = [], budgetByCategory: [String: Double] = [:]) {
        self.id = id
        self.name = name
        self.participants = participants
        self.expenses = expenses
        self.budgetByCategory = budgetByCategory
    }
}

