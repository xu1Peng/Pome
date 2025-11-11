import SwiftUI

struct PoemHomeView: View {
    @StateObject private var poemService = PoemService()
    @State private var selectedPoem: Poem?
    @State private var searchText = ""
    @State private var isShowingSearch = false
    @State private var isShowingErrorAlert = false
    let title: String

    init(title: String = "诗歌") {
        self.title = title
    }

    var body: some View {
        ZStack {
            // 统一背景色
            AppTheme.backgroundColor.ignoresSafeArea()

            VStack(spacing: 0) {
                if poemService.isLoading {
                    // 加载中状态
                    LoadingView()
                } else if let error = poemService.errorMessage {
                    // 错误状态
                    ErrorView(errorMessage: error, retryAction: {
                        poemService.forceRefresh()
                    })
                } else if poemService.poems.isEmpty {
                    // 没有数据状态
                    EmptyDataView(loadAction: {
                        poemService.fetchPoemsFromNetwork()
                    })
                } else {
                    // 显示诗词内容
                    ScrollView {
                        VStack(spacing: AppTheme.spacing_lg) {
                            // 随机展示一首诗
                            PoemCardView(poem: selectedPoem ?? poemService.getRandomPoem())
                                .padding(.horizontal, AppTheme.spacing_lg)

                            // 操作按钮区域
                            HStack(spacing: AppTheme.spacing_md) {
                                // 换一首按钮
                                Button(action: {
                                    withAnimation {
                                        selectedPoem = poemService.getRandomPoem()
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: "arrow.triangle.2.circlepath")
                                        Text("换一首")
                                    }
                                    .frame(maxWidth: .infinity)
                                    .foregroundColor(.white)
                                    .padding(AppTheme.spacing_md)
                                    .background(AppTheme.primaryColor)
                                    .cornerRadius(AppTheme.cornerRadius_md)
                                }

                                // 刷新数据按钮
                                Button(action: {
                                    poemService.forceRefresh()
                                }) {
                                    HStack {
                                        Image(systemName: "arrow.clockwise")
                                        Text("刷新")
                                    }
                                    .frame(maxWidth: .infinity)
                                    .foregroundColor(.white)
                                    .padding(AppTheme.spacing_md)
                                    .background(AppTheme.secondaryColor)
                                    .cornerRadius(AppTheme.cornerRadius_md)
                                }
                            }
                            .padding(.horizontal, AppTheme.spacing_lg)

                            // 热门诗人
                            CategorySection(
                                title: "热门诗人",
                                items: ["李白", "杜甫", "白居易", "王维", "苏轼"],
                                onSelect: { author in
                                    let poems = poemService.getPoemsByAuthor(author: author)
                                    selectedPoem = poems.first ?? poemService.getRandomPoem()
                                }
                            )

                            // 朝代分类
                            CategorySection(
                                title: "按朝代分类",
                                items: ["唐代", "宋代", "元代", "明代", "清代"],
                                onSelect: { dynasty in
                                    let poems = poemService.getPoemsByDynasty(dynasty: dynasty)
                                    selectedPoem = poems.first ?? poemService.getRandomPoem()
                                }
                            )

                            Spacer().frame(height: AppTheme.spacing_lg)
                        }
                    }
                }
            }
            .alert(isPresented: $isShowingErrorAlert) {
                Alert(
                    title: Text("错误"),
                    message: Text(poemService.errorMessage ?? "未知错误"),
                    primaryButton: .default(Text("重试"), action: {
                        poemService.forceRefresh()
                    }),
                    secondaryButton: .cancel(Text("取消"))
                )
            }
        }
        .onAppear {
            if selectedPoem == nil && !poemService.poems.isEmpty {
                selectedPoem = poemService.getRandomPoem()
            }
            setupNotifications()
        }
        .onDisappear {
            NotificationCenter.default.removeObserver(self)
        }
        .sheet(isPresented: $isShowingSearch) {
            SearchView(poemService: poemService) { poem in
                selectedPoem = poem
                isShowingSearch = false
            }
        }
        .onChange(of: poemService.errorMessage) { newValue in
            isShowingErrorAlert = newValue != nil
        }
    }
    
    // 设置通知监听器来响应UIKit的操作
    private func setupNotifications() {
        // 监听搜索通知
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("ShowPoemSearch"),
            object: nil,
            queue: .main
        ) { _ in
            isShowingSearch = true
        }
        
        // 监听刷新诗词通知
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("RefreshPoem"),
            object: nil,
            queue: .main
        ) { _ in
            selectedPoem = poemService.getRandomPoem()
        }
        
        // 监听加载本地诗词通知
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("LoadLocalPoems"),
            object: nil,
            queue: .main
        ) { _ in
            poemService.loadLocalPoems()
        }
    }
}

// 加载视图
struct LoadingView: View {
    var body: some View {
        VStack(spacing: AppTheme.spacing_lg) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .tint(AppTheme.primaryColor)

            Text("正在加载诗词...")
                .font(.headline)
                .foregroundColor(AppTheme.textPrimary)

            Text("正在从网络获取最新诗词数据")
                .font(.subheadline)
                .foregroundColor(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.backgroundColor)
    }
}

// 错误视图
struct ErrorView: View {
    let errorMessage: String
    let retryAction: () -> Void

