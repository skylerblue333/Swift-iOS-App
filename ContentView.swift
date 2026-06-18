import SwiftUI

struct Task: Identifiable {
    let id = UUID()
    let title: String
    var isCompleted: Bool = false
}

class TaskViewModel: ObservableObject {
    @Published var tasks: [Task] = [
        Task(title: "Design system architecture"),
        Task(title: "Implement backend API"),
        Task(title: "Write unit tests")
    ]
    
    func toggleTask(id: UUID) {
        if let index = tasks.firstIndex(where: { $0.id == id }) {
            tasks[index].isCompleted.toggle()
        }
    }
}

struct ContentView: View {
    @StateObject private var viewModel = TaskViewModel()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.tasks) { task in
                    HStack {
                        Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(task.isCompleted ? .green : .gray)
                            .onTapGesture {
                                viewModel.toggleTask(id: task.id)
                            }
                        Text(task.title)
                            .strikethrough(task.isCompleted)
                    }
                }
            }
            .navigationTitle("Enterprise Tasks")
        }
    }
}
