import Foundation
import Combine

class TripViewModel: ObservableObject {
    @Published var trip: Trip
    
    init(tripName: String, participants: [Participant]) {
        self.trip = Trip(name: tripName, participants: participants)
    }
    
    func addExpense(title: String, amount: Double, paidBy: Participant, sharedBy: [Participant], category: String, date: Date = Date()) {
        objectWillChange.send()
        let newExpense = Expense(title: title, amount: amount, paidBy: paidBy, sharedBy: sharedBy, category: category, date: date)
        trip.expenses.append(newExpense)
    }
    
    func setBudget(category: String, amount: Double) {
        objectWillChange.send()
        trip.budgetByCategory[category] = amount
    }
    
    func calculateBalances() -> [Participant: Double] {
        var balances: [Participant: Double] = [:]
        for participant in trip.participants {
            balances[participant] = 0.0
        }
        
        for expense in trip.expenses {
            let splitAmount = expense.amount / Double(expense.sharedBy.count)
            for participant in expense.sharedBy {
                balances[participant]! -= splitAmount
            }
            balances[expense.paidBy]! += expense.amount
        }
        return balances
    }
    
    func spentPerCategory() -> [String: Double] {
        var totals: [String: Double] = [:]
        for expense in trip.expenses {
            totals[expense.category, default: 0.0] += expense.amount
        }
        return totals
    }
    
    func budgetStatus() -> [String: (spent: Double, budget: Double, isOver: Bool)] {
        var result: [String: (spent: Double, budget: Double, isOver: Bool)] = [:]
        for (category, budgetAmount) in trip.budgetByCategory {
            let spentAmount = trip.expenses
                .filter { $0.category.lowercased() == category.lowercased() }
                .reduce(0) { $0 + $1.amount }
            result[category] = (spentAmount, budgetAmount, spentAmount > budgetAmount)
        }
        return result
    }
    
    func calculateSettlements() -> [(from: Participant, to: Participant, amount: Double)] {
        var settlements: [(from: Participant, to: Participant, amount: Double)] = []

        var balances = calculateBalances()
        
        var debtors = balances.filter { $0.value < 0 }
            .map { (participant: $0.key, amount: -$0.value) }
            .sorted { $0.amount > $1.amount }

        var creditors = balances.filter { $0.value > 0 }
            .map { (participant: $0.key, amount: $0.value) }
            .sorted { $0.amount > $1.amount }
        
        var i = 0, j = 0
        while i < debtors.count && j < creditors.count {
            let debtor = debtors[i]
            let creditor = creditors[j]
            let payment = min(debtor.amount, creditor.amount)
            
            settlements.append((from: debtor.participant, to: creditor.participant, amount: payment))
            
            debtors[i].amount -= payment
            creditors[j].amount -= payment
            
            if debtors[i].amount == 0 {
                i += 1
            }
            if creditors[j].amount == 0 {
                j += 1
            }
        }
        
        return settlements
    }
    
    // Delete participant, expense, budget, update budget
    func deleteParticipant(_ participant: Participant) {
        objectWillChange.send()
        trip.participants.removeAll { $0.id == participant.id }
        trip.expenses.removeAll { $0.paidBy == participant || $0.sharedBy.contains(participant) }
    }
    
    func deleteExpense(_ expense: Expense) {
        objectWillChange.send()
        trip.expenses.removeAll { $0.id == expense.id }
    }
    
    func deleteBudget(for category: String) {
        objectWillChange.send()
        trip.budgetByCategory.removeValue(forKey: category)
    }
    
    func updateBudget(for category: String, with newAmount: Double) {
        objectWillChange.send()
        trip.budgetByCategory[category] = newAmount
    }
}

// MARK: - AI Helper Extension

extension TripViewModel {
    /// Generates a participant-wise summary string for AI prompts
    func generateDetailedParticipantSummary() -> String {
        var summary = "Trip Participants Expense Summary:\n\n"
        let balances = calculateBalances()
        let budgets = budgetStatus()
        
        for participant in trip.participants {
            let balance = balances[participant] ?? 0.0
            summary += "\(participant.name):\n"
            summary += "- Balance: $\(String(format: "%.2f", balance))\n"
            
            // List overspending categories for this participant (if any)
            var overBudgetCategories = [String]()
            for (category, status) in budgets {
                if status.isOver {
                    overBudgetCategories.append(category)
                }
            }
            if overBudgetCategories.isEmpty {
                summary += "- Staying within budget. Way to go!\n"
            } else {
                summary += "- Watch out! Over budget in: \(overBudgetCategories.joined(separator: ", "))\n"
            }
            summary += "\n"
        }
        
        return summary
    }
}