    var body: some View {
        VStack(spacing: AppTheme.spacing_lg) {
            Image(systemName: "exclamationmark.triangle")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .foregroundColor(AppTheme.accentColor)

            Text("加载失败")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(AppTheme.textPrimary)

            Text(errorMessage)
                .font(.body)
                .foregroundColor(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            VStack(spacing: AppTheme.spacing_md) {
                Button(action: retryAction) {
                    Text("重试")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(AppTheme.spacing_md)
                        .background(AppTheme.primaryColor)
                        .cornerRadius(AppTheme.cornerRadius_md)
                }

                Button(action: {
                    NotificationCenter.default.post(name: NSNotification.Name("LoadLocalPoems"), object: nil)
                }) {
                    Text("使用离线数据")
                        .fontWeight(.medium)
                        .foregroundColor(AppTheme.primaryColor)
                        .frame(maxWidth: .infinity)
                        .padding(AppTheme.spacing_md)
                        .background(AppTheme.backgroundColor)
                        .cornerRadius(AppTheme.cornerRadius_md)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.cornerRadius_md)
                                .stroke(AppTheme.primaryColor, lineWidth: 1)
                        )
                }
            }
        }
        .padding(AppTheme.spacing_lg)
        .background(AppTheme.cardBackground)
        .cornerRadius(AppTheme.cornerRadius_lg)
        .shadow(color: AppTheme.shadowColor, radius: AppTheme.shadowRadius, x: 0, y: 2)
        .padding(AppTheme.spacing_lg)
    }
}

// 空数据视图
struct EmptyDataView: View {
    let loadAction: () -> Void

    var body: some View {
        VStack(spacing: AppTheme.spacing_lg) {
            Image(systemName: "doc.text")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .foregroundColor(AppTheme.textSecondary)

            Text("还没有诗词数据")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(AppTheme.textPrimary)

            Text("点击下方按钮获取诗词数据")
                .font(.subheadline)
                .foregroundColor(AppTheme.textSecondary)

            Button(action: loadAction) {
                Text("获取诗词")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(AppTheme.spacing_md)
                    .background(AppTheme.primaryColor)
                    .cornerRadius(AppTheme.cornerRadius_md)
            }
        }
        .padding(AppTheme.spacing_lg)
        .background(AppTheme.cardBackground)
        .cornerRadius(AppTheme.cornerRadius_lg)
        .shadow(color: AppTheme.shadowColor, radius: AppTheme.shadowRadius, x: 0, y: 2)
        .padding(AppTheme.spacing_lg)
    }
}

// 诗词卡片视图
struct PoemCardView: View {
    let poem: Poem

    var body: some View {
        NavigationLink(destination: PoemView(poem: poem)) {
            VStack(alignment: .center, spacing: AppTheme.spacing_md) {
                Text(poem.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(AppTheme.textPrimary)

                HStack(spacing: AppTheme.spacing_sm) {
                    Text("[\(poem.dynasty)]")
                        .font(.subheadline)
                    Text(poem.writer)
                        .font(.subheadline)
                }
                .foregroundColor(AppTheme.textSecondary)

                Divider()
                    .padding(.vertical, AppTheme.spacing_sm)

                let firstTwoLines = poem.content.split(separator: "\n").prefix(2)
                ForEach(firstTwoLines.indices, id: \.self) { index in
                    Text(String(firstTwoLines[index]))
                        .font(.body)
                        .foregroundColor(AppTheme.textPrimary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }

                if poem.content.split(separator: "\n").count > 2 {
                    Text("...")
                        .font(.body)
                        .foregroundColor(AppTheme.textSecondary)
                }
            }
            .padding(AppTheme.spacing_lg)
            .frame(maxWidth: .infinity)
            .background(AppTheme.cardBackground)
            .cornerRadius(AppTheme.cornerRadius_lg)
            .shadow(color: AppTheme.shadowColor, radius: AppTheme.shadowRadius, x: 0, y: 2)
        }
    }
}

// 分类区域组件
struct CategorySection: View {
    let title: String
    let items: [String]
    let onSelect: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacing_md) {
            Text(title)
                .font(.headline)
                .foregroundColor(AppTheme.textPrimary)
                .padding(.horizontal, AppTheme.spacing_lg)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppTheme.spacing_md) {
                    ForEach(items, id: \.self) { item in
                        Button(action: {
                            onSelect(item)
                        }) {
                            Text(item)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .padding(.vertical, AppTheme.spacing_sm)
                                .padding(.horizontal, AppTheme.spacing_md)
                                .background(AppTheme.primaryColor)
                                .cornerRadius(AppTheme.cornerRadius_md)
                        }
                    }
                }
                .padding(.horizontal, AppTheme.spacing_lg)
            }
        }
    }
}

// 搜索视图
struct SearchView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var poemService: PoemService
    @State private var searchText = ""
    let onSelect: (Poem) -> Void

    var filteredPoems: [Poem] {
        if searchText.isEmpty {
            return []
        } else {
            let titleResults = poemService.getPoemsByTitle(keyword: searchText)
            let contentResults = poemService.getPoemsByContent(keyword: searchText)
            let authorResults = poemService.getPoemsByAuthor(author: searchText)

            var combinedResults = Array(Set(titleResults + contentResults + authorResults))
            if combinedResults.count > 20 {
                combinedResults = Array(combinedResults.prefix(20))
            }
            return combinedResults
        }
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