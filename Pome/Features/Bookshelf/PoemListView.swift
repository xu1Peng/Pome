import SwiftUI

struct PoemListView: View {
    let title: String
    @StateObject private var poemService = PoemService()
    
    var body: some View {
        List(poemService.poems) { poem in
            NavigationLink(destination: PoemDetailView(poem: poem)) {
                VStack(alignment: .leading) {
                    Text(poem.title)
                        .font(.headline)
                    Text(poem.writer)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
        }
        .navigationTitle(title)
        .onAppear {
            if poemService.poems.isEmpty {
                poemService.loadLocalPoems()
            }
        }
    }
}
