import UIKit

class ImageViewController: UIViewController {
    
    // MARK: - Properties
    private let demoImages: [(String, String)] = [
        ("风景1", "sunset.fill"),
        ("风景2", "mountain.2.fill"),
        ("风景3", "cloud.sun.fill"),
        ("动物1", "bird.fill"),
        ("动物2", "tortoise.fill"),
        ("植物1", "leaf.fill"),
        ("植物2", "tree.fill"),
        ("建筑1", "building.columns.fill"),
        ("建筑2", "building.2.fill"),
        ("其他", "sparkles")
    ]
    
    // MARK: - UI Components
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        // 计算每行显示2个图片的大小
        let width = (UIScreen.main.bounds.width - 30) / 2
        layout.itemSize = CGSize(width: width, height: width)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: "ImageCell")
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设置导航栏
        navigationItem.title = "图片"
        
        // 左侧按钮
        let filterButton = UIBarButtonItem(image: UIImage(systemName: "line.3.horizontal.decrease.circle"),
                                         style: .plain,
                                         target: self,
                                         action: #selector(showFilters))
        navigationItem.leftBarButtonItem = filterButton
        
        // 右侧按钮组
        let cameraButton = UIBarButtonItem(image: UIImage(systemName: "camera"),
                                         style: .plain,
                                         target: self,
                                         action: #selector(openCamera))
        
        let selectButton = UIBarButtonItem(title: "选择",
                                         style: .plain,
                                         target: self,
                                         action: #selector(selectImage))
        
        navigationItem.rightBarButtonItems = [selectButton, cameraButton]
        
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // 添加 CollectionView
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // 设置约束
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - Actions
    @objc private func showFilters() {
        // 处理显示筛选器逻辑
    }
    
    @objc private func openCamera() {
        // 处理打开相机逻辑
    }
    
    @objc private func selectImage() {
        // 处理选择图片的逻辑
    }
}

// MARK: - UICollectionViewDelegate & DataSource
extension ImageViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return demoImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCell
        let (title, imageName) = demoImages[indexPath.item]
        cell.configure(title: title, image: UIImage(systemName: imageName))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let (title, imageName) = demoImages[indexPath.item]
        
        // 获取系统图片
        guard let image = UIImage(systemName: imageName) else { return }
        
        // 创建全屏显示控制器
        let fullscreenVC = FullscreenImageViewController(image: image, title: title)
        
        // 创建导航控制器
        let navController = UINavigationController(rootViewController: fullscreenVC)
        navController.modalPresentationStyle = .fullScreen
        
        // 显示全屏图片
        present(navController, animated: true)
    }
}

// MARK: - ImageCell
class ImageCell: UICollectionViewCell {

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemBlue
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .systemGray6
        layer.cornerRadius = 8
        clipsToBounds = true
        
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    func configure(title: String, image: UIImage?) {
        titleLabel.text = title
        imageView.image = image
    }
} 
