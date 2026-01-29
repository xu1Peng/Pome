import SwiftUI

struct PoemView: View {
    let poem: Poem
    @State private var showTranslation = false
    @State private var showShangxi = false

    var body: some View {
        ZStack {
            AppTheme.backgroundColor.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .center, spacing: AppTheme.spacing_lg) {
                    // 标题
                    Text(poem.title)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.textPrimary)
                        .padding(.top, AppTheme.spacing_lg)

                    // 朝代和作者
                    HStack(spacing: AppTheme.spacing_md) {
                        Text("[\(poem.dynasty)]")
                            .font(.subheadline)
                        Text(poem.writer)
                            .font(.subheadline)
                    }
                    .foregroundColor(AppTheme.textSecondary)

                    Divider()
                        .padding(.vertical, AppTheme.spacing_md)

                    // 诗词内容
                    let contentLines = poem.content.split(separator: "\n")
                    VStack(alignment: .center, spacing: AppTheme.spacing_md) {
                        ForEach(contentLines.indices, id: \.self) { index in
                            Text(String(contentLines[index]))
                                .font(.system(.body, design: .serif))
                                .foregroundColor(AppTheme.textPrimary)
                                .lineSpacing(4)
                        }
                    }
                    .padding(AppTheme.spacing_lg)
                    .frame(maxWidth: .infinity)
                    .background(AppTheme.cardBackground)
                    .cornerRadius(AppTheme.cornerRadius_lg)
                    .shadow(color: AppTheme.shadowColor, radius: AppTheme.shadowRadius, x: 0, y: 2)

                    // 注释 (如果有)
                    if let remark = poem.remark, !remark.isEmpty {
                        ExpandableSection(title: "注释", content: remark)
                    }

                    // 翻译 (如果有)
                    if let translation = poem.translation, !translation.isEmpty {
                        ExpandableSection(title: "翻译", content: translation)
                    }

                    // 赏析 (如果有)
                    if let shangxi = poem.shangxi, !shangxi.isEmpty {
                        ExpandableSection(title: "赏析", content: shangxi)
                    }

                    Spacer().frame(height: AppTheme.spacing_lg)
                }
                .padding(AppTheme.spacing_lg)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

// 可展开的内容区域
struct ExpandableSection: View {
    let title: String
    let content: String
    @State private var isExpanded = false

    var body: some View {
        VStack(spacing: 0) {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            }) {
                HStack(spacing: AppTheme.spacing_md) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(AppTheme.textPrimary)

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(AppTheme.primaryColor)
                        .font(.system(size: 14, weight: .semibold))
                }
                .padding(AppTheme.spacing_lg)
                .background(AppTheme.cardBackground)
            }

            if isExpanded {
                Divider()
                    .padding(.horizontal, AppTheme.spacing_lg)

                Text(content)
                    .font(.body)
                    .foregroundColor(AppTheme.textPrimary)
                    .lineSpacing(6)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(AppTheme.spacing_lg)
                    .background(AppTheme.cardBackground)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(AppTheme.cardBackground)
        .cornerRadius(AppTheme.cornerRadius_lg)
        .shadow(color: AppTheme.shadowColor, radius: AppTheme.shadowRadius, x: 0, y: 2)
    }
}

struct PoemView_Previews: PreviewProvider {
    static var previews: some View {
        PoemView(poem: Poem.example)
    }
} 