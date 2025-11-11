import UIKit
import SwiftUI

class PoemViewController: UIViewController {

    private var homeView: UIHostingController<HomeView>?

    override func viewDidLoad() {
        super.viewDidLoad()

        // 设置导航栏
        navigationItem.title = "首页"

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
