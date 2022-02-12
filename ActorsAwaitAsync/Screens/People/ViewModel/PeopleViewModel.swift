import UIKit

public protocol DataFetchable {
    func loadUsers(numberOfUsersToFetch: Int) async throws -> [Person]
}

class PeopleViewModel {
    private var peopleService: DataFetchable
    
    var reloadCollectionView: (() -> Void)?
    var people = [Person]()
    var personCellViewModels = [PersonCellViewModel]()
    
    
    init(peopleService: DataFetchable = APIManager()) {
        self.peopleService = peopleService
    }
    
    func getPeople() async throws {
        do {
            people = try await peopleService.loadUsers(numberOfUsersToFetch: 20)
            fetchData(people: people)
        } catch {
            // TODO: Throw an error to handle or show alert
        }
    }
    
    func fetchData(people: [Person]) {
        self.people = people
        var personViewModels = [PersonCellViewModel]()
        for person in people {
            personViewModels.append(createCellModel(person: person))
        }
        personCellViewModels = personViewModels
    }
    
    func createCellModel(person: Person) -> PersonCellViewModel {
        let fullName = "\(person.name.title) \(person.name.first) \(person.name.last)"
        let email = person.email
        let imageURL = person.picture.thumbnail
        
        return PersonCellViewModel(fullName: fullName, email: email, imageURL: imageURL)
    }
    
    func getCellViewModel(at indexPath: IndexPath) -> PersonCellViewModel {
        personCellViewModels[indexPath.row]
    }
}
