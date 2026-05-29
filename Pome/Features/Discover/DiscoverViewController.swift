import UIKit
import SwiftUI

class DiscoverViewController: UIViewController {
    
    private var poemHomeView: UIHostingController<PoemHomeView>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设置导航栏
        navigationItem.title = "发现"

        // 嵌入 SwiftUI 视图
        embedPoemHomeView()
    }
    
    private func embedPoemHomeView() {
        // 创建 SwiftUI 视图
        let poemHomeView = PoemHomeView(title: "发现")
        let hostingController = UIHostingController(rootView: poemHomeView)
        
        // 保存引用
        self.poemHomeView = hostingController
        
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
