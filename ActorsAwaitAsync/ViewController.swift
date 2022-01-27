import UIKit

public protocol DataFetchable {
    func loadUsers(userCount: Int) async -> [User]
}

class ViewController: UIViewController {
    var collectionView: UICollectionView?
    var collectionViewItems = [User]()
    let dataFetchable: DataFetchable
    
    init(dataFetchable: DataFetchable) {
        self.dataFetchable = dataFetchable
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavBar()
        configureView()
        loadUsers()
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
        collectionView?.register(CustomCell.self, forCellWithReuseIdentifier: "CustomCell")
        
        view.addSubview(collectionView ?? UICollectionView())
        self.view = view
    }
    
    private func loadUsers() {
        Task {
            let users = await dataFetchable.loadUsers(userCount: 1000)
            updateCollectionView(users)
        }
    }
    
    private func updateCollectionView(_ items: [User]) {
        collectionViewItems = items
        DispatchQueue.main.async { [weak self] in
            self?.collectionView?.reloadData()
        }
    }
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionViewItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCell", for: indexPath) as! CustomCell
        
        let fullName = "\(collectionViewItems[indexPath.row].name.title) \(collectionViewItems[indexPath.row].name.first) \(collectionViewItems[indexPath.row].name.last)"
        
        cell.configure(name: fullName, email: collectionViewItems[indexPath.row].email, imageURL: collectionViewItems[indexPath.row].picture.thumbnail)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("user tapped on \(collectionViewItems[indexPath.row].name.first)")
    }
}

