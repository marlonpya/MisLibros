import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            BibliotecaView()
                .tabItem {
                    Label("Biblioteca", systemImage: "books.vertical")
                }
            CatalogoView()
                .tabItem {
                    Label("Catálogo", systemImage: "magnifyingglass")
                }
            AjustesView()
                .tabItem {
                    Label("Ajustes", systemImage: "gearshape")
                }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(contenedorDePrueba)
}
