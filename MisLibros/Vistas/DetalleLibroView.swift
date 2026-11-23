import SwiftUI
import SwiftData

struct DetalleLibroView: View {
    // UPDATE: @Bindable permite usar $libro con un objeto @Model.
    // Cada cambio se escribe directo en el libro guardado: no hay botón Guardar.
    @Bindable var libro: Libro

    var body: some View {
        Form {
            Section("Datos") {
                TextField("Título", text: $libro.titulo)
                TextField("Autor", text: $libro.autor)
                Stepper("Páginas: \(libro.paginas)", value: $libro.paginas, in: 1...5000, step: 10)
            }
            Section {
                Toggle("Leído", isOn: $libro.leido)
            }
            Section {
                LabeledContent("Registrado", value: libro.fechaRegistro.formatted(date: .abbreviated, time: .shortened))
            }
        }
        .navigationTitle(libro.titulo)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        DetalleLibroView(libro: Libro(titulo: "El principito", autor: "Antoine de Saint-Exupéry", paginas: 96))
    }
    .modelContainer(contenedorDePrueba)
}
