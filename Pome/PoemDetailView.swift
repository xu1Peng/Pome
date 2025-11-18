import SwiftUI

struct PoemDetailView: View {
    let poem: Poem
    @State private var showTranslation = false
    @State private var showBackground = false

    var body: some View {
        ScrollView {
                VStack(alignment: .leading, spacing: AppTheme.spacing_lg) {
                    // 诗词标题和作者信息
                    VStack(alignment: .leading, spacing: AppTheme.spacing_md) {
                        Text(poem.title)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(AppTheme.textPrimary)
                        
                        HStack {
                            Text(poem.dynasty)
                                .font(.subheadline)
                                .foregroundColor(AppTheme.textSecondary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(12)
                            
                            Text(poem.writer)
                                .font(.headline)
                                .foregroundColor(AppTheme.primaryColor)
                        }
                    }
                    .padding(.horizontal, AppTheme.spacing_lg)
                    
                    Divider()
                        .padding(.horizontal, AppTheme.spacing_lg)
                    
                    // 诗词内容
                    VStack(alignment: .leading, spacing: AppTheme.spacing_md) {
                        Text("诗词正文")
                            .font(.headline)
                            .foregroundColor(AppTheme.textPrimary)
                        
                        Text(poem.content)
                            .font(.title3)
                            .lineSpacing(8)
                            .foregroundColor(AppTheme.textPrimary)
                            .multilineTextAlignment(.leading)
                            .padding()
                            .background(AppTheme.cardBackground)
                            .cornerRadius(AppTheme.cornerRadius_md)
                    }
                    .padding(.horizontal, AppTheme.spacing_lg)
                    
                    // 注释（如果有）
                    if let remark = poem.remark, !remark.isEmpty {
                        VStack(alignment: .leading, spacing: AppTheme.spacing_md) {
                            Text("注释")
                                .font(.headline)
                                .foregroundColor(AppTheme.textPrimary)
                            
                            Text(remark)
                                .font(.body)
                                .foregroundColor(AppTheme.textSecondary)
                                .padding()
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(AppTheme.cornerRadius_md)
                        }
                        .padding(.horizontal, AppTheme.spacing_lg)
                    }
                    
                    // 译文部分
                    if let translation = poem.translation, !translation.isEmpty {
                        VStack(alignment: .leading, spacing: AppTheme.spacing_md) {
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    showTranslation.toggle()
                                }
                            }) {
                                HStack {
                                    Text("译文")
                                        .font(.headline)
                                        .foregroundColor(AppTheme.textPrimary)
                                    
                                    Spacer()
                                    
                                    Image(systemName: showTranslation ? "chevron.up" : "chevron.down")
                                        .foregroundColor(AppTheme.primaryColor)
                                }
                            }
                            
                            if showTranslation {
                                Text(translation)
                                    .font(.body)
                                    .foregroundColor(AppTheme.textSecondary)
                                    .padding()
                                    .background(Color.green.opacity(0.1))
                                    .cornerRadius(AppTheme.cornerRadius_md)
                                    .transition(.opacity.combined(with: .slide))
                            }
                        }
                        .padding(.horizontal, AppTheme.spacing_lg)
                    }
                    
                    // 诗词背景部分
                    if let background = poem.shangxi, !background.isEmpty {
                        VStack(alignment: .leading, spacing: AppTheme.spacing_md) {
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    showBackground.toggle()
                                }
                            }) {
                                HStack {
                                    Text("诗词背景")
                                        .font(.headline)
                                        .foregroundColor(AppTheme.textPrimary)
                                    
                                    Spacer()
                                    
                                    Image(systemName: showBackground ? "chevron.up" : "chevron.down")
                                        .foregroundColor(AppTheme.primaryColor)
                                }
                            }
                            
                            if showBackground {
                                Text(background)
                                    .font(.body)
                                    .foregroundColor(AppTheme.textSecondary)
                                    .padding()
                                    .background(Color.orange.opacity(0.1))
                                    .cornerRadius(AppTheme.cornerRadius_md)
                                    .transition(.opacity.combined(with: .slide))
                            }
                        }
                        .padding(.horizontal, AppTheme.spacing_lg)
                    }
                    
                    // 作者简介部分（基于朝代和作者名称提供简单介绍）
                    VStack(alignment: .leading, spacing: AppTheme.spacing_md) {
                        Text("作者简介")
                            .font(.headline)
                            .foregroundColor(AppTheme.textPrimary)
                        
                        Text(getAuthorBio(writer: poem.writer, dynasty: poem.dynasty))
                            .font(.body)
                            .foregroundColor(AppTheme.textSecondary)
                            .padding()
                            .background(Color.purple.opacity(0.1))
                            .cornerRadius(AppTheme.cornerRadius_md)
                    }
                    .padding(.horizontal, AppTheme.spacing_lg)
                    
                    Spacer().frame(height: AppTheme.spacing_lg)
                }
            }
            .navigationTitle(poem.title)
            .navigationBarTitleDisplayMode(.inline)

            .background(AppTheme.backgroundColor.ignoresSafeArea())
    }
    
    // 根据作者和朝代提供简单的作者介绍
    private func getAuthorBio(writer: String, dynasty: String) -> String {
        let authorBios: [String: String] = [
            "李白": "李白（701年－762年），字太白，号青莲居士，唐代伟大的浪漫主义诗人，被后人誉为'诗仙'。其诗雄奇飘逸，艺术成就极高。",
            "杜甫": "杜甫（712年－770年），字子美，自号少陵野老，唐代伟大的现实主义诗人，被后世称为'诗圣'。其诗被称为'诗史'。",
            "王维": "王维（701年－761年），字摩诘，唐代著名诗人、画家，外号'诗佛'。其诗画俱佳，尤以山水诗成就最高。",
            "白居易": "白居易（772年－846年），字乐天，号香山居士，唐代著名现实主义诗人，其诗歌题材广泛，形式多样，语言平易通俗。",
            "孟浩然": "孟浩然（689年－740年），字浩然，唐代著名的山水田园派诗人，与王维并称'王孟'。",
            "王之涣": "王之涣（688年－742年），字季凌，唐代著名诗人，以《登鹳雀楼》等边塞诗闻名。",
            "柳宗元": "柳宗元（773年－819年），字子厚，唐代文学家、哲学家，唐宋八大家之一。",
            "骆宾王": "骆宾王（约638年－684年），字观光，唐代诗人，初唐四杰之一，以《咏鹅》等诗著名。",
            "李绅": "李绅（772年－846年），字公垂，唐代诗人，以《悯农》诗反映农民疾苦而著名。"
        ]
        
        return authorBios[writer] ?? "\(writer)，\(dynasty)著名诗人，其作品在中国文学史上占有重要地位。"
    }
}

#Preview {
    PoemDetailView(poem: Poem.example)
}
