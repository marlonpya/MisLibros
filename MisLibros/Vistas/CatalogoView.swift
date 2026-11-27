import SwiftUI

struct CatalogoView: View {
    // La vista es dueña de su ViewModel: @State lo crea una sola vez.
    @State private var viewModel = CatalogoViewModel()
    @State private var texto = ""
    @AppStorage("simularErrores") private var simularErrores = false

    var body: some View {
        NavigationStack {
            contenido
                .navigationTitle("Catálogo")
                .navigationDestination(for: LibroCatalogo.self) { libro in
                    DetalleCatalogoView(libro: libro)
                }
                .searchable(text: $texto, prompt: "Título o autor")
                // .task(id:) se ejecuta al aparecer la vista y CADA VEZ que cambia `texto`.
                // Si cambia antes de terminar, SwiftUI cancela la búsqueda anterior.
                // Al salir de la pantalla, también se cancela sola.
                .task(id: texto) {
                    await viewModel.buscar(texto, simularErrores: simularErrores)
                }
        }
    }

    // Un `switch` sobre el estado: cada caso dibuja una pantalla distinta.
    @ViewBuilder
    private var contenido: some View {
        switch viewModel.estado {
        case .cargando:
            ProgressView("Buscando en el catálogo…")

        case .listo(let libros):
            List(libros) { libro in
                NavigationLink(value: libro) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(libro.titulo).font(.headline)
                        Text("\(libro.autor) · \(String(libro.anioPublicacion))")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }

        case .vacio:
            ContentUnavailableView.search(text: texto)

        case .error(let mensaje):
            ContentUnavailableView {
                Label("Sin conexión", systemImage: "wifi.exclamationmark")
            } description: {
                Text(mensaje)
            } actions: {
                Button("Reintentar") {
                    // Task { } crea una tarea async desde un botón (que no es async).
                    Task {
                        await viewModel.buscar(texto, simularErrores: simularErrores)
                    }
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
}

#Preview {
    CatalogoView()
        .modelContainer(contenedorDePrueba)
}
