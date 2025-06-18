import SwiftUI

struct AIInsightsView: View {
    @ObservedObject var viewModel: TripViewModel
    @State private var insights: String = "Loading AI insights..."
    
    var body: some View {
        ScrollView {
            Text(insights)
                .padding()
        }
        .navigationTitle("AI Spending Insights")
        .onAppear {
            let summary = generateExpenseSummary()
            // Simulate AI response for now
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                insights = generateEncouragingMessage(basedOn: summary)
            }
        }
    }
    
    func generateExpenseSummary() -> String {
        var summary = "Participants and their balances:\n"
        
        let balances = viewModel.calculateBalances()
        for (participant, balance) in balances {
            summary += "\(participant.name): balance $\(String(format: "%.2f", balance))\n"
        }
        
        summary += "\nCategory spending:\n"
        for (category, spent) in viewModel.spentPerCategory() {
            let budget = viewModel.trip.budgetByCategory[category] ?? 0
            summary += "\(category): spent $\(String(format: "%.2f", spent)) of budget $\(String(format: "%.2f", budget))\n"
        }
        return summary
    }
    
    func generateEncouragingMessage(basedOn summary: String) -> String {
        // basic example encouraging message based on budget usage
        let budgets = viewModel.budgetStatus()
        var message = "Here's how you're doing:\n\n"
        var allGood = true
        
        for (category, status) in budgets {
            if status.isOver {
                message += "⚠️ You're over budget in \(category) by $\(String(format: "%.2f", status.spent - status.budget)). Try to cut back a bit!\n"
                allGood = false
            } else {
                message += "✅ Great job staying within your \(category) budget.\n"
            }
        }
        
        if allGood {
            message += "\n🎉 Awesome! You're on track with all your budgets. Keep up the great work and enjoy your trip!"
        }
        
        return message
    }
}

