import SwiftUI

struct Task: Identifiable, Codable {
    let id: UUID
    var title: String
    var isCompleted: Bool
    var priority: Int
    
    init(title: String, priority: Int = 1) {
        self.id = UUID()
        self.title = title
        self.isCompleted = false
        self.priority = priority
    }
}

class TaskStore: ObservableObject {
    @Published var tasks: [Task] = []
    
    func addTask(_ title: String, priority: Int = 1) {
        tasks.append(Task(title: title, priority: priority))
    }
    
    func toggleTask(_ task: Task) {
        if let idx = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[idx].isCompleted.toggle()
        }
    }
    
    func deleteTask(at offsets: IndexSet) {
        tasks.remove(atOffsets: offsets)
    }
    
    var completedCount: Int { tasks.filter { $0.isCompleted }.count }
    var pendingCount: Int { tasks.filter { !$0.isCompleted }.count }
}

struct ContentView: View {
    @StateObject private var store = TaskStore()
    @State private var newTaskTitle = ""
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    TextField("New task...", text: $newTaskTitle)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button("Add") {
                        guard !newTaskTitle.isEmpty else { return }
                        store.addTask(newTaskTitle)
                        newTaskTitle = ""
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
                
                HStack {
                    Label("\(store.pendingCount) pending", systemImage: "clock")
                    Spacer()
                    Label("\(store.completedCount) done", systemImage: "checkmark.circle")
                }
                .padding(.horizontal)
                .foregroundColor(.secondary)
                
                List {
                    ForEach(store.tasks) { task in
                        HStack {
                            Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(task.isCompleted ? .green : .gray)
                                .onTapGesture { store.toggleTask(task) }
                            Text(task.title)
                                .strikethrough(task.isCompleted)
                        }
                    }
                    .onDelete(perform: store.deleteTask)
                }
            }
            .navigationTitle("Task Manager")
        }
    }
}
