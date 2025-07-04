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
            // 背景色
            Color(UIColor(
                red: .random(in: 0.6...0.9),
                green: .random(in: 0.6...0.9),
                blue: .random(in: 0.6...0.9),
                alpha: 1.0
            )).ignoresSafeArea()
            
            VStack {
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
                        VStack {
                            // 随机展示一首诗
                            PoemCardView(poem: selectedPoem ?? poemService.getRandomPoem())
                                .padding()
                            
                            // 操作按钮区域
                            HStack {
                                // 刷新按钮
                                Button(action: {
                                    withAnimation {
                                        selectedPoem = poemService.getRandomPoem()
                                    }
                                }) {
                                    Label("换一首", systemImage: "arrow.triangle.2.circlepath")
                                        .foregroundColor(.white)
                                        .padding()
                                        .background(Color.blue)
                                        .cornerRadius(8)
                                }
                                
                                // 强制从网络刷新按钮
                                Button(action: {
                                    poemService.forceRefresh()
                                }) {
                                    Label("刷新数据", systemImage: "arrow.clockwise")
                                        .foregroundColor(.white)
                                        .padding()
                                        .background(Color.green)
                                        .cornerRadius(8)
                                }
                            }
                            .padding(.bottom)
                            
                            // 热门诗人
                            VStack(alignment: .leading) {
                                Text("热门诗人")
                                    .font(.headline)
                                    .padding(.leading)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 15) {
                                        ForEach(["李白", "杜甫", "白居易", "王维", "苏轼"], id: \.self) { author in
                                            Button(action: {
                                                let poems = poemService.getPoemsByAuthor(author: author)
                                                selectedPoem = poems.first ?? poemService.getRandomPoem()
                                            }) {
                                                Text(author)
                                                    .foregroundColor(.white)
                                                    .padding(.vertical, 8)
                                                    .padding(.horizontal, 15)
                                                    .background(Color.blue.opacity(0.7))
                                                    .cornerRadius(20)
                                            }
                                        }
                                    }
                                    .padding()
                                }
                            }
                            
                            // 朝代分类
                            VStack(alignment: .leading) {
                                Text("按朝代分类")
                                    .font(.headline)
                                    .padding(.leading)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 15) {
                                        ForEach(["唐代", "宋代", "元代", "明代", "清代"], id: \.self) { dynasty in
                                            Button(action: {
                                                let poems = poemService.getPoemsByDynasty(dynasty: dynasty)
                                                selectedPoem = poems.first ?? poemService.getRandomPoem()
                                            }) {
                                                Text(dynasty)
                                                    .foregroundColor(.white)
                                                    .padding(.vertical, 8)
                                                    .padding(.horizontal, 15)
                                                    .background(Color.green.opacity(0.7))
                                                    .cornerRadius(20)
                                            }
                                        }
                                    }
                                    .padding()
                                }
                            }
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
            // 如果没有选择诗词，就随机选一首
            if selectedPoem == nil && !poemService.poems.isEmpty {
                selectedPoem = poemService.getRandomPoem()
            }
            
            // 设置通知监听器
            setupNotifications()
        }
        .onDisappear {
            // 移除通知监听器
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
        VStack(spacing: 20) {
            ProgressView("正在加载诗词...")
                .progressViewStyle(CircularProgressViewStyle())
                .foregroundColor(.white)
            
            Text("正在从网络获取最新诗词数据")
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color.black.opacity(0.2))
        .cornerRadius(10)
    }
}

// 错误视图
struct ErrorView: View {
    let errorMessage: String
    let retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .foregroundColor(.red)
            
            Text("加载失败")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.red)
            
            Text(errorMessage)
                .multilineTextAlignment(.center)
                .padding()
            
            Button(action: retryAction) {
                Text("重试")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 160)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            
            Button(action: {
                // 不再尝试直接访问PoemService实例
                // 而是通过传入的重试操作通知外层组件重新加载本地数据
                NotificationCenter.default.post(name: NSNotification.Name("LoadLocalPoems"), object: nil)
            }) {
                Text("使用离线数据")
                    .fontWeight(.medium)
                    .foregroundColor(.blue)
            }
            .padding()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 5)
        .padding()
    }
}

// 空数据视图
struct EmptyDataView: View {
    let loadAction: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .foregroundColor(.gray)
            
            Text("还没有诗词数据")
                .font(.title2)
                .fontWeight(.medium)
            
            Button(action: loadAction) {
                Text("获取诗词")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 160)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 5)
        .padding()
    }
}

// 简洁版诗词卡片视图
struct PoemCardView: View {
    let poem: Poem
    
    var body: some View {
        NavigationLink(destination: PoemView(poem: poem)) {
            VStack(alignment: .center, spacing: 12) {
                Text(poem.title)
                    .font(.title)
                    .fontWeight(.bold)
                
                HStack {
                    Text("[\(poem.dynasty)]")
                        .font(.subheadline)
                    Text(poem.writer)
                        .font(.subheadline)
                }
                .foregroundColor(.secondary)
                
                let firstTwoLines = poem.content.split(separator: "\n").prefix(2)
                ForEach(firstTwoLines.indices, id: \.self) { index in
                    Text(String(firstTwoLines[index]))
                        .font(.body)
                        .multilineTextAlignment(.center)
                }
                
                if poem.content.split(separator: "\n").count > 2 {
                    Text("...")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(radius: 5)
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
            
            // 合并结果并去重
            var combinedResults = Array(Set(titleResults + contentResults + authorResults))
            // 限制结果数量
            if combinedResults.count > 20 {
                combinedResults = Array(combinedResults.prefix(20))
            }
            return combinedResults
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // 搜索框
                TextField("输入关键词搜索", text: $searchText)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal)
                
                if searchText.isEmpty {
                    // 搜索提示
                    VStack {
                        Spacer()
                        Text("请输入作者、标题或内容关键词")
                            .foregroundColor(.gray)
                        Spacer()
                    }
                } else if filteredPoems.isEmpty {
                    // 没有搜索结果
                    VStack {
                        Spacer()
                        Text("没有找到匹配的诗词")
                            .foregroundColor(.gray)
                        Spacer()
                    }
                } else {
                    // 搜索结果列表
                    List(filteredPoems, id: \.id) { poem in
                        Button(action: {
                            onSelect(poem)
                        }) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(poem.title)
                                        .font(.headline)
                                    Text("[\(poem.dynasty)] \(poem.writer)")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                            }
                            .padding(.vertical, 5)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
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