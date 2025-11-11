import SwiftUI

struct HomeView: View {
    @StateObject private var poemService = PoemService()
    @State private var selectedPoem: Poem?
    
    var body: some View {
        ZStack {
            AppTheme.backgroundColor.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 搜索栏
                HStack(spacing: AppTheme.spacing_md) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(AppTheme.textSecondary)
                    
                    Text("诗词搜索")
                        .foregroundColor(AppTheme.textSecondary)
                    
                    Spacer()
                }
                .padding(AppTheme.spacing_md)
                .background(AppTheme.cardBackground)
                .cornerRadius(AppTheme.cornerRadius_md)
                .padding(AppTheme.spacing_lg)
                
                ScrollView {
                    VStack(spacing: AppTheme.spacing_lg) {
                        // 每日推荐
                        VStack(alignment: .leading, spacing: AppTheme.spacing_md) {
                            Text("每日推荐")
                                .font(.headline)
                                .foregroundColor(AppTheme.textPrimary)
                                .padding(.horizontal, AppTheme.spacing_lg)
                            
                            // 推荐卡片 1
                            RecommendedPoemCard(
                                image: "moon.stars.fill",
                                title: "静夜思",
                                author: "李白",
                                description: "床前明月光，疑是地上霜。"
                            )
                            .padding(.horizontal, AppTheme.spacing_lg)
                            
                            // 推荐卡片 2
                            RecommendedPoemCard(
                                image: "water.waves",
                                title: "水调歌头",
                                author: "苏轼",
                                description: "明月几时有，把酒问青天。"
                            )
                            .padding(.horizontal, AppTheme.spacing_lg)
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
                                    title: "百家选粹",
                                    hasArrow: true
                                )
                                
                                CategoryItemView(
                                    icon: "moon.fill",
                                    title: "咏月",
                                    hasArrow: true
                                )
                                
                                CategoryItemView(
                                    icon: "triangle.fill",
                                    title: "应景诗",
                                    hasArrow: true
                                )
                                
                                CategoryItemView(
                                    icon: "book.fill",
                                    title: "豪放派词选",
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
        .onAppear {
            if poemService.poems.isEmpty {
                poemService.loadLocalPoems()
            }
        }
    }
}

// 推荐诗词卡片
struct RecommendedPoemCard: View {
    let image: String
    let title: String
    let author: String
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacing_md) {
            HStack(spacing: AppTheme.spacing_md) {
                Image(systemName: image)
                    .font(.system(size: 24))
                    .foregroundColor(AppTheme.primaryColor)
                    .frame(width: 50, height: 50)
                    .background(AppTheme.primaryColor.opacity(0.1))
                    .cornerRadius(AppTheme.cornerRadius_md)
                
                VStack(alignment: .leading, spacing: AppTheme.spacing_xs) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(AppTheme.textPrimary)
                    
                    Text(author)
                        .font(.caption)
                        .foregroundColor(AppTheme.textSecondary)
                }
                
                Spacer()
            }
            
            Text(description)
                .font(.subheadline)
                .foregroundColor(AppTheme.textSecondary)
                .lineLimit(2)
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
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(AppTheme.primaryColor)
                .frame(width: 30, height: 30)
            
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

