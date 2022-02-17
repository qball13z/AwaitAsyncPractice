import UIKit

class PersonCell: UICollectionViewCell {
    var nameLabel = UILabel()
    var emailLabel = UILabel()
    let avatarImageView = UIImageView()
    var avatarImage = UIImage()
//    var imageLoader = ImageCacheService()
    var imageTask: Task<Void, Never>?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureSubviews()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = ""
        emailLabel.text = ""
        avatarImage = UIImage()
        imageTask?.cancel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateCell(name: String, email: String, image: UIImage) {
        nameLabel.text = name
        emailLabel.text = email
        avatarImageView.image = image
//      imageTask = Task {
//          await loadImage(at: URLRequest(url: URL(string: imageURL)!))
//        }
    }
    
    // TODO: Move this to the ViewController
//    private func loadImage(at source: URLRequest) async {
//        guard !Task.isCancelled else { return }
//
//        do {
//            avatarImage = try await imageLoader.fetch(source)
//            await MainActor.run {
//                avatarImageView.image = avatarImage
//            }
//        } catch {
//            print(error)
//        }
//    }
    
    private func configureSubviews() {
        nameLabel.numberOfLines = 0
        emailLabel.numberOfLines = 1
        
        let textStackView = UIStackView(arrangedSubviews: [nameLabel, emailLabel])
        textStackView.axis = .vertical
        
        let containerStackView = UIStackView(arrangedSubviews: [avatarImageView, textStackView])
        containerStackView.axis = .horizontal
        containerStackView.spacing = 16.0
        contentView.addSubview(containerStackView)
        
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        containerStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            containerStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            
            avatarImageView.widthAnchor.constraint(equalToConstant: 60.0),
            avatarImageView.heightAnchor.constraint(equalToConstant: 60.0),
            avatarImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}
