import SwiftUI
#if os(iOS)
import AlertToast
#endif

struct FrekPlaceList: View {
    
    @ObservedObject var viewModel = FrekPlaceListViewModel()
    @State private var selectedId: String? = nil
    @State private var isLocal: Bool = true
    @State private var showSuccessToast = false
    @State private var showErrorToast = false
    @State private var lastError: FetchError?
    @State private var query = ""

    func onOpenURL(_ url: URL) {
        guard let host = url.host,
              let frekPlace = viewModel.frekPlaces.first(where: { host == $0.id || host == "frek://\($0.id)" })
        else {
            print("❌ Unsupported deep link: \(url)")
            return
        }
        selectedId = frekPlace.id
    }
    
    var body: some View {
        let favorites = viewModel
            .favorites
            .filter { query.isEmpty || $0.name.localizedCaseInsensitiveContains(query) }
        let other = viewModel
            .sortedFrekPlaces
            .filter { !$0.favorite }
            .filter { query.isEmpty || $0.name.localizedCaseInsensitiveContains(query) }
        
        return NavigationStack {
            List {
                if favorites.count > 0 {
                    Section("Favorites") {
                        ForEach(favorites) { frekplace in
                            NavigationLink(value: frekplace) {
                                let index = viewModel.frekPlaces.firstIndex { frekplace.id == $0.id }!
                                FrekPlaceRow(frekPlace: $viewModel.frekPlaces[index])
                            }
                        }
                    }
                }
                Section("Toutes") {
                    ForEach(other) { frekplace in
                        NavigationLink(value: frekplace) {
                            let index = viewModel.frekPlaces.firstIndex { frekplace.id == $0.id }!
                            FrekPlaceRow(frekPlace: $viewModel.frekPlaces[index])
                        }
                    }
                }
            }
            .navigationDestination(for: FrekPlace.self) { frekplace in
                let index = viewModel.frekPlaces.firstIndex { frekplace.id == $0.id }!
                FrekPlaceDetail(frekPlace: $viewModel.frekPlaces[index])
            }
            .navigationBarTitle(Text("Salles de gym"))
            .searchable(text: $query, placement: .automatic)
            .frekListStyle()
            .onOpenURL(perform: onOpenURL)
            #if os(iOS)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Picker("Data Provider", selection: $isLocal) {
                            Label("Server Data", systemImage: "icloud").tag(false)
                            Label("Local Data", systemImage: "iphone").tag(true)
                        }
                        .onChange(of: isLocal) { setLocal in
                            viewModel.dataProvider = setLocal ? LocalStore() : WebFetcher()
                            Task {
                                let result = await viewModel.fetchFrekPlaces()
                                switch result {
                                case .success(_): self.showSuccessToast = true
                                case .failure(let error):
                                    self.lastError = error
                                    self.showErrorToast = true
                                }
                            }
                        }
                    } label: {
                        Label("Options", systemImage: "ellipsis.circle")
                    }.opacity(DeviceMeta().isTest ? 1 : 0)
                }
            }
            .toast(isPresenting: $showSuccessToast) {
                AlertToast(
                    type: .systemImage("checkmark", .accentColor),
                    title: "Fréquentations téléchargées"
                )
            }
            .toast(isPresenting: $showErrorToast) {
                AlertToast(
                    type: .systemImage("x.square.fill", .accentColor),
                    title: lastError?.message ?? "Erreur de téléchargement"
                )
            }
            .task {
                await viewModel.fetchFrekPlaces()
            }
            .onAppear {
                if DeviceMeta().idiom != .phone {
                    selectedId = favorites.first?.id ?? other.first?.id
                }
            }
            #else
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Settings") {}
                }
            }
            .task {
                await viewModel.fetchFrekPlaces()
            }
            #endif
        }
    }
}

extension View {
    public func frekListStyle() -> some View  {
        #if os(watchOS)
            self.listStyle(.carousel)
        #else
        self.listStyle(.insetGrouped)
        #endif
    }
}

struct FrekPlaceList_Previews: PreviewProvider {
    static var previews: some View {
        FrekPlaceList()
    }
}
