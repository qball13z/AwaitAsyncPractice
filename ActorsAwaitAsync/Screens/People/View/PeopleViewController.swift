import UIKit
import OSLog

class PeopleViewController: UIViewController {
    var collectionView: UICollectionView?
    
    lazy var viewModel = {
        PeopleViewModel()
    }()
    
    private let logger = Logger(subsystem: "com.wwt.actorsawaitasync.viewcontroller", category: "ViewController")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showSpinner(onView: self.view)
        configureNavBar()
        configureView()
        Task {
            await prepareViewModel()
        }
    }
    
    private func configureNavBar() {
        title = "Random People"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func configureView() {
        let view = UIView()
        view.backgroundColor = .systemBackground
        
        let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(60))
        let item  = NSCollectionLayoutItem(layoutSize: size)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitem: item, count: 1)
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        section.interGroupSpacing = 10
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        collectionView?.dataSource = self
        collectionView?.delegate = self
        collectionView?.register(PersonCell.self, forCellWithReuseIdentifier: "PersonCell")
        
        view.addSubview(collectionView ?? UICollectionView())
        self.view = view
    }
    
    func prepareViewModel() async {
        do {
            try await initViewModel()
        } catch {
            // TODO: Show error alert
        }
        removeSpinner()
    }
    
    func initViewModel() async throws {
        do {
            try await viewModel.getPeople()
            DispatchQueue.main.async { [weak self] in
                self?.collectionView?.reloadData()
            }
        } catch {
            // TODO: Show error alert
        }
    }
}

extension PeopleViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.personCellViewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PersonCell", for: indexPath) as? PersonCell else { fatalError("PersonCell doesn't exist!")}
        let cellViewModel = viewModel.getCellViewModel(at: indexPath)
        cell.updateCell(name: cellViewModel.fullName, email: cellViewModel.email, image: cellViewModel.image)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // TODO: 
    }
}
