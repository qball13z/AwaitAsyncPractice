import UIKit

public protocol DataFetchable {
    func loadUsers(numberOfUsersToFetch: Int) async throws -> [Person]
}

class PeopleViewModel {
    private var peopleService: DataFetchable
    var imageLoader: ImageCacheServiceProtocol
    var reloadCollectionView: (() -> Void)?
    var people = [Person]()
    var personCellViewModels = [PersonCellViewModel]()
    
    
    init(peopleService: DataFetchable = APIManager(), imageLoader: ImageCacheServiceProtocol = ImageCacheService()) {
        self.peopleService = peopleService
        self.imageLoader = imageLoader
    }
    
    func getPeople() async throws {
        do {
            people = try await peopleService.loadUsers(numberOfUsersToFetch: 200)
            await fetchData(people: people)
        } catch {
            // TODO: Throw an error to handle or show alert
        }
    }
    
    func fetchData(people: [Person]) async {
        self.people = people
        var personViewModels = [PersonCellViewModel]()
        for person in people {
            await personViewModels.append(createCellModel(person: person))
        }
        personCellViewModels = personViewModels
    }
    
    func createCellModel(person: Person) async -> PersonCellViewModel {
        let fullName = "\(person.name.title) \(person.name.first) \(person.name.last)"
        let email = person.email
        let imageURL = person.picture.thumbnail
        
        let image = await fetchImage(imageURL: imageURL)
        
        return PersonCellViewModel(fullName: fullName, email: email, image: image)
    }
    
    func getCellViewModel(at indexPath: IndexPath) -> PersonCellViewModel {
        personCellViewModels[indexPath.row]
    }
    
    private func loadImage(at source: URLRequest) async -> UIImage {
        guard !Task.isCancelled else { return UIImage() }
        
        do {
            let avatarImage = try await imageLoader.fetch(source)
            return avatarImage
        } catch {
            print(error)
            return UIImage()
        }
    }
    
    private func fetchImage(imageURL: String) async -> UIImage {
        let imageTask = Task<UIImage, Error> {
            let currentImage: UIImage = await loadImage(at: URLRequest(url: URL(string: imageURL)!))
            return currentImage
        }
        
        let result = await imageTask.result
        
        do {
            let image = try result.get()
            return image
        } catch {
            print(error)
        }
        
        return UIImage()
    }
}
