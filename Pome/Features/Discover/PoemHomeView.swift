import SwiftUI
import UIKit

struct PoemHomeView: View {
    @State private var navigationController: UINavigationController?


    let title: String

    init(title: String = "诗歌") {
        self.title = title
    }

    var body: some View {
        ZStack {
            // 统一背景色
            AppTheme.backgroundColor.ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: AppTheme.spacing_lg) {
                        Spacer().frame(height: AppTheme.spacing_lg)

                        LearningModuleSection(
                            onSelect: pushLearningModule
                        )

                        Spacer().frame(height: AppTheme.spacing_lg)
                    }
                }
            }
        }
        .background(
            NavigationControllerReader { navigationController in
                self.navigationController = navigationController
            }
        )
    }

    private func pushLearningModule(_ module: LearningModule) {
        guard let navigationController = navigationController ?? findNavigationController() else {
            return
        }

        let detailView = LearningModuleDetailView(module: module)
        let hostingController = UIHostingController(rootView: detailView)
        hostingController.title = module.title
        hostingController.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(hostingController, animated: true)
    }

    private func findNavigationController() -> UINavigationController? {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return nil
        }

        return scene.windows.first(where: { $0.isKeyWindow })?.rootViewController?.nearestNavigationController
    }
}

private extension UIViewController {
    var nearestNavigationController: UINavigationController? {
        if let navigationController = self as? UINavigationController {
            return navigationController
        }

        if let navigationController = navigationController {
            return navigationController
        }

        for child in children {
            if let navigationController = child.nearestNavigationController {
                return navigationController
            }
        }

        return presentedViewController?.nearestNavigationController
    }
}

// 搜索视图
struct SearchView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var poemService: PoemService
    @State private var searchText = ""
    let onSelect: (Poem) -> Void

    var filteredPoems: [Poem] {
        let keyword = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if keyword.isEmpty {
            return []
        }

        let titleResults = poemService.getPoemsByTitle(keyword: keyword)
        let authorResults = poemService.getPoemsByAuthor(author: keyword)
        let contentResults = poemService.getPoemsByContent(keyword: keyword)
        var seenIDs = Set<String>()

        return (titleResults + authorResults + contentResults)
            .filter { poem in
                seenIDs.insert(poem.id).inserted
            }
            .prefix(20)
            .map { $0 }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 搜索框
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(AppTheme.textSecondary)

                    TextField("输入关键词搜索", text: $searchText)
                        .foregroundColor(AppTheme.textPrimary)
                }
                .padding(AppTheme.spacing_md)
                .background(AppTheme.backgroundColor)
                .cornerRadius(AppTheme.cornerRadius_md)
                .padding(AppTheme.spacing_lg)

                if searchText.isEmpty {
                    VStack(spacing: AppTheme.spacing_md) {
                        Spacer()
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 40))
                            .foregroundColor(AppTheme.textSecondary)
                        Text("请输入作者、标题或内容关键词")
                            .foregroundColor(AppTheme.textSecondary)
                        Spacer()
                    }
                } else if filteredPoems.isEmpty {
                    VStack(spacing: AppTheme.spacing_md) {
                        Spacer()
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.system(size: 40))
                            .foregroundColor(AppTheme.textSecondary)
                        Text("没有找到匹配的诗词")
                            .foregroundColor(AppTheme.textSecondary)
                        Spacer()
                    }
                } else {
                    List(filteredPoems, id: \.id) { poem in
                        Button(action: {
                            onSelect(poem)
                        }) {
                            VStack(alignment: .leading, spacing: AppTheme.spacing_sm) {
                                Text(poem.title)
                                    .font(.headline)
                                    .foregroundColor(AppTheme.textPrimary)
                                Text("[\(poem.dynasty)] \(poem.writer)")
                                    .font(.subheadline)
                                    .foregroundColor(AppTheme.textSecondary)
                            }
                            .padding(.vertical, AppTheme.spacing_sm)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .background(AppTheme.backgroundColor)
            .navigationBarTitle("搜索诗词", displayMode: .inline)
            .navigationBarItems(trailing: Button("关闭") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct PoemHomeView_Previews: PreviewProvider {
    static var previews: some View {
        PoemHomeView()
    }
} 
