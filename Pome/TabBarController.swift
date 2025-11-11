import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // 设置全局导航栏样式
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(red: 0.4, green: 0.5, blue: 0.8, alpha: 1.0)
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().tintColor = .white

        // 创建视图控制器
        let homeVC = PoemViewController()
        let discoverVC = DiscoverViewController()
        let bookshelfVC = BookshelfViewController()
        let profileVC = ProfileViewController()

        // 为每个视图控制器添加导航控制器
        let homeNav = UINavigationController(rootViewController: homeVC)
        let discoverNav = UINavigationController(rootViewController: discoverVC)
        let bookshelfNav = UINavigationController(rootViewController: bookshelfVC)
        let profileNav = UINavigationController(rootViewController: profileVC)

        // 设置标题和系统图标 - 按照截图顺序：首页、发现、书架、我的
        homeNav.tabBarItem = UITabBarItem(title: "首页",
                                         image: UIImage(systemName: "house"),
                                         selectedImage: UIImage(systemName: "house.fill"))
        discoverNav.tabBarItem = UITabBarItem(title: "发现",
                                            image: UIImage(systemName: "sparkles"),
                                            selectedImage: UIImage(systemName: "sparkles"))
        bookshelfNav.tabBarItem = UITabBarItem(title: "收藏",
                                             image: UIImage(systemName: "books.vertical"),
                                             selectedImage: UIImage(systemName: "books.vertical.fill"))
        profileNav.tabBarItem = UITabBarItem(title: "我的",
                                            image: UIImage(systemName: "person"),
                                            selectedImage: UIImage(systemName: "person.fill"))

        // 设置视图控制器数组
        viewControllers = [homeNav, discoverNav, bookshelfNav, profileNav]

        // 设置 TabBar 外观 - 匹配截图样式
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        // 浅灰色背景，接近截图中的颜色
        tabBarAppearance.backgroundColor = UIColor(red: 0.98, green: 0.98, blue: 0.99, alpha: 1.0)
        tabBarAppearance.shadowImage = UIImage()

        // 配置 TabBar 项目的外观
        let itemAppearance = UITabBarItemAppearance()
        itemAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0),
            .font: UIFont.systemFont(ofSize: 10, weight: .regular)
        ]
        itemAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(red: 0.4, green: 0.5, blue: 0.8, alpha: 1.0),
            .font: UIFont.systemFont(ofSize: 10, weight: .regular)
        ]
        tabBarAppearance.stackedLayoutAppearance = itemAppearance

        UITabBar.appearance().standardAppearance = tabBarAppearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        }

        // 设置 TabBar 颜色
        tabBar.tintColor = UIColor(red: 0.4, green: 0.5, blue: 0.8, alpha: 1.0)
        tabBar.unselectedItemTintColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
    }
}
