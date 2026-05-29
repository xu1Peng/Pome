import AVFoundation
import SwiftUI
import UIKit

struct PoemDetailView: View {
    let poem: Poem

    @StateObject private var speechController = PoemSpeechController()
    @ObservedObject private var favoriteStore = FavoritePoemStore.shared
    @State private var selectedSectionID = "注释"
    @State private var showCopiedToast = false

    private var isFavorite: Bool {
        favoriteStore.isFavorite(poem)
    }

    private var poemLines: [String] {
        poem.content
            .split(separator: "\n", omittingEmptySubsequences: false)
            .map(String.init)
    }

    private var copyText: String {
        "\(poem.title)\n[\(poem.dynasty)] \(poem.writer)\n\n\(poem.content)"
    }

    private var availableSections: [PoemDetailSectionData] {
        [
            PoemDetailSectionData(
                title: "注释",
                icon: "text.book.closed",
                content: poem.remark
            ),
            PoemDetailSectionData(
                title: "译文",
                icon: "character.book.closed",
                content: poem.translation
            ),
            PoemDetailSectionData(
                title: "赏析",
                icon: "sparkles",
                content: poem.shangxi
            ),
            PoemDetailSectionData(
                title: "作者",
                icon: "person.text.rectangle",
                content: authorBio(writer: poem.writer, dynasty: poem.dynasty)
            )
        ]
        .filter { !$0.content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    }

    private var selectedSection: PoemDetailSectionData? {
        availableSections.first(where: { $0.id == selectedSectionID }) ?? availableSections.first
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            AppTheme.backgroundColor.ignoresSafeArea()

            ScrollView {
                VStack(spacing: AppTheme.spacing_xxl) {
                    coverHeader
                    poemReader
                    sectionTabs
                }
                .padding(.horizontal, AppTheme.spacing_lg)
                .padding(.top, AppTheme.spacing_lg)
                .padding(.bottom, 112)
            }

            actionBar

            if showCopiedToast {
                copiedToast
                    .padding(.bottom, 92)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .navigationTitle(poem.title)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            selectedSectionID = selectedSection?.id ?? selectedSectionID
        }
        .onDisappear {
            speechController.stop()
        }
    }

    private var coverHeader: some View {
        VStack(spacing: AppTheme.spacing_md) {
            Text(poem.title)
                .font(.system(size: 34, weight: .semibold, design: .serif))
                .foregroundColor(AppTheme.textPrimary)
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .minimumScaleFactor(0.72)
                .frame(maxWidth: .infinity)

            HStack(spacing: AppTheme.spacing_sm) {
                Text(poem.dynasty)
                    .font(.footnote.weight(.medium))
                    .foregroundColor(AppTheme.primaryColor)
                    .padding(.horizontal, AppTheme.spacing_md)
                    .padding(.vertical, 6)
                    .background(AppTheme.primaryColor.opacity(0.1))
                    .clipShape(Capsule())

                Text(poem.writer)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(AppTheme.textSecondary)
            }

            if let tags = poem.tags, !tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: AppTheme.spacing_sm) {
                        ForEach(tags.prefix(4), id: \.self) { tag in
                            Text(tag)
                                .font(.caption.weight(.medium))
                                .foregroundColor(AppTheme.textSecondary)
                                .padding(.horizontal, AppTheme.spacing_sm)
                                .padding(.vertical, 5)
                                .background(Color.white.opacity(0.75))
                                .overlay(
                                    Capsule()
                                        .stroke(AppTheme.dividerColor, lineWidth: 1)
                                )
                                .clipShape(Capsule())
                        }
                    }
                    .padding(.horizontal, 1)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }

    private var poemReader: some View {
        VStack(spacing: 26) {
            HStack(spacing: AppTheme.spacing_md) {
                Rectangle()
                    .fill(AppTheme.primaryColor.opacity(0.28))
                    .frame(width: 34, height: 1)

                Text("正文")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(AppTheme.textSecondary)

                Rectangle()
                    .fill(AppTheme.primaryColor.opacity(0.28))
                    .frame(width: 34, height: 1)
            }

            VStack(spacing: 18) {
                ForEach(poemLines.indices, id: \.self) { index in
                    Text(poemLines[index])
                        .font(.system(size: 23, weight: .regular, design: .serif))
                        .foregroundColor(AppTheme.textPrimary)
                        .lineSpacing(10)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, AppTheme.spacing_xxl)
        .padding(.vertical, 34)
        .frame(maxWidth: .infinity, minHeight: 280)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius_lg, style: .continuous)
                .fill(Color(red: 1.0, green: 0.99, blue: 0.96))
        )
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(AppTheme.primaryColor.opacity(0.18))
                .frame(width: 3)
                .padding(.vertical, AppTheme.spacing_xxl)
                .padding(.leading, AppTheme.spacing_md)
        }
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius_lg, style: .continuous)
                .stroke(Color(red: 0.93, green: 0.90, blue: 0.84), lineWidth: 1)
        )
        .shadow(color: AppTheme.shadowColor.opacity(0.55), radius: 9, x: 0, y: 3)
    }

    private var sectionTabs: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacing_md) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppTheme.spacing_sm) {
                    ForEach(availableSections) { section in
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.18)) {
                                selectedSectionID = section.id
                            }
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: section.icon)
                                    .font(.system(size: 13, weight: .semibold))
                                Text(section.title)
                                    .font(.subheadline.weight(.semibold))
                            }
                            .foregroundColor(isSelected(section) ? .white : AppTheme.textSecondary)
                            .padding(.horizontal, AppTheme.spacing_md)
                            .padding(.vertical, 9)
                            .background(isSelected(section) ? AppTheme.primaryColor : Color.white)
                            .clipShape(Capsule())
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 1)
            }

            if let selectedSection {
                VStack(alignment: .leading, spacing: AppTheme.spacing_md) {
                    HStack(spacing: AppTheme.spacing_sm) {
                        Image(systemName: selectedSection.icon)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppTheme.primaryColor)

                        Text(selectedSection.title)
                            .font(.headline)
                            .foregroundColor(AppTheme.textPrimary)
                    }

                    Text(selectedSection.content)
                        .font(.body)
                        .foregroundColor(AppTheme.textPrimary)
                        .lineSpacing(8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(AppTheme.spacing_lg)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppTheme.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius_lg, style: .continuous))
                .shadow(color: AppTheme.shadowColor.opacity(0.55), radius: 8, x: 0, y: 3)
                .transition(.opacity)
            }
        }
    }

    private var actionBar: some View {
        HStack(spacing: AppTheme.spacing_sm) {
            DetailActionButton(
                title: speechController.isSpeaking ? "停止" : "朗读",
                icon: speechController.isSpeaking ? "stop.fill" : "speaker.wave.2.fill",
                isActive: speechController.isSpeaking,
                action: toggleSpeech
            )

            DetailActionButton(
                title: isFavorite ? "已收藏" : "收藏",
                icon: isFavorite ? "heart.fill" : "heart",
                isActive: isFavorite,
                action: toggleFavorite
            )

            DetailActionButton(
                title: "复制",
                icon: "doc.on.doc",
                isActive: false,
                action: copyPoem
            )
        }
        .padding(.horizontal, AppTheme.spacing_md)
        .padding(.vertical, AppTheme.spacing_sm)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
        .shadow(color: Color.black.opacity(0.14), radius: 14, x: 0, y: 6)
        .padding(.horizontal, AppTheme.spacing_lg)
        .padding(.bottom, AppTheme.spacing_lg)
    }

    private var copiedToast: some View {
        Text("已复制")
            .font(.subheadline.weight(.semibold))
            .foregroundColor(.white)
            .padding(.horizontal, AppTheme.spacing_lg)
            .padding(.vertical, AppTheme.spacing_sm)
            .background(Color.black.opacity(0.72))
            .clipShape(Capsule())
    }

    private func isSelected(_ section: PoemDetailSectionData) -> Bool {
        section.id == (selectedSection?.id ?? selectedSectionID)
    }

    private func toggleSpeech() {
        if speechController.isSpeaking {
            speechController.stop()
        } else {
            speechController.speak(copyText)
        }
    }

    private func toggleFavorite() {
        favoriteStore.toggle(poem)
    }

    private func copyPoem() {
        UIPasteboard.general.string = copyText

        withAnimation(.easeInOut(duration: 0.18)) {
            showCopiedToast = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
            withAnimation(.easeInOut(duration: 0.18)) {
                showCopiedToast = false
            }
        }
    }

    private func authorBio(writer: String, dynasty: String) -> String {
        let authorBios: [String: String] = [
            "李白": "李白（701年-762年），字太白，号青莲居士，唐代浪漫主义诗人，后人誉为“诗仙”。其诗想象瑰丽，气势奔放，语言明净自然。",
            "杜甫": "杜甫（712年-770年），字子美，自号少陵野老，唐代现实主义诗人，后世称为“诗圣”。其诗沉郁顿挫，关切时代与民生。",
            "王维": "王维（701年-761年），字摩诘，唐代诗人、画家。其诗兼具画意与禅意，尤以山水田园诗见长。",
            "白居易": "白居易（772年-846年），字乐天，号香山居士，唐代诗人。其诗题材广泛，语言平易，常关注现实人生。",
            "孟浩然": "孟浩然（689年-740年），唐代山水田园派诗人，与王维并称“王孟”。其诗清淡自然，意境悠远。",
            "王之涣": "王之涣（688年-742年），唐代诗人，善写边塞与登临之作，语言开阔明朗。",
            "柳宗元": "柳宗元（773年-819年），字子厚，唐代文学家、思想家，唐宋八大家之一。",
            "骆宾王": "骆宾王（约638年-684年），字观光，初唐四杰之一，诗文清俊有力。",
            "李绅": "李绅（772年-846年），字公垂，唐代诗人，以反映农事艰辛的《悯农》诗广为流传。"
        ]

        return authorBios[writer] ?? "\(writer)，\(dynasty)诗人。其作品在中国古典文学中具有独特的审美价值，常被后人传诵与学习。"
    }
}

private struct PoemDetailSectionData: Identifiable {
    var id: String { title }
    let title: String
    let icon: String
    let content: String

    init(title: String, icon: String, content: String?) {
        self.title = title
        self.icon = icon
        self.content = content ?? ""
    }
}

private struct DetailActionButton: View {
    let title: String
    let icon: String
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .foregroundColor(isActive ? .white : AppTheme.textPrimary)
            .frame(maxWidth: .infinity, minHeight: 42)
            .padding(.horizontal, AppTheme.spacing_sm)
            .background(isActive ? AppTheme.primaryColor : Color.white.opacity(0.92))
            .clipShape(Capsule())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

private final class PoemSpeechController: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    @Published var isSpeaking = false

    private let synthesizer = AVSpeechSynthesizer()

    override init() {
        super.init()
        synthesizer.delegate = self
    }

    func speak(_ text: String) {
        stop()

        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "zh-CN")
        utterance.rate = 0.45
        utterance.pitchMultiplier = 0.95

        isSpeaking = true
        synthesizer.speak(utterance)
    }

    func stop() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        isSpeaking = false
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.isSpeaking = false
        }
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.isSpeaking = false
        }
    }
}

struct PoemDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            PoemDetailView(poem: Poem.example)
        }
    }
}
