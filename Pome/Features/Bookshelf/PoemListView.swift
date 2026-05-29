import SwiftUI

struct PoemListView: View {
    let title: String
    let mode: Mode

    @ObservedObject private var poemService = PoemService.shared
    @ObservedObject private var favoriteStore = FavoritePoemStore.shared

    enum Mode {
        case favorites
        case all
    }

    private var poems: [Poem] {
        switch mode {
        case .favorites:
            return favoriteStore.favoritePoems(from: poemService.poems)
        case .all:
            return poemService.poems
        }
    }

    init(title: String, mode: Mode = .all) {
        self.title = title
        self.mode = mode
    }
    
    var body: some View {
        Group {
            if poems.isEmpty {
                VStack(spacing: AppTheme.spacing_md) {
                    Image(systemName: mode == .favorites ? "heart" : "doc.text")
                        .font(.system(size: 40))
                        .foregroundColor(AppTheme.textSecondary)

                    Text(mode == .favorites ? "还没有收藏诗词" : "暂无诗词数据")
                        .font(.headline)
                        .foregroundColor(AppTheme.textPrimary)

                    Text(mode == .favorites ? "在诗词详情页点按收藏后会出现在这里" : "请稍后再试")
                        .font(.subheadline)
                        .foregroundColor(AppTheme.textSecondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(AppTheme.backgroundColor)
            } else {
                List(poems) { poem in
                    NavigationLink(destination: PoemDetailView(poem: poem)) {
                        VStack(alignment: .leading, spacing: AppTheme.spacing_xs) {
                            Text(poem.title)
                                .font(.headline)
                            Text("\(poem.dynasty) · \(poem.writer)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, AppTheme.spacing_xs)
                    }
                }
            }
        }
        .navigationTitle(title)
    }
}
