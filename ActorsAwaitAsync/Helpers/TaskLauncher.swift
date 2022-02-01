import Foundation
import UIKit

protocol TaskLaunchable {
    func imageTask(priority: TaskPriority?, operation: @escaping @Sendable () async throws -> UIImage) -> Task<UIImage, Error>
}

class TaskLauncher: TaskLaunchable {
    func imageTask(priority: TaskPriority?, operation: @escaping @Sendable () async throws -> UIImage) -> Task<UIImage, Error> {
        return Task(priority: priority, operation: operation)
    }
}
