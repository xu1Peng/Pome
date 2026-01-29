import Foundation

struct Poem: Codable, Identifiable, Hashable {
    // 使用自定义ID，因为API返回的id格式是MongoDB格式
    var id = UUID()
    let title: String
    let dynasty: String
    let writer: String
    let content: String
    let remark: String?
    let translation: String?
    let shangxi: String?
    
    // 从API获取的MongoDB ID格式
    struct MongoID: Codable {
        let oid: String
        
        enum CodingKeys: String, CodingKey {
            case oid = "$oid"
        }
    }
    
    // 删除重复的结构体
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case title
        case dynasty
        case writer
        case content
        case remark
        case translation
        case shangxi
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // 解析MongoDB格式的ID
        if let idContainer = try? container.decode(MongoID.self, forKey: .id) {
            // 从MongoDB ID生成UUID (不使用API的ID)
            self.id = UUID()
        }
        
        title = try container.decode(String.self, forKey: .title)
        dynasty = try container.decode(String.self, forKey: .dynasty)
        writer = try container.decode(String.self, forKey: .writer)
        content = try container.decode(String.self, forKey: .content)
        remark = try container.decodeIfPresent(String.self, forKey: .remark)
        translation = try container.decodeIfPresent(String.self, forKey: .translation)
        shangxi = try container.decodeIfPresent(String.self, forKey: .shangxi)
    }
    
    // 添加一个标准的初始化方法以解决构造函数调用问题
    init(id: UUID = UUID(), title: String, dynasty: String, writer: String, content: String, remark: String? = nil, translation: String? = nil, shangxi: String? = nil) {
        self.id = id
        self.title = title
        self.dynasty = dynasty
        self.writer = writer
        self.content = content
        self.remark = remark
        self.translation = translation
        self.shangxi = shangxi
    }
    
    // 提供一个默认的诗词，以防API调用失败
    static let example = Poem(
        title: "将进酒",
        dynasty: "唐代",
        writer: "李白",
        content: "君不见，黄河之水天上来，奔流到海不复回。\n君不见，高堂明镜悲白发，朝如青丝暮成雪。\n人生得意须尽欢，莫使金樽空对月。\n天生我材必有用，千金散尽还复来。\n烹羊宰牛且为乐，会须一饮三百杯。\n岑夫子，丹丘生，将进酒，杯莫停。\n与君歌一曲，请君为我倾耳听。\n钟鼓馔玉不足贵，但愿长醉不复醒。\n古来圣贤皆寂寞，惟有饮者留其名。\n陈王昔时宴平乐，斗酒十千恣欢谑。\n主人何为言少钱，径须沽取对君酌。\n五花马，千金裘，呼儿将出换美酒，与尔同销万古愁。",
        remark: "将进酒：属乐府旧题。将（qiāng）：请。",
        translation: "你难道看不见那黄河之水从天上奔腾而来，波涛翻滚直奔东海，从不再往回流。你难道看不见那悬挂在高堂上的明镜里映出白发的忧伤，早晨如青丝一般的头发傍晚就会变得如雪一般苍白。",
        shangxi: "这是一首着名的以劝酒为主题的诗。全诗感情奔放，语言雄浑，气度非凡，体现了李白桀骜不驯的性格和物极必反的人生哲理。"
    )
} 