import XCTest
@testable import ActorsAwaitAsync

class PeopleViewModelTests: XCTestCase {
    var mockAPIManager = MockApiManager()
    var mockImageCacheService = MockImageCacheService()
    var testObject = PeopleViewModel()
    var testImage = UIImage(named: "picture1.jpg", in: Bundle.init(for: ImageCacheServiceTests.self), with: nil)
    var testImageUrl = Bundle.init(for: ImageCacheServiceTests.self).url(forResource: "picture1", withExtension: "jpg")
    var testBadImageUrl = URL(string: "http://badimageurl.com")
    
    var testPerson1 = Person(gender: "male", name: NameInfo(title: "Sir", first: "Quintin", last: "Rodriguez"), location: Location(street: Street(number: 12, name: "East Village"), city: "New York", state: "NY", country: "USA", coordinates: Coordinates(latitude: "", longitude: ""), timezone: Timezone(offset: "", description: "")), email: "rodriguq@wwt.com", picture: PictureInfo(large: "https://large", medium: "https://medium", thumbnail: "https://thumbnail"))
    var testPerson2 = Person(gender: "female", name: NameInfo(title: "Miss", first: "Mi'Kele", last: "Rodriguez"), location: Location(street: Street(number: 12, name: "East Village"), city: "New York", state: "NY", country: "USA", coordinates: Coordinates(latitude: "", longitude: ""), timezone: Timezone(offset: "", description: "")), email: "wife.com", picture: PictureInfo(large: "http://large", medium: "http://medium", thumbnail: "http://thumbnail"))
    
    override func setUp() async throws {
        try await super.setUp()
        testObject = PeopleViewModel(peopleService: mockAPIManager, imageLoader: mockImageCacheService)
    }
    
    // MARK: getPeople()
    func test_getPeople_givenNumberOfUsers_createsEqualNumberOfPersonObjects() async {
        testObject.userCount = 2
        mockAPIManager.loadUsersReturnPersonValue = [testPerson1, testPerson2]
        
        do {
            try await testObject.getPeople()
            XCTAssertEqual(testObject.people.count, testObject.userCount)
        } catch {
            XCTFail("Should not throw.")
        }
    }
    
    func test_getPeople_givenNumberOfUsers_whenFetchDataFails_throwsError() async {
        testObject.userCount = 2
        mockAPIManager.loadUsersShouldReturnPerson = false
        
        do {
            try await testObject.getPeople()
            XCTFail("Should throw error.")
        } catch {
            XCTAssertEqual(error.localizedDescription, MockApiManager.MockAPIManagerError.loadUserError.localizedDescription)
        }
    }
    
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
    func test_getCellViewModel_givenPersonObjects_returnCellViewModelOfPerson() async {
        await testObject.fetchData(people: [testPerson1, testPerson2])
        let cellViewModel = testObject.getCellViewModel(at: IndexPath(item: 0, section: 0))
        
        XCTAssertEqual(cellViewModel.imageURL, testPerson1.picture.thumbnail)
        XCTAssertEqual(cellViewModel.email, testPerson1.email)
        XCTAssertEqual(cellViewModel.fullName, "\(testPerson1.name.title) \(testPerson1.name.first) \(testPerson1.name.last)")
    }
    
    // MARK: loadImage()
    
    // MARK: fetchImage()
    func test_fetchImage_givenValidImageUrl_returnsImage() async throws {
        await mockImageCacheService.configureMock(fetchReturnImageValue: testImage!)
        let fetchedImage = await testObject.fetchImage(imageURL: testImageUrl!.path)
        
        let image = try XCTUnwrap(fetchedImage)
        XCTAssertEqual(image.size, CGSize(width: 48.0, height: 48.0))
        
    }
    
    func test_fetchImage_givenInvalidImageUrl_returnsEmptyImage() async throws {
        let fetchedImage = await testObject.fetchImage(imageURL: testBadImageUrl!.absoluteString)
        
        let image = try XCTUnwrap(fetchedImage)
        XCTAssertEqual(image.size, CGSize.zero)
    }
    
    func test_fetchImage_givenLoadImageThrows_returnEmptyImage() async throws {
        await mockImageCacheService.configureMock(fetchShouldReturnImage: false)
        let fetchedImage = await testObject.fetchImage(imageURL: testImageUrl!.path)
        
        let image = try XCTUnwrap(fetchedImage)
        XCTAssertEqual(image.size, CGSize.zero)
    }
}
