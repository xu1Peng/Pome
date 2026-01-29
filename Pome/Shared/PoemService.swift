import Foundation
import Network

class PoemService: ObservableObject {
    @Published var poems: [Poem] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    // 今日诗词API URL
    private let poemDataURL = "https://v2.jinrishici.com/one.json"
    
    // 用于存储Token的Key
    private let tokenKey = "jinrishici-token"

    private let localPoemFilename = "localPoems.json"
    private let networkMonitor = NWPathMonitor()
    private var isConnected = true
    private let maxRetries = 3
    
    init() {
        // 设置网络监控
        setupNetworkMonitoring()
        // 初始化时尝试从本地加载
        loadLocalPoems()
        // 加载内置的唐诗宋词库
        loadResourcePoems()
    }
    
    deinit {
        networkMonitor.cancel()
    }
    
    // 加载内置的唐诗宋词
    private func loadResourcePoems() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            var newPoems: [Poem] = []
            
            // 解析唐诗
            if let tangData = PoemData.tangShiJSON.data(using: .utf8) {
                struct TangPoem: Codable {
                    let author: String
                    let paragraphs: [String]
                    let title: String
                    let tags: [String]?
                }
                do {
                    let tangPoems = try JSONDecoder().decode([TangPoem].self, from: tangData)
                    let poems = tangPoems.map { p in
                        Poem(
                            id: UUID(),
                            title: p.title,
                            dynasty: "唐代",
                            writer: p.author,
                            content: p.paragraphs.joined(separator: "\n"),
                            remark: nil,
                            translation: nil,
                            shangxi: nil,
                            tags: p.tags
                        )
                    }
                    newPoems.append(contentsOf: poems)
                    print("加载了 \(poems.count) 首唐诗")
                } catch {
                    print("解析唐诗失败: \(error)")
                }
            }
            
            // 解析宋词
            if let songData = PoemData.songCiJSON.data(using: .utf8) {
                struct SongPoem: Codable {
                    let author: String
                    let paragraphs: [String]
                    let rhythmic: String
                    let tags: [String]?
                }
                do {
                    let songPoems = try JSONDecoder().decode([SongPoem].self, from: songData)
                    let poems = songPoems.map { p in
                        Poem(
                            id: UUID(),
                            title: p.rhythmic,
                            dynasty: "宋代",
                            writer: p.author,
                            content: p.paragraphs.joined(separator: "\n"),
                            remark: nil,
                            translation: nil,
                            shangxi: nil,
                            tags: p.tags
                        )
                    }
                    newPoems.append(contentsOf: poems)
                    print("加载了 \(poems.count) 首宋词")
                } catch {
                    print("解析宋词失败: \(error)")
                }
            }
            
            // 解析诗经
            if let shijingData = PoemData.shijingJSON.data(using: .utf8) {
                struct ShijingPoem: Codable {
                    let title: String
                    let chapter: String
                    let section: String
                    let content: [String]
                }
                do {
                    let shijingPoems = try JSONDecoder().decode([ShijingPoem].self, from: shijingData)
                    let poems = shijingPoems.map { p in
                        Poem(
                            id: UUID(),
                            title: p.title,
                            dynasty: "先秦",
                            writer: "诗经",
                            content: p.content.joined(separator: "\n"),
                            remark: "\(p.chapter) · \(p.section)",
                            translation: nil,
                            shangxi: nil
                        )
                    }
                    newPoems.append(contentsOf: poems)
                    print("加载了 \(poems.count) 首诗经")
                } catch {
                    print("解析诗经失败: \(error)")
                }
            }
            
            // 解析楚辞
            if let chuciData = PoemData.chuciJSON.data(using: .utf8) {
                struct ChuciPoem: Codable {
                    let title: String
                    let author: String
                    let content: [String]
                    let section: String
                }
                do {
                    let chuciPoems = try JSONDecoder().decode([ChuciPoem].self, from: chuciData)
                    let poems = chuciPoems.map { p in
                        Poem(
                            id: UUID(),
                            title: p.title,
                            dynasty: "先秦",
                            writer: p.author,
                            content: p.content.joined(separator: "\n"),
                            remark: p.section,
                            translation: nil,
                            shangxi: nil
                        )
                    }
                    newPoems.append(contentsOf: poems)
                    print("加载了 \(poems.count) 首楚辞")
                } catch {
                    print("解析楚辞失败: \(error)")
                }
            }
            

            
            // 解析毛泽东诗词
            if let maoData = PoemData.maoZeDongJSON.data(using: .utf8) {
                struct MaoPoem: Codable {
                    let title: String
                    let paragraphs: [String]
                    let author: String
                    let dynasty: String
                }
                do {
                    let maoPoems = try JSONDecoder().decode([MaoPoem].self, from: maoData)
                    let poems = maoPoems.map { p in
                        Poem(
                            id: UUID(),
                            title: p.title,
                            dynasty: p.dynasty,
                            writer: p.author,
                            content: p.paragraphs.joined(separator: "\n"),
                            remark: nil,
                            translation: nil,
                            shangxi: nil
                        )
                    }
                    newPoems.append(contentsOf: poems)
                    print("加载了 \(poems.count) 首毛泽东诗词")
                } catch {
                    print("解析毛泽东诗词失败: \(error)")
                }
            }
            
            DispatchQueue.main.async {
                guard let self = self else { return }
                // 合并到现有列表（简单的去重）
                let existingTitles = Set(self.poems.map { $0.title + $0.writer })
                let uniqueNewPoems = newPoems.filter { !existingTitles.contains($0.title + $0.writer) }
                
                if !uniqueNewPoems.isEmpty {
                    self.poems.append(contentsOf: uniqueNewPoems)
                    print("合并后共有 \(self.poems.count) 首诗词")
                }
            }
        }
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
                
                // 即使本地加载成功，如果网络可用，也尝试从网络获取最新数据
                if isConnected {
                    fetchPoemsFromNetwork()
                }
            } catch {
                errorMessage = "从本地加载失败: \(error.localizedDescription)"
                print("从本地加载失败: \(error)")
                
                // 尝试从 Bundle 加载预置数据
                loadBundledPoems()
                
                // 如果本地加载失败且网络可用，尝试从网络获取
                if isConnected && poems.isEmpty {
                    fetchPoemsFromNetwork()
                }
            }
        } else {
            // 如果本地没有数据，先尝试从 Bundle 加载预置数据
            loadBundledPoems()
            
            // 如果仍然没有数据且网络可用，从网络获取
            if isConnected && poems.isEmpty {
                fetchPoemsFromNetwork()
            } else if poems.isEmpty {
                errorMessage = "没有本地数据且网络不可用"
            }
        }
    }
    
    // 从 Bundle 加载预置诗词
    private func loadBundledPoems() {
        guard let bundleURL = Bundle.main.url(forResource: "localPoems", withExtension: "json") else {
            print("Bundle 中未找到 localPoems.json")
            return
        }
        
        do {
            let data = try Data(contentsOf: bundleURL)
            let decodedPoems = try JSONDecoder().decode([Poem].self, from: data)
            self.poems = decodedPoems
            print("成功从 Bundle 加载了 \(decodedPoems.count) 首诗")
            
            // 可选：将预置数据保存到文档目录，以便后续使用
            // savePoemsToLocal() 
        } catch {
            print("从 Bundle 加载失败: \(error)")
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
        // 设置User-Agent
        request.addValue("Pome/1.0 iOS-App", forHTTPHeaderField: "User-Agent")
        
        // 如果有Token，添加到Header中
        if let token = UserDefaults.standard.string(forKey: tokenKey) {
            request.addValue(token, forHTTPHeaderField: "X-User-Token")
        }
        
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
                    // 处理今日诗词API的JSON响应格式
                    let responseObj = try JSONDecoder().decode(JinrishiciResponse.self, from: data)
                    
                    if responseObj.status == "success" {
                        // 如果有新的Token，保存它
                        if let token = responseObj.token {
                            UserDefaults.standard.set(token, forKey: self.tokenKey)
                        }
                        
                        let data = responseObj.data
                        
                        // 优先使用 origin (全诗)，如果不存在则使用 content (名句)
                        var content = data.content
                        var title = "未知标题"
                        var dynasty = "未知朝代"
                        var author = "未知作者"
                        var translation: String? = nil
                        
                        if let origin = data.origin {
                            title = origin.title
                            dynasty = origin.dynasty
                            author = origin.author
                            content = origin.content.joined(separator: "\n")
                            if let translate = origin.translate {
                                translation = translate.joined(separator: "\n")
                            }
                        }
                        
                        let poem = Poem(
                            id: UUID(),
                            title: title,
                            dynasty: dynasty,
                            writer: author,
                            content: content,
                            remark: nil,
                            translation: translation,
                            shangxi: nil
                        )
                        
                        print("========== 网络诗词获取成功 ==========")
                        print("标题: \(title)")
                        print("朝代: \(dynasty)")
                        print("作者: \(author)")
                        print("内容:\n\(content)")
                        if let trans = translation {
                            print("翻译:\n\(trans)")
                        }
                        print("=====================================")
                        
                        // 由于API每次只返回一首，我们将其添加到列表头部
                        // 注意：这里需要考虑是否去重
                        if !self.poems.contains(where: { $0.title == poem.title && $0.content == poem.content }) {
                            self.poems.insert(poem, at: 0)
                        }
                        
                        // 保存更新后的列表到本地
                        self.savePoems(self.poems)
                        
                    } else {
                        self.errorMessage = "API返回错误"
                    }
                } catch let error {
                    self.errorMessage = "数据解析错误: \(error.localizedDescription)"
                    print("数据解析错误: \(error)")
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
        // 如果有网络获取的/本地缓存的诗词，优先展示这些
        if !poems.isEmpty {
            // 如果数量太少，可以补上预置的推荐诗词
            if poems.count < 5 {
                return poems + Self.dailyRecommendations
            }
            return poems
        }
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
    
    // 根据标签筛选诗词
    func getPoemsByTag(tag: String) -> [Poem] {
        return poems.filter { $0.tags?.contains { t in t.contains(tag) } ?? false }
    }
    
    // 根据年级筛选诗词
    func getPoemsByGrade(grade: String) -> [Poem] {
        switch grade {
        case "小学":
            return poems.filter { poem in
                guard let tags = poem.tags else { return false }
                return tags.contains { $0.contains("小学") || $0.contains("一年级") || $0.contains("二年级") || $0.contains("三年级") || $0.contains("四年级") || $0.contains("五年级") || $0.contains("六年级") }
            }
        case "初中":
            return poems.filter { poem in
                guard let tags = poem.tags else { return false }
                return tags.contains { $0.contains("初中") || $0.contains("七年级") || $0.contains("八年级") || $0.contains("九年级") }
            }
        case "高中":
            return poems.filter { poem in
                guard let tags = poem.tags else { return false }
                return tags.contains { $0.contains("高中") || $0.contains("高一") || $0.contains("高二") || $0.contains("高三") }
            }
        default:
            return []
        }
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

// 今日诗词 API 响应结构
struct JinrishiciResponse: Codable {
    let status: String
    let data: JinrishiciData
    let token: String?
    let ipAddress: String?
}

struct JinrishiciData: Codable {
    let id: String?
    let content: String
    let popularity: Int?
    let origin: JinrishiciOrigin?
    let matchTags: [String]?
    let recommendedReason: String?
    let cacheAt: String?
}

struct JinrishiciOrigin: Codable {
    let title: String
    let dynasty: String
    let author: String
    let content: [String]
    let translate: [String]?
}

extension PoemData {
    static let shijingJSON = #"""
[
  {
    "title": "关雎",
    "chapter": "国风",
    "section": "周南",
    "content": [
      "关关雎鸠，在河之洲。窈窕淑女，君子好逑。",
      "参差荇菜，左右流之。窈窕淑女，寤寐求之。",
      "求之不得，寤寐思服。悠哉悠哉，辗转反侧。",
      "参差荇菜，左右采之。窈窕淑女，琴瑟友之。",
      "参差荇菜，左右芼之。窈窕淑女，钟鼓乐之。"
    ]
  },
  {
    "title": "桃夭",
    "chapter": "国风",
    "section": "周南",
    "content": [
      "桃之夭夭，灼灼其华。之子于归，宜其室家。",
      "桃之夭夭，有蕡其实。之子于归，宜其家室。",
      "桃之夭夭，其叶蓁蓁。之子于归，宜其家人。"
    ]
  }
]
"""#

    static let chuciJSON = #"""
[
    {
        "title": "国殇",
        "section": "九歌",
        "author": "屈原",
        "content": [
            "操吴戈兮被犀甲，车错毂兮短兵接",
            "旌蔽日兮敌若云，矢交坠兮士争先",
            "凌余阵兮躐余行，左骖殪兮右刃伤",
            "霾两轮兮絷四马，援玉枹兮击鸣鼓",
            "天时怼兮威灵怒，严杀尽兮弃原野",
            "出不入兮往不反，平原忽兮路超远",
            "带长剑兮挟秦弓，首身离兮心不惩",
            "诚既勇兮又以武，终刚强兮不可凌",
            "身既死兮神以灵，魂魄毅兮为鬼雄。"
        ]
    },
    {
        "title": "山鬼",
        "section": "九歌",
        "author": "屈原",
        "content": [
            "若有人兮山之阿，被薜荔兮带女萝",
            "既含睇兮又宜笑，子慕予兮善窈窕",
            "乘赤豹兮从文狸，辛夷车兮结桂旗",
            "被石兰兮带杜衡，折芬馨兮遗所思",
            "余处幽篁兮终不见天，路险难兮独后来",
            "表独立兮山之上，云容容兮而在下",
            "杳冥冥兮羌昼晦，东风飘兮神灵雨",
            "留灵修兮憺忘归，岁既晏兮孰华予",
            "采三秀兮于山间，石磊磊兮葛蔓蔓",
            "怨公子兮怅忘归，君思我兮不得闲",
            "山中人兮芳杜若，饮石泉兮荫松柏",
            "君思我兮然疑作",
            "雷填填兮雨冥冥，猿啾啾兮狖夜鸣",
            "风飒飒兮木萧萧，思公子兮徒离忧。"
        ]
    }
]
"""#
}
