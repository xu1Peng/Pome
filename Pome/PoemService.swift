import Foundation
import Network

class PoemService: ObservableObject {
    @Published var poems: [Poem] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    // 更换为一个更稳定的免费API接口
    private let poemDataURL = "https://hub.saintic.com/openservice/sentence/all.json"
    // private let poemDataURL = "https://v1.jinrishici.com/all.json"
    // https://v1.jinrishici.com/all.svg
    // https://v1.jinrishici.com/shuqing/libie.png
    // https://v1.jinrishici.com/rensheng.txt

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
    
    // 每日推荐诗词数据（10条精选诗词）
    static let dailyRecommendations: [Poem] = [
        Poem(
            title: "静夜思",
            dynasty: "唐代",
            writer: "李白",
            content: "床前明月光，疑是地上霜。\n举头望明月，低头思故乡。",
            remark: "这是李白的代表作之一，表达了游子思乡的情感。",
            translation: "明亮的月光洒在床前的窗户纸上，好像地上泛起了一层白霜。我禁不住抬起头来，看那天窗外空中的一轮明月，不由得低头沉思，想起远方的家乡。",
            shangxi: "这首诗写的是在寂静的月夜思念家乡的感受。诗的前两句，是写诗人在作客他乡的特定环境中一刹那间所产生的错觉。"
        ),
        Poem(
            title: "春晓",
            dynasty: "唐代",
            writer: "孟浩然",
            content: "春眠不觉晓，处处闻啼鸟。\n夜来风雨声，花落知多少。",
            remark: "这首诗描写了春天早晨的美好景象。",
            translation: "春日里贪睡不知不觉天已破晓，搅乱我酣眠的是那啁啾的小鸟。昨天夜里风声雨声一直不断，那娇美的春花不知被吹落了多少？",
            shangxi: "这首诗是诗人隐居在鹿门山时所作，意境十分优美。诗人抓住春天的早晨刚刚醒来时的一瞬间展开联想，描绘了一幅春天早晨绚丽的图景。"
        ),
        Poem(
            title: "登鹳雀楼",
            dynasty: "唐代",
            writer: "王之涣",
            content: "白日依山尽，黄河入海流。\n欲穷千里目，更上一层楼。",
            remark: "这首诗表达了诗人积极向上的人生态度。",
            translation: "夕阳依傍着西山慢慢地沉没，滔滔黄河朝着东海汹涌奔流。若想把千里的风光景物看够，那就要登上更高的一层城楼。",
            shangxi: "这首诗写诗人在登高望远中表现出来的不凡的胸襟抱负，反映了盛唐时期人们积极向上的进取精神。"
        ),
        Poem(
            title: "相思",
            dynasty: "唐代",
            writer: "王维",
            content: "红豆生南国，春来发几枝。\n愿君多采撷，此物最相思。",
            remark: "这首诗借红豆寄托相思之情。",
            translation: "红豆树生长在南方，春天到了它长出几枝新枝。希望思念的人儿多多采集，小小红豆引人相思。",
            shangxi: "这首诗借咏物而寄相思，一种相思，两处闲愁，通过红豆这一具体可感的事物，表达了深挚的思念之情。"
        ),
        Poem(
            title: "咏鹅",
            dynasty: "唐代",
            writer: "骆宾王",
            content: "鹅，鹅，鹅，曲项向天歌。\n白毛浮绿水，红掌拨清波。",
            remark: "这是骆宾王七岁时所作的咏物诗。",
            translation: "鹅！鹅！鹅！弯着脖子朝天欢叫，洁白的羽毛漂浮在碧绿水面，红红的脚掌拨动着清清水波。",
            shangxi: "这首诗从一个七岁儿童的眼光看鹅游水嬉戏的神态，写得极为生动活泼。"
        ),
        Poem(
            title: "悯农",
            dynasty: "唐代",
            writer: "李绅",
            content: "锄禾日当午，汗滴禾下土。\n谁知盘中餐，粒粒皆辛苦。",
            remark: "这首诗反映了农民劳作的辛苦。",
            translation: "盛夏中午，烈日炎炎，农民还在劳作，汗珠滴入泥土。有谁想到，我们碗中的米饭，粒粒饱含着农民的血汗？",
            shangxi: "这首诗深刻地反映了中国封建社会中农民的生存状态，表达了诗人对农民真挚的同情之心。"
        ),
        Poem(
            title: "江雪",
            dynasty: "唐代",
            writer: "柳宗元",
            content: "千山鸟飞绝，万径人踪灭。\n孤舟蓑笠翁，独钓寒江雪。",
            remark: "这首诗描绘了一幅江乡雪景图。",
            translation: "所有的山，飞鸟全都断绝；所有的路，不见人影踪迹。江上孤舟，渔翁披蓑戴笠；独自垂钓，不怕冰雪侵袭。",
            shangxi: "这首诗通过描写一位渔翁在雪天独钓的情景，表现了诗人在政治革新失败后不屈而又深感孤寂的心境。"
        ),
        Poem(
            title: "赋得古原草送别",
            dynasty: "唐代",
            writer: "白居易",
            content: "离离原上草，一岁一枯荣。\n野火烧不尽，春风吹又生。\n远芳侵古道，晴翠接荒城。\n又送王孙去，萋萋满别情。",
            remark: "这首诗通过对古原上野草的描绘，抒发离别之情。",
            translation: "长长的原上草是多么茂盛，每年秋冬枯黄春来草色浓。无情的野火只能烧掉干叶，春风吹来大地又是绿茸茸。野草野花蔓延着淹没古道，艳阳下草地尽头是你征程。我又一次送走知心的好友，茂密的青草代表我的深情。",
            shangxi: "这首诗通过对古原上野草的描绘，抒发了送别友人时的依依不舍的心情。"
        ),
        Poem(
            title: "望庐山瀑布",
            dynasty: "唐代",
            writer: "李白",
            content: "日照香炉生紫烟，遥看瀑布挂前川。\n飞流直下三千尺，疑是银河落九天。",
            remark: "这首诗描写了庐山瀑布的壮观景象。",
            translation: "香炉峰在阳光的照射下生起紫色烟霞，远远望见瀑布似白色绢绸悬挂在山前。高崖上飞腾直落的瀑布好像有几千尺，让人恍惚以为银河从天上泻落到人间。",
            shangxi: "这首诗极其成功地运用了比喻、夸张和想象，构思奇特，语言生动形象、洗练明快。"
        ),
        Poem(
            title: "早发白帝城",
            dynasty: "唐代",
            writer: "李白",
            content: "朝辞白帝彩云间，千里江陵一日还。\n两岸猿声啼不住，轻舟已过万重山。",
            remark: "这首诗表现了诗人遇赦后愉快的心情。",
            translation: "清晨告别五彩云霞间的白帝城，千里之遥的江陵一天就能到达。两岸猿猴的啼声还在耳边不断，轻快的小船已驶过连绵不绝的万重山峦。",
            shangxi: "这首诗是李白流放夜郎途中遇赦返回时所作，诗人用夸张的手法，写了长江一泻千里的雄伟气势，同时也抒发了诗人经过艰难岁月之后突然遇赦的欢快心情。"
        )
    ]

    // 获取每日推荐诗词
    func getDailyRecommendations() -> [Poem] {
        return Self.dailyRecommendations
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