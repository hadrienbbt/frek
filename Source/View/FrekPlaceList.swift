import SwiftUI
#if os(iOS)
import AlertToast
#endif

struct FrekPlaceList: View {
    
    @ObservedObject var viewModel = FrekPlaceListViewModel()
    @State private var selectedId: String? = nil
    @State private var isLocal: Bool = true
    @State private var showToast = false

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
        let favorites = viewModel.favorites
        let other = viewModel.sortedFrekPlaces.filter { !$0.favorite }
        
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
                            self.viewModel.dataProvider = setLocal ? LocalStore() : WebFetcher()
                            self.viewModel.fetchFrekPlaces {
                                self.showToast = true
                            }
                        }
                    } label: {
                        Label("Options", systemImage: "ellipsis.circle")
                    }.opacity(DeviceMeta().isTest ? 1 : 0)
                }
            }
            .toast(isPresenting: $showToast) {
                AlertToast(
                    type: .systemImage("checkmark", .accentColor),
                    title: "Fréquentations téléchargées"
                )
            }
            .onAppear {
                viewModel.fetchFrekPlaces()
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
            .onAppear {
                viewModel.fetchFrekPlaces()
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
