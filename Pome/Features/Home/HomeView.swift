import SwiftUI

struct HomeView: View {
    @ObservedObject private var poemService = PoemService.shared
    let onSelectPoem: (Poem) -> Void

    init(onSelectPoem: @escaping (Poem) -> Void = { _ in }) {
        self.onSelectPoem = onSelectPoem
    }

    var body: some View {
            ZStack {
                AppTheme.backgroundColor.ignoresSafeArea()

                VStack(spacing: 0) {
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
                                    ForEach(poemService.getDailyRecommendations()) { poem in
                                        Button {
                                            onSelectPoem(poem)
                                        } label: {
                                            RecommendedPoemCard(poem: poem)
                                                .frame(width: 280)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
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
                        Spacer().frame(height: AppTheme.spacing_lg)
                    }
                    }
                }
            }
        .onAppear {
            if poemService.poems.isEmpty {
                poemService.loadLocalPoems()
            }
        }
    }
}

// 推荐诗词卡片
struct RecommendedPoemCard: View {
    let poem: Poem

    // 根据诗词内容生成不同的渐变色
    private var gradientColors: [Color] {
        let hash = abs(poem.title.hashValue)
        let colorSets: [[Color]] = [
            [Color(red: 0.1, green: 0.3, blue: 0.5), Color(red: 0.2, green: 0.4, blue: 0.6)],
            [Color(red: 0.3, green: 0.1, blue: 0.5), Color(red: 0.4, green: 0.2, blue: 0.6)],
            [Color(red: 0.5, green: 0.3, blue: 0.1), Color(red: 0.6, green: 0.4, blue: 0.2)],
            [Color(red: 0.1, green: 0.5, blue: 0.3), Color(red: 0.2, green: 0.6, blue: 0.4)],
            [Color(red: 0.5, green: 0.1, blue: 0.3), Color(red: 0.6, green: 0.2, blue: 0.4)]
        ]
        return colorSets[hash % colorSets.count]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacing_md) {
                // 图片区域 - 使用渐变背景模拟图片
                ZStack {
                    // 背景渐变
                    LinearGradient(
                        gradient: Gradient(colors: gradientColors),
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
                Text(poem.title)
                    .font(.headline)
                    .foregroundColor(AppTheme.textPrimary)

                // 作者和朝代
                Text("\(poem.dynasty) · \(poem.writer)")
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary)

                // 诗词内容预览（取前两句）
                Text(poem.content.components(separatedBy: "\n").prefix(2).joined(separator: "\n"))
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

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
