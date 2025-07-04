//import UIKit
import SwiftUI

class PoemViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设置导航栏
        navigationItem.title = "诗歌"
        
        // 左侧按钮
        let searchButton = UIBarButtonItem(image: UIImage(systemName: "magnifyingglass"), 
                                         style: .plain,
                                         target: self,
                                         action: #selector(searchPoems))
        navigationItem.leftBarButtonItem = searchButton
        
        // 设置随机背景颜色
        view.backgroundColor = UIColor(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1),
            alpha: 1.0
        )
        
        // 右侧按钮
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, 
                                      target: self, 
                                      action: #selector(addNewPoem))
        navigationItem.rightBarButtonItem = addButton
    }
    
    @objc private func searchPoems() {
        // 处理搜索诗歌的逻辑
    }
    
    @objc private func addNewPoem() {
        // 处理添加新诗歌的逻辑
    }
} 
