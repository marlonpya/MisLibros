import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            BibliotecaView()
                .tabItem {
                    Label("Biblioteca", systemImage: "books.vertical")
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
