import UIKit
import SwiftUI

class PoemViewController: UIViewController {

    private var homeView: UIHostingController<HomeView>?

    override func viewDidLoad() {
        super.viewDidLoad()

        // 设置导航栏
        navigationItem.title = "首页"

        // 设置导航控制器代理
        navigationController?.delegate = self

        // 嵌入 SwiftUI 视图
        embedHomeView()
    }

    private func embedHomeView() {
        // 创建 SwiftUI 视图
        let homeView = HomeView()
        let hostingController = UIHostingController(rootView: homeView)

        // 保存引用
        self.homeView = hostingController

        // 嵌入子视图控制器
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false

        // 设置约束以填充整个视图
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        hostingController.didMove(toParent: self)
    }
}

// MARK: - UINavigationControllerDelegate
extension PoemViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        // 判断将要显示的页面是否是根页面
        let isRootVC = (viewController == navigationController.viewControllers.first)
        // 如果不是根页面（即二级页面），则隐藏TabBar
        viewController.hidesBottomBarWhenPushed = !isRootVC
    }
}
