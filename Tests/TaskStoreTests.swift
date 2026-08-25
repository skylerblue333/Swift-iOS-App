import XCTest
@testable import App

@MainActor
final class TaskStoreTests: XCTestCase {
    func testAddTaskTrimsAndStores() throws {
        let store = TaskStore()
        let task = try store.addTask("  Buy groceries  ", priority: 3)
        XCTAssertEqual(task.title, "Buy groceries")
        XCTAssertEqual(task.priority, 3)
        XCTAssertFalse(task.isCompleted)
        XCTAssertEqual(store.pendingCount, 1)
    }

    func testRejectsInvalidInputs() {
        let store = TaskStore()
        XCTAssertThrowsError(try store.addTask("   ")) { error in
            XCTAssertEqual(error as? TaskStoreError, .emptyTitle)
        }
        XCTAssertThrowsError(try store.addTask(String(repeating: "a", count: 201))) { error in
            XCTAssertEqual(error as? TaskStoreError, .titleTooLong)
        }
        XCTAssertThrowsError(try store.addTask("Task", priority: 0)) { error in
            XCTAssertEqual(error as? TaskStoreError, .invalidPriority)
        }
    }

    func testToggleMovesCompletedTaskBehindPending() throws {
        let store = TaskStore()
        let high = try store.addTask("High", priority: 5)
        _ = try store.addTask("Low", priority: 1)
        store.toggleTask(id: high.id)
        XCTAssertTrue(store.tasks.last?.isCompleted == true)
        XCTAssertEqual(store.completedCount, 1)
        XCTAssertEqual(store.pendingCount, 1)
    }

    func testPendingTasksSortByPriority() throws {
        let store = TaskStore()
        _ = try store.addTask("Low", priority: 1)
        _ = try store.addTask("High", priority: 5)
        XCTAssertEqual(store.tasks.map(\.title), ["High", "Low"])
    }

    func testDeleteById() throws {
        let store = TaskStore()
        let task = try store.addTask("Remove me")
        store.deleteTask(id: task.id)
        XCTAssertTrue(store.tasks.isEmpty)
    }
}
