import SwiftUI
import SwiftData

struct BibliotecaView: View {
    // READ: @Query lee los libros guardados y se actualiza sola
    // cuando se agrega, edita o elimina un libro.
    @Query(sort: \Libro.titulo) private var libros: [Libro]

    // ModelContext: el "puente" para insertar y eliminar en la base de datos.
    @Environment(\.modelContext) private var contexto

    // @AppStorage: preferencias simples guardadas en UserDefaults.
    @AppStorage("nombreLector") private var nombreLector = ""
    @AppStorage("soloPendientes") private var soloPendientes = false

    // El filtro se aplica en memoria sobre lo que trae @Query.
    private var librosVisibles: [Libro] {
        soloPendientes ? libros.filter { !$0.leido } : libros
    }

    private var titulo: String {
        nombreLector.isEmpty ? "Mis libros" : "Libros de \(nombreLector)"
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(librosVisibles) { libro in
                        NavigationLink {
                            DetalleLibroView(libro: libro)
                        } label: {
                            FilaLibro(libro: libro)
                        }
                        .swipeActions {
                            // DELETE: se elimina el objeto, no una posición de la lista.
                            Button("Eliminar", systemImage: "trash", role: .destructive) {
                                contexto.delete(libro)
                            }
                        }
                    }
                } header: {
                    Text("Leídos: \(libros.filter(\.leido).count) de \(libros.count)")
                }
            }
            .navigationTitle(titulo)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        NuevoLibroView()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .overlay {
                if libros.isEmpty {
                    ContentUnavailableView {
                        Label("Sin libros", systemImage: "books.vertical")
                    } description: {
                        Text("Agrega tu primer libro con el botón +.")
                    } actions: {
                        Button("Cargar ejemplos", action: cargarEjemplos)
                    }
                } else if librosVisibles.isEmpty {
                    ContentUnavailableView("¡Todo leído!", systemImage: "checkmark.seal",
                                           description: Text("No tienes libros pendientes."))
                }
            }
        }
    }

    private func cargarEjemplos() {
        for libro in Libro.ejemplos() {
            contexto.insert(libro)
        }
    }
}

#Preview {
    BibliotecaView()
        .modelContainer(contenedorDePrueba)
}
