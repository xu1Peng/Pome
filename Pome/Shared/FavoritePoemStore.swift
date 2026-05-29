import Foundation

final class FavoritePoemStore: ObservableObject {
    static let shared = FavoritePoemStore()

    @Published private(set) var favoriteIDs: Set<String>

    private let favoriteIDsKey = "favorite_poem_ids"
    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        self.favoriteIDs = Set(userDefaults.stringArray(forKey: favoriteIDsKey) ?? [])
    }

    func isFavorite(_ poem: Poem) -> Bool {
        favoriteIDs.contains(poem.id) || userDefaults.bool(forKey: Poem.legacyFavoriteKey(for: poem))
    }

    func setFavorite(_ isFavorite: Bool, for poem: Poem) {
        if isFavorite {
            favoriteIDs.insert(poem.id)
        } else {
            favoriteIDs.remove(poem.id)
            userDefaults.removeObject(forKey: Poem.legacyFavoriteKey(for: poem))
        }

        save()
    }

    func toggle(_ poem: Poem) {
        setFavorite(!isFavorite(poem), for: poem)
    }

    func favoritePoems(from poems: [Poem]) -> [Poem] {
        poems.filter(isFavorite)
    }

    private func save() {
        userDefaults.set(Array(favoriteIDs).sorted(), forKey: favoriteIDsKey)
    }
}
