import Foundation

private func resourceDebugLog(_ message: @autoclosure () -> String) {
#if DEBUG
    print(message())
#endif
}

enum PoemResourceLoader {
    static func loadBundledPoems(bundle: Bundle = .main) -> [Poem] {
        let collections: [PoemResourceCollection] = [
            TangPoemCollection(),
            SongCiCollection(),
            ShijingCollection(),
            ChuciCollection(),
            MaoPoemCollection()
        ]

        return collections.flatMap { collection in
            do {
                return try collection.loadPoems(bundle: bundle)
            } catch {
                resourceDebugLog("加载 \(collection.filename).json 失败: \(error)")
                return []
            }
        }
    }
}

private protocol PoemResourceCollection {
    var filename: String { get }
    func loadPoems(bundle: Bundle) throws -> [Poem]
}

private extension PoemResourceCollection {
    func data(bundle: Bundle) throws -> Data {
        guard let url = bundle.url(forResource: filename, withExtension: "json") else {
            throw PoemResourceError.missingResource(filename)
        }

        return try Data(contentsOf: url)
    }
}

private enum PoemResourceError: Error {
    case missingResource(String)
}

private struct TangPoemCollection: PoemResourceCollection {
    let filename = "tangshi300"

    func loadPoems(bundle: Bundle) throws -> [Poem] {
        struct TangPoem: Codable {
            let id: String?
            let author: String
            let paragraphs: [String]
            let title: String
            let tags: [String]?
        }

        return try JSONDecoder()
            .decode([TangPoem].self, from: data(bundle: bundle))
            .map {
                Poem(
                    id: $0.id,
                    title: $0.title,
                    dynasty: "唐代",
                    writer: $0.author,
                    content: $0.paragraphs.joined(separator: "\n"),
                    tags: $0.tags
                )
            }
    }
}

private struct SongCiCollection: PoemResourceCollection {
    let filename = "songci300"

    func loadPoems(bundle: Bundle) throws -> [Poem] {
        struct SongPoem: Codable {
            let author: String
            let paragraphs: [String]
            let rhythmic: String
            let tags: [String]?
        }

        return try JSONDecoder()
            .decode([SongPoem].self, from: data(bundle: bundle))
            .map {
                Poem(
                    title: $0.rhythmic,
                    dynasty: "宋代",
                    writer: $0.author,
                    content: $0.paragraphs.joined(separator: "\n"),
                    tags: $0.tags
                )
            }
    }
}

private struct ShijingCollection: PoemResourceCollection {
    let filename = "shijing"

    func loadPoems(bundle: Bundle) throws -> [Poem] {
        struct ShijingPoem: Codable {
            let title: String
            let chapter: String
            let section: String
            let content: [String]
        }

        return try JSONDecoder()
            .decode([ShijingPoem].self, from: data(bundle: bundle))
            .map {
                Poem(
                    title: $0.title,
                    dynasty: "先秦",
                    writer: "诗经",
                    content: $0.content.joined(separator: "\n"),
                    remark: "\($0.chapter) · \($0.section)"
                )
            }
    }
}

private struct ChuciCollection: PoemResourceCollection {
    let filename = "chuci"

    func loadPoems(bundle: Bundle) throws -> [Poem] {
        struct ChuciPoem: Codable {
            let title: String
            let author: String
            let content: [String]
            let section: String
        }

        return try JSONDecoder()
            .decode([ChuciPoem].self, from: data(bundle: bundle))
            .map {
                Poem(
                    title: $0.title,
                    dynasty: "先秦",
                    writer: $0.author,
                    content: $0.content.joined(separator: "\n"),
                    remark: $0.section
                )
            }
    }
}

private struct MaoPoemCollection: PoemResourceCollection {
    let filename = "maozedong"

    func loadPoems(bundle: Bundle) throws -> [Poem] {
        struct MaoPoem: Codable {
            let title: String
            let paragraphs: [String]
            let author: String
            let dynasty: String
        }

        return try JSONDecoder()
            .decode([MaoPoem].self, from: data(bundle: bundle))
            .map {
                Poem(
                    title: $0.title,
                    dynasty: $0.dynasty,
                    writer: $0.author,
                    content: $0.paragraphs.joined(separator: "\n")
                )
            }
    }
}
