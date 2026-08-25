import SwiftUI

public struct SkyTask: Identifiable, Codable, Equatable {
    public let id: UUID
    public var title: String
    public var isCompleted: Bool
    public var priority: Int
    public let createdAt: Date

    public init(id: UUID = UUID(), title: String, priority: Int = 1, isCompleted: Bool = false, createdAt: Date = Date()) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
        self.priority = priority
        self.createdAt = createdAt
    }
}

public enum TaskStoreError: Error, Equatable {
    case emptyTitle
    case titleTooLong
    case invalidPriority
    case capacityReached
}

@MainActor
public final class TaskStore: ObservableObject {
    public static let maxTasks = 1_000
    public static let maxTitleLength = 200

    @Published public private(set) var tasks: [SkyTask]

    public init(tasks: [SkyTask] = []) {
        self.tasks = Array(tasks.prefix(Self.maxTasks))
        sortTasks()
    }

    @discardableResult
    public func addTask(_ rawTitle: String, priority: Int = 1) throws -> SkyTask {
        let title = rawTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else { throw TaskStoreError.emptyTitle }
        guard title.count <= Self.maxTitleLength else { throw TaskStoreError.titleTooLong }
        guard (1...5).contains(priority) else { throw TaskStoreError.invalidPriority }
        guard tasks.count < Self.maxTasks else { throw TaskStoreError.capacityReached }

        let task = SkyTask(title: title, priority: priority)
        tasks.append(task)
        sortTasks()
        return task
    }

    public func toggleTask(id: UUID) {
        guard let index = tasks.firstIndex(where: { $0.id == id }) else { return }
        tasks[index].isCompleted.toggle()
        sortTasks()
    }

    public func deleteTask(id: UUID) {
        tasks.removeAll { $0.id == id }
    }

    public func deleteTask(at offsets: IndexSet) {
        tasks.remove(atOffsets: offsets)
    }

    public var completedCount: Int { tasks.lazy.filter(\.isCompleted).count }
    public var pendingCount: Int { tasks.count - completedCount }

    private func sortTasks() {
        tasks.sort {
            if $0.isCompleted != $1.isCompleted { return !$0.isCompleted }
            if $0.priority != $1.priority { return $0.priority > $1.priority }
            if $0.createdAt != $1.createdAt { return $0.createdAt < $1.createdAt }
            return $0.id.uuidString < $1.id.uuidString
        }
    }
}

public struct ContentView: View {
    @StateObject private var store = TaskStore()
    @State private var newTaskTitle = ""
    @State private var validationMessage: String?

    public init() {}

    public var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    TextField("New task…", text: $newTaskTitle)
                        .textFieldStyle(.roundedBorder)
                        .accessibilityLabel("New task title")
                    Button("Add") { addTask() }
                        .buttonStyle(.borderedProminent)
                        .disabled(newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding()

                if let validationMessage {
                    Text(validationMessage)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .accessibilityLabel("Task validation error")
                }

                HStack {
                    Label("\(store.pendingCount) pending", systemImage: "clock")
                    Spacer()
                    Label("\(store.completedCount) done", systemImage: "checkmark.circle")
                }
                .padding(.horizontal)
                .foregroundStyle(.secondary)

                List {
                    ForEach(store.tasks) { task in
                        HStack {
                            Button {
                                store.toggleTask(id: task.id)
                            } label: {
                                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel(task.isCompleted ? "Mark task pending" : "Mark task complete")

                            VStack(alignment: .leading) {
                                Text(task.title).strikethrough(task.isCompleted)
                                Text("Priority \(task.priority)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .onDelete(perform: store.deleteTask)
                }
            }
            .navigationTitle("Sky Tasks")
        }
    }

    private func addTask() {
        do {
            try store.addTask(newTaskTitle)
            newTaskTitle = ""
            validationMessage = nil
        } catch {
            validationMessage = "Task title must be 1–200 characters and capacity must be available."
        }
    }
}
