import Foundation

struct Poem: Codable, Identifiable, Hashable {
    let id: String
    let title: String
    let dynasty: String
    let writer: String
    let content: String
    let remark: String?
    let translation: String?
    let shangxi: String?
    let tags: [String]?

    private struct MongoID: Codable {
        let oid: String

        enum CodingKeys: String, CodingKey {
            case oid = "$oid"
        }
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case legacyID = "_id"
        case title
        case dynasty
        case writer
        case content
        case remark
        case translation
        case shangxi
        case tags
    }

    init(
        id: String? = nil,
        title: String,
        dynasty: String,
        writer: String,
        content: String,
        remark: String? = nil,
        translation: String? = nil,
        shangxi: String? = nil,
        tags: [String]? = nil
    ) {
        self.title = title
        self.dynasty = dynasty
        self.writer = writer
        self.content = content
        self.remark = remark
        self.translation = translation
        self.shangxi = shangxi
        self.tags = tags
        self.id = id ?? Self.stableID(title: title, writer: writer, content: content)
    }

    init(
        id: UUID,
        title: String,
        dynasty: String,
        writer: String,
        content: String,
        remark: String? = nil,
        translation: String? = nil,
        shangxi: String? = nil,
        tags: [String]? = nil
    ) {
        self.init(
            id: id.uuidString,
            title: title,
            dynasty: dynasty,
            writer: writer,
            content: content,
            remark: remark,
            translation: translation,
            shangxi: shangxi,
            tags: tags
        )
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let title = try container.decode(String.self, forKey: .title)
        let dynasty = try container.decode(String.self, forKey: .dynasty)
        let writer = try container.decode(String.self, forKey: .writer)
        let content = try container.decode(String.self, forKey: .content)

        self.title = title
        self.dynasty = dynasty
        self.writer = writer
        self.content = content
        self.remark = try container.decodeIfPresent(String.self, forKey: .remark)
        self.translation = try container.decodeIfPresent(String.self, forKey: .translation)
        self.shangxi = try container.decodeIfPresent(String.self, forKey: .shangxi)
        self.tags = try container.decodeIfPresent([String].self, forKey: .tags)

        if let id = try? container.decode(String.self, forKey: .id), !id.isEmpty {
            self.id = id
        } else if let legacyID = try? container.decode(String.self, forKey: .legacyID), !legacyID.isEmpty {
            self.id = legacyID
        } else if let mongoID = try? container.decode(MongoID.self, forKey: .legacyID), !mongoID.oid.isEmpty {
            self.id = mongoID.oid
        } else {
            self.id = Self.stableID(title: title, writer: writer, content: content)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(dynasty, forKey: .dynasty)
        try container.encode(writer, forKey: .writer)
        try container.encode(content, forKey: .content)
        try container.encodeIfPresent(remark, forKey: .remark)
        try container.encodeIfPresent(translation, forKey: .translation)
        try container.encodeIfPresent(shangxi, forKey: .shangxi)
        try container.encodeIfPresent(tags, forKey: .tags)
    }

    static func stableID(title: String, writer: String, content: String) -> String {
        let firstLine = content
            .split(separator: "\n", omittingEmptySubsequences: true)
            .first
            .map(String.init) ?? content

        return [title, writer, firstLine]
            .map(normalizedIdentifierPart)
            .joined(separator: "|")
    }

    static func legacyFavoriteKey(for poem: Poem) -> String {
        let firstLine = poem.content.split(separator: "\n").first.map(String.init) ?? poem.content
        return "favorite_poem_\(poem.title)_\(poem.writer)_\(firstLine)"
    }

    private static func normalizedIdentifierPart(_ value: String) -> String {
        value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\n", with: "")
            .replacingOccurrences(of: "\r", with: "")
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "　", with: "")
    }

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
