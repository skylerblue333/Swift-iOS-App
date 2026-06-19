import XCTest
@testable import App

final class TaskStoreTests: XCTestCase {
    func testAddTask() {
        let store = TaskStore()
        store.addTask("Buy groceries")
        XCTAssertEqual(store.tasks.count, 1)
        XCTAssertEqual(store.tasks[0].title, "Buy groceries")
        XCTAssertFalse(store.tasks[0].isCompleted)
    }
    
    func testToggleTask() {
        let store = TaskStore()
        store.addTask("Test task")
        let task = store.tasks[0]
        store.toggleTask(task)
        XCTAssertTrue(store.tasks[0].isCompleted)
    }
    
    func testCounts() {
        let store = TaskStore()
        store.addTask("Task 1")
        store.addTask("Task 2")
        store.toggleTask(store.tasks[0])
        XCTAssertEqual(store.completedCount, 1)
        XCTAssertEqual(store.pendingCount, 1)
    }
}
