import SwiftUI

struct PoemView: View {
    let poem: Poem
    @State private var showTranslation = false
    @State private var showShangxi = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 20) {
                // 标题
                Text(poem.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)
                
                // 朝代和作者
                HStack {
                    Text("[\(poem.dynasty)]")
                        .font(.headline)
                    Text(poem.writer)
                        .font(.headline)
                }
                .foregroundColor(.gray)
                
                // 诗词内容
                let contentLines = poem.content.split(separator: "\n")
                VStack(alignment: .center, spacing: 10) {
                    ForEach(contentLines.indices, id: \.self) { index in
                        Text(String(contentLines[index]))
                            .font(.system(.title3, design: .serif))
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                
                // 注释 (如果有)
                if let remark = poem.remark, !remark.isEmpty {
                    VStack(alignment: .leading) {
                        Text("注释")
                            .font(.headline)
                            .padding(.bottom, 5)
                        
                        Text(remark)
                            .font(.body)
                            .lineSpacing(5)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }
                
                // 翻译 (如果有)
                if let translation = poem.translation, !translation.isEmpty {
                    Button(action: {
                        withAnimation {
                            showTranslation.toggle()
                        }
                    }) {
                        HStack {
                            Text("翻译")
                                .font(.headline)
                            Spacer()
                            Image(systemName: showTranslation ? "chevron.up" : "chevron.down")
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                    
                    if showTranslation {
                        Text(translation)
                            .font(.body)
                            .lineSpacing(5)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
                
                // 赏析 (如果有)
                if let shangxi = poem.shangxi, !shangxi.isEmpty {
                    Button(action: {
                        withAnimation {
                            showShangxi.toggle()
                        }
                    }) {
                        HStack {
                            Text("赏析")
                                .font(.headline)
                            Spacer()
                            Image(systemName: showShangxi ? "chevron.up" : "chevron.down")
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                    
                    if showShangxi {
                        Text(shangxi)
                            .font(.body)
                            .lineSpacing(5)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PoemView_Previews: PreviewProvider {
    static var previews: some View {
        PoemView(poem: Poem.example)
    }
} 