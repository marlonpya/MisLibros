import SwiftUI
import SwiftData

struct DetalleCatalogoView: View {
    let libro: LibroCatalogo

    @State private var viewModel = DetalleCatalogoViewModel()
    @Environment(\.modelContext) private var contexto
    @Query private var biblioteca: [Libro]   // para saber si ya lo agregué

    private var yaAgregado: Bool {
        biblioteca.contains { $0.titulo == libro.titulo && $0.autor == libro.autor }
    }

    var body: some View {
        List {
            Section {
                LabeledContent("Autor", value: libro.autor)
                LabeledContent("Publicado", value: String(libro.anioPublicacion))
                LabeledContent("Páginas", value: "\(libro.paginas)")
            }

            Section("Del catálogo") {
                switch viewModel.estado {
                case .cargando, .vacio:
                    HStack {
                        ProgressView()
                        Text("Cargando sinopsis y valoración…")
                            .foregroundStyle(.secondary)
                    }
                case .listo(let detalle):
                    Text(detalle.sinopsis)
                    LabeledContent("Valoración") {
                        Label(detalle.valoracion.formatted(.number.precision(.fractionLength(1))),
                              systemImage: "star.fill")
                            .foregroundStyle(.orange)
                    }
                    LabeledContent("Tiempo de carga",
                                   value: detalle.segundos.formatted(.number.precision(.fractionLength(1))) + " s")
                case .error(let mensaje):
                    Text(mensaje).foregroundStyle(.red)
                }
            }

            Section {
                Button(yaAgregado ? "Ya está en tu biblioteca" : "Agregar a mi biblioteca",
                       systemImage: yaAgregado ? "checkmark" : "plus") {
                    // El DTO (struct) se convierte en @Model y se guarda con SwiftData.
                    contexto.insert(libro.comoLibro())
                }
                .disabled(yaAgregado)
            }
        }
        .navigationTitle(libro.titulo)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.cargar(libro)
        }
    }
}

#Preview {
    NavigationStack {
        DetalleCatalogoView(libro: CatalogoService.libros[0])
    }
    .modelContainer(contenedorDePrueba)
}
