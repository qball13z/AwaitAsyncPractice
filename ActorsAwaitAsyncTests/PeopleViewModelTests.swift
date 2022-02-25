import XCTest
@testable import ActorsAwaitAsync

class PeopleViewModelTests: XCTestCase {
    var mockAPIManager = MockApiManager()
    var mockImageCacheService = MockImageCacheService()
    var testObject = PeopleViewModel()
    
    var testPerson1 = Person(gender: "male", name: NameInfo(title: "Sir", first: "Quintin", last: "Rodriguez"), location: Location(street: Street(number: 12, name: "East Village"), city: "New York", state: "NY", country: "USA", coordinates: Coordinates(latitude: "", longitude: ""), timezone: Timezone(offset: "", description: "")), email: "rodriguq@wwt.com", picture: PictureInfo(large: "", medium: "", thumbnail: ""))
    var testPerson2 = Person(gender: "female", name: NameInfo(title: "Miss", first: "Mi'Kele", last: "Rodriguez"), location: Location(street: Street(number: 12, name: "East Village"), city: "New York", state: "NY", country: "USA", coordinates: Coordinates(latitude: "", longitude: ""), timezone: Timezone(offset: "", description: "")), email: "wife.com", picture: PictureInfo(large: "", medium: "", thumbnail: ""))
    
    override func setUp() async throws {
        try await super.setUp()
        testObject = PeopleViewModel(peopleService: mockAPIManager, imageLoader: mockImageCacheService)
    }
    
    // MARK: getPeople()
    
    // MARK: fetchData()
    func test_fetchData_givenZeroPeople_createNoViewModels() async {
        testObject.userCount = 0
        await testObject.fetchData(people: [])
        XCTAssertEqual(testObject.personCellViewModels.count, testObject.userCount)
    }
    
    func test_fetchData_givenOnePerson_createsOneViewModel() async {
        testObject.userCount = 1
        await testObject.fetchData(people: [testPerson1])
        XCTAssertEqual(testObject.personCellViewModels.count, testObject.userCount)
    }
    
    func test_fetchData_givenMultiplePeople_createsSameNumberofViewModels() async {
        testObject.userCount = 2
        await testObject.fetchData(people: [testPerson1, testPerson2])
        XCTAssertEqual(testObject.personCellViewModels.count, testObject.userCount)
    }
    
    // MARK: createCellModel()
    func test_createCellModel_givenPerson_returnCellViewModelWithPersonValues() async {
        let testPerson1FullName = "\(testPerson1.name.title) \(testPerson1.name.first) \(testPerson1.name.last)"
 
        let viewModel = await testObject.createCellModel(person: testPerson1)
        XCTAssertEqual(testPerson1FullName, viewModel.fullName)
        XCTAssertEqual(testPerson1.email, viewModel.email)
        XCTAssertEqual(testPerson1.picture.thumbnail, viewModel.imageURL)
    }
    
    // MARK: getCellViewModel()
    
    // MARK: loadImage()
    
    // MARK: fetchImage()
    
}
