import Foundation
import Network

class PoemService: ObservableObject {
    @Published var poems: [Poem] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    // 更换为一个更稳定的免费API接口
    private let poemDataURL = "https://hub.saintic.com/openservice/sentence/all.json"
    // private let poemDataURL = "https://v1.jinrishici.com/all.json"

    private let localPoemFilename = "localPoems.json"
    private let networkMonitor = NWPathMonitor()
    private var isConnected = true
    private let maxRetries = 3
    
    init() {
        // 设置网络监控
        setupNetworkMonitoring()
        // 初始化时尝试从本地加载
        loadLocalPoems()
    }
    
    deinit {
        networkMonitor.cancel()
    }
    
    // 设置网络监控
    private func setupNetworkMonitoring() {
        networkMonitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
                if self?.isConnected == false {
                    self?.errorMessage = "网络连接不可用，使用本地缓存数据"
                }
            }
        }
        let queue = DispatchQueue(label: "NetworkMonitor")
        networkMonitor.start(queue: queue)
    }
    
    // 从本地存储加载诗词
    func loadLocalPoems() {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            errorMessage = "无法访问文档目录"
            return
        }
        
        let fileURL = documentsDirectory.appendingPathComponent(localPoemFilename)
        
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                let data = try Data(contentsOf: fileURL)
                let decodedPoems = try JSONDecoder().decode([Poem].self, from: data)
                self.poems = decodedPoems
                print("成功从本地加载了 \(decodedPoems.count) 首诗")
            } catch {
                errorMessage = "从本地加载失败: \(error.localizedDescription)"
                print("从本地加载失败: \(error)")
                
                // 如果本地加载失败且网络可用，尝试从网络获取
                if isConnected {
                    fetchPoemsFromNetwork()
                }
            }
        } else {
            // 如果本地没有数据，从网络获取
            if isConnected {
                fetchPoemsFromNetwork()
            } else {
                errorMessage = "没有本地数据且网络不可用"
            }
        }
    }
    
    // 从网络获取诗词
    func fetchPoemsFromNetwork(retryCount: Int = 0) {
        if !isConnected {
            errorMessage = "网络连接不可用"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        guard let url = URL(string: poemDataURL) else {
            isLoading = false
            errorMessage = "无效的URL"
            return
        }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 15 // 设置15秒超时
        // 设置User-Agent（这个API需要User-Agent）
        request.addValue("Pome/1.0 iOS-App", forHTTPHeaderField: "User-Agent")
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                // 处理错误并可能重试
                if let error = error {
                    // 检查是否为超时错误
                    if (error as NSError).code == NSURLErrorTimedOut {
                        self.errorMessage = "请求超时"
                        // 如果未达到最大重试次数，进行重试
                        if retryCount < self.maxRetries {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { // 延迟2秒重试
                                self.fetchPoemsFromNetwork(retryCount: retryCount + 1)
                            }
                            return
                        }
                    } else {
                        self.errorMessage = "网络错误: \(error.localizedDescription)"
                    }
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    self.errorMessage = "无效的服务器响应"
                    return
                }
                
                // 处理HTTP状态码
                switch httpResponse.statusCode {
                case 200:
                    // 成功响应
                    break
                case 400...499:
                    self.errorMessage = "客户端请求错误 (状态码: \(httpResponse.statusCode))"
                    return
                case 500...599:
                    self.errorMessage = "服务器错误 (状态码: \(httpResponse.statusCode))"
                    // 服务器错误可能是暂时的，尝试重试
                    if retryCount < self.maxRetries {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            self.fetchPoemsFromNetwork(retryCount: retryCount + 1)
                        }
                    }
                    return
                default:
                    self.errorMessage = "未知HTTP状态码: \(httpResponse.statusCode)"
                    return
                }
                
                guard let data = data else {
                    self.errorMessage = "没有返回数据"
                    return
                }
                
                do {
                    // 处理API的JSON响应格式
                    let sentenceResponse = try JSONDecoder().decode(SentenceResponse.self, from: data)
                    
                    if sentenceResponse.success {
                        // 创建一个诗词收集数组
                        var collectedPoems: [Poem] = []
                        
                        // 将名句转换为Poem格式
                        let sentenceData = sentenceResponse.data
                        let sentence = sentenceData.sentence
                        let poem = Poem(
                            id: UUID(),
                            title: sentenceData.title ?? "名句",
                            dynasty: sentenceData.dynasty ?? "未知",
                            writer: sentenceData.author,
                            content: sentence,
                            remark: nil,
                            translation: nil,
                            shangxi: nil
                        )
                        collectedPoems.append(poem)
                        
                        // 如果只有一个名句，多次请求获取更多
                        self.fetchMorePoems(collectedPoems: collectedPoems, remaining: 9)
                    } else {
                        self.errorMessage = "API返回错误: \(sentenceResponse.message ?? "未知错误")"
                    }
                } catch let error {
                    self.errorMessage = "数据解析错误: \(error.localizedDescription)"
                    print("数据解析错误: \(error)")
                }
            }
        }
        
        task.resume()
    }
    
    // 递归获取更多诗句
    private func fetchMorePoems(collectedPoems: [Poem], remaining: Int) {
        // 如果已经获取了足够的诗词或不需要更多，就保存并更新
        if remaining <= 0 {
            self.poems = collectedPoems
            self.errorMessage = nil
            print("成功从网络加载了 \(collectedPoems.count) 首诗")
            
            // 保存到本地
            self.savePoems(collectedPoems)
            return
        }
        
        // 继续请求更多诗词
        guard let url = URL(string: poemDataURL) else {
            return
        }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 15
        request.addValue("Pome/1.0 iOS-App", forHTTPHeaderField: "User-Agent")
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if let error = error {
                    print("获取更多诗词时出错: \(error.localizedDescription)")
                    // 发生错误时也保存已有的数据
                    self.poems = collectedPoems
                    self.errorMessage = nil
                    self.savePoems(collectedPoems)
                    return
                }
                
                guard let data = data else {
                    // 没有数据时也保存已有的
                    self.poems = collectedPoems
                    self.errorMessage = nil
                    self.savePoems(collectedPoems)
                    return
                }
                
                do {
                    let sentenceResponse = try JSONDecoder().decode(SentenceResponse.self, from: data)
                    
                    if sentenceResponse.success {
                        let sentenceData = sentenceResponse.data
                        let sentence = sentenceData.sentence
                        let newPoem = Poem(
                            id: UUID(),
                            title: sentenceData.title ?? "名句",
                            dynasty: sentenceData.dynasty ?? "未知",
                            writer: sentenceData.author,
                            content: sentence,
                            remark: nil,
                            translation: nil,
                            shangxi: nil
                        )
                        
                        // 将新诗添加到收集中
                        var updatedCollection = collectedPoems
                        updatedCollection.append(newPoem)
                        
                        // 递归调用获取更多
                        self.fetchMorePoems(collectedPoems: updatedCollection, remaining: remaining - 1)
                    } else {
                        // API返回错误时也保存已有的数据
                        self.poems = collectedPoems
                        self.errorMessage = nil
                        self.savePoems(collectedPoems)
                    }
                } catch {
                    // 解析错误时也保存已有的数据
                    print("解析更多诗词时出错: \(error.localizedDescription)")
                    self.poems = collectedPoems
                    self.errorMessage = nil
                    self.savePoems(collectedPoems)
                }
            }
        }
        
        task.resume()
    }
    
    // 将诗词保存到本地
    private func savePoems(_ poems: [Poem]) {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            errorMessage = "无法访问文档目录"
            return
        }
        
        let fileURL = documentsDirectory.appendingPathComponent(localPoemFilename)
        
        do {
            let data = try JSONEncoder().encode(poems)
            try data.write(to: fileURL)
            print("诗词已保存到本地: \(fileURL.path)")
        } catch {
            errorMessage = "保存到本地失败: \(error.localizedDescription)"
            print("保存到本地失败: \(error)")
        }
    }
    
    // 获取随机诗词
    func getRandomPoem() -> Poem {
        guard !poems.isEmpty else {
            return Poem.example
        }
        return poems.randomElement() ?? Poem.example
    }
    
    // 根据作者筛选诗词
    func getPoemsByAuthor(author: String) -> [Poem] {
        return poems.filter { $0.writer.contains(author) }
    }
    
    // 根据朝代筛选诗词
    func getPoemsByDynasty(dynasty: String) -> [Poem] {
        return poems.filter { $0.dynasty.contains(dynasty) }
    }
    
    // 根据标题关键词筛选诗词
    func getPoemsByTitle(keyword: String) -> [Poem] {
        return poems.filter { $0.title.contains(keyword) }
    }
    
    // 根据内容关键词筛选诗词
    func getPoemsByContent(keyword: String) -> [Poem] {
        return poems.filter { $0.content.contains(keyword) }
    }
    
    // 手动强制刷新
    func forceRefresh() {
        if isConnected {
            fetchPoemsFromNetwork()
        } else {
            errorMessage = "网络连接不可用，无法刷新"
        }
    }
}

// 定义名句API响应的数据结构
struct SentenceResponse: Codable {
    let success: Bool
    let data: SentenceData
    let message: String?
}

// 名句数据结构
struct SentenceData: Codable {
    let author: String
    let sentence: String
    let dynasty: String?
    let title: String?
    let origin: String?
} 