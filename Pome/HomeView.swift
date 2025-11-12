import SwiftUI

struct HomeView: View {
    @StateObject private var poemService = PoemService()
    @State private var selectedPoem: Poem?
    @State private var isShowingSearch = false

    var body: some View {
        ZStack {
            AppTheme.backgroundColor.ignoresSafeArea()

            VStack(spacing: 0) {
                // 顶部导航栏
//                HomeHeaderView(isShowingSearch: $isShowingSearch)

                ScrollView {
                    VStack(spacing: AppTheme.spacing_lg) {
                        Spacer().frame(height: 5)

                        // 每日推荐
                        VStack(alignment: .leading, spacing: AppTheme.spacing_md) {
                            Text("每日推荐")
                                .font(.headline)
                                .foregroundColor(AppTheme.textPrimary)
                                .padding(.horizontal, AppTheme.spacing_lg)

                            // 推荐卡片横排列
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: AppTheme.spacing_md) {
                                    // 推荐卡片 1
                                    RecommendedPoemCard(
                                        imageName: "poem_moonlight",
                                        title: "静夜思",
                                        author: "李白",
                                        description: "床前明月光，疑是地上霜。"
                                    )
                                    .frame(width: 280)

                                    // 推荐卡片 2
                                    RecommendedPoemCard(
                                        imageName: "poem_water",
                                        title: "水调歌头",
                                        author: "苏轼",
                                        description: "明月几时有，把酒问青天。"
                                    )
                                    .frame(width: 280)
                                }
                                .padding(.horizontal, AppTheme.spacing_lg)
                            }
                        }

                        // 精选诗集
                        VStack(alignment: .leading, spacing: AppTheme.spacing_md) {
                            Text("精选诗集")
                                .font(.headline)
                                .foregroundColor(AppTheme.textPrimary)
                                .padding(.horizontal, AppTheme.spacing_lg)

                            VStack(spacing: AppTheme.spacing_md) {
                                CategoryItemView(
                                    icon: "sun.max.fill",
                                    title: "四季流转",
                                    hasArrow: true
                                )

                                CategoryItemView(
                                    icon: "moon.fill",
                                    title: "晓月",
                                    hasArrow: true
                                )

                                CategoryItemView(
                                    icon: "triangle.fill",
                                    title: "边塞诗",
                                    hasArrow: true
                                )

                                CategoryItemView(
                                    icon: "book.fill",
                                    title: "豪放派诗选",
                                    hasArrow: true
                                )
                            }
                            .padding(.horizontal, AppTheme.spacing_lg)
                        }

                        Spacer().frame(height: AppTheme.spacing_lg)
                    }
                }
            }
        }
        .sheet(isPresented: $isShowingSearch) {
            SearchView(poemService: poemService) { poem in
                selectedPoem = poem
                isShowingSearch = false
            }
        }
        .onAppear {
            if poemService.poems.isEmpty {
                poemService.loadLocalPoems()
            }
        }
    }
}

// 顶部导航栏
//struct HomeHeaderView: View {
//    @Binding var isShowingSearch: Bool
//
//    var body: some View {
//        HStack(spacing: AppTheme.spacing_lg) {
//            // 左侧：书籍图标
//            Image(systemName: "book.fill")
//                .font(.system(size: 20))
//                .foregroundColor(AppTheme.textPrimary)
//
//            // 中间：标题
//            Text("诗词鉴赏")
//                .font(.system(size: 18, weight: .semibold))
//                .foregroundColor(AppTheme.textPrimary)
//
//            Spacer()
//
//            // 右侧：搜索图标
//            Button(action: {
//                isShowingSearch = true
//            }) {
//                Image(systemName: "magnifyingglass")
//                    .font(.system(size: 16))
//                    .foregroundColor(AppTheme.textPrimary)
//            }
//        }
//        .padding(.horizontal, AppTheme.spacing_lg)
//        .padding(.vertical, AppTheme.spacing_md)
//        .background(AppTheme.backgroundColor)
//        .border(width: 0.5, edges: [.bottom], color: AppTheme.dividerColor)
//    }
//}

// 推荐诗词卡片
struct RecommendedPoemCard: View {
    let imageName: String
    let title: String
    let author: String
    let description: String

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacing_md) {
            // 图片区域 - 使用渐变背景模拟图片
            ZStack {
                // 背景渐变
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.1, green: 0.3, blue: 0.5),
                        Color(red: 0.2, green: 0.4, blue: 0.6)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                // 装饰元素
                VStack {
                    HStack {
                        Circle()
                            .fill(Color.white.opacity(0.3))
                            .frame(width: 40, height: 40)
                        Spacer()
                    }
                    .padding()

                    Spacer()

                    HStack {
                        Spacer()
                        Circle()
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 60, height: 60)
                            .padding()
                    }
                }
            }
            .frame(height: 160)
            .cornerRadius(AppTheme.cornerRadius_md)

            // 标题
            Text(title)
                .font(.headline)
                .foregroundColor(AppTheme.textPrimary)

            // 作者
            Text(author)
                .font(.caption)
                .foregroundColor(AppTheme.textSecondary)

            // 描述
            Text(description)
                .font(.caption)
                .foregroundColor(AppTheme.textSecondary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)

            Spacer()
        }
        .padding(AppTheme.spacing_md)
        .background(AppTheme.cardBackground)
        .cornerRadius(AppTheme.cornerRadius_md)
        .shadow(color: AppTheme.shadowColor, radius: AppTheme.shadowRadius, x: 0, y: 2)
    }
}

// 分类项目视图
struct CategoryItemView: View {
    let icon: String
    let title: String
    let hasArrow: Bool

    var body: some View {
        HStack(spacing: AppTheme.spacing_md) {
            // 图标背景
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(AppTheme.primaryColor)
                .frame(width: 44, height: 44)
                .background(Color(red: 0.95, green: 0.92, blue: 0.88))
                .cornerRadius(AppTheme.cornerRadius_md)

            Text(title)
                .font(.body)
                .foregroundColor(AppTheme.textPrimary)

            Spacer()

            if hasArrow {
                Image(systemName: "chevron.right")
                    .foregroundColor(AppTheme.textSecondary)
            }
        }
        .padding(AppTheme.spacing_md)
        .background(AppTheme.cardBackground)
        .cornerRadius(AppTheme.cornerRadius_md)
    }
}

#Preview {
    HomeView()
}

