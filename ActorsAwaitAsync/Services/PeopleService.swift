//protocol PeopleServiceProtocol {
//    func loadUsers(numberOfUsersToFetch: Int) async throws -> [Person]
//}
//
//class PeopleService: PeopleServiceProtocol {
//    private func loadUsers() {
//        Task {
////            showSpinner(onView: self.view)
//            do {
//                let users = try await dataFetchable.loadUsers(numberOfUsersToFetch: 1000)
////                updateCollectionView(users)
//            } catch {
//                // log error
////                logger.debug("Error loading users. \(error.localizedDescription)")
////                updateCollectionView([])
//            }
////            removeSpinner()
//        }
//    }
//}
