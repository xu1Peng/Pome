import UIKit

class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设置全局导航栏样式
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBlue
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().tintColor = .white  // 设置按钮颜色
        
        // 创建视图控制器
        let poemVC = PoemViewController()
        let profileVC = ProfileViewController()
        let imageVC = ImageViewController()
        
        // 为每个视图控制器添加导航控制器
        let poemNav = UINavigationController(rootViewController: poemVC)
        let profileNav = UINavigationController(rootViewController: profileVC) 
        let imageNav = UINavigationController(rootViewController: imageVC)
        
        // 设置标题和系统图标
        poemNav.tabBarItem = UITabBarItem(title: "诗歌", 
                                         image: UIImage(systemName: "text.book.closed"),
                                         selectedImage: UIImage(systemName: "text.book.closed.fill"))
        imageNav.tabBarItem = UITabBarItem(title: "图片", 
                                          image: UIImage(systemName: "photo"),
                                          selectedImage: UIImage(systemName: "photo.fill"))
        profileNav.tabBarItem = UITabBarItem(title: "我的", 
                                            image: UIImage(systemName: "person"),
                                            selectedImage: UIImage(systemName: "person.fill"))
        
        // 设置视图控制器数组 - 调整顺序
        viewControllers = [poemNav, imageNav, profileNav]
        
        // 设置 TabBar 外观
        tabBar.tintColor = .systemBlue
        tabBar.backgroundColor = .systemBackground
    }
} 