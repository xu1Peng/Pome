import UIKit
import SwiftUI

class DiscoverViewController: UIViewController {
    
    private var poemHomeView: UIHostingController<PoemHomeView>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设置导航栏
        navigationItem.title = "发现"
        
        // 左侧按钮
        let searchButton = UIBarButtonItem(image: UIImage(systemName: "magnifyingglass"), 
                                         style: .plain,
                                         target: self,
                                         action: #selector(searchPoems))
        navigationItem.leftBarButtonItem = searchButton
        
        // 右侧按钮
        let refreshButton = UIBarButtonItem(image: UIImage(systemName: "arrow.triangle.2.circlepath"),
                                      style: .plain,
                                      target: self,
                                      action: #selector(refreshPoem))
        navigationItem.rightBarButtonItem = refreshButton
        
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
    
    @objc private func searchPoems() {
        // 通过 NotificationCenter 通知 SwiftUI 视图显示搜索界面
        NotificationCenter.default.post(name: NSNotification.Name("ShowPoemSearch"), object: nil)
    }
    
    @objc private func refreshPoem() {
        // 通过 NotificationCenter 通知 SwiftUI 视图刷新诗词
        NotificationCenter.default.post(name: NSNotification.Name("RefreshPoem"), object: nil)
    }
}

