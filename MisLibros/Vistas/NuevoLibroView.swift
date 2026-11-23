import SwiftUI
import SwiftData

struct NuevoLibroView: View {
    @Environment(\.modelContext) private var contexto
    @Environment(\.dismiss) private var dismiss

    // Borrador del formulario: aún no está en la base de datos.
    @State private var titulo = ""
    @State private var autor = ""
    @State private var paginas = ""
    @State private var mensajeError = ""
    @State private var mostrarAlerta = false

    var body: some View {
        Form {
            TextField("Título", text: $titulo)
            TextField("Autor", text: $autor)
            TextField("Número de páginas", text: $paginas)
                .keyboardType(.numberPad)
        }
        .navigationTitle("Nuevo libro")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Guardar", action: guardar)
            }
        }
        .alert("Datos incorrectos", isPresented: $mostrarAlerta) {
            Button("Aceptar", role: .cancel) { }
        } message: {
            Text(mensajeError)
        }
    }

    // Devuelve el primer error encontrado, o nil si todo es válido.
    private func validar() -> String? {
        let tituloLimpio = titulo.trimmingCharacters(in: .whitespaces)
        if tituloLimpio.isEmpty { return "Ingrese el título del libro." }
        if autor.trimmingCharacters(in: .whitespaces).isEmpty { return "Ingrese el autor del libro." }
        guard let numero = Int(paginas), numero > 0 else {
            return "Las páginas deben ser un número mayor que 0."
        }
        return nil
    }

    private func guardar() {
        if let error = validar() {
            mensajeError = error
            mostrarAlerta = true
            return
        }
        guard let numero = Int(paginas) else { return }

        // CREATE: insertar en el contexto. SwiftData guarda solo (autosave).
        let libro = Libro(titulo: titulo.trimmingCharacters(in: .whitespaces),
                          autor: autor.trimmingCharacters(in: .whitespaces),
                          paginas: numero)
        contexto.insert(libro)
        dismiss()
    }
}

#Preview {
    NavigationStack {
        NuevoLibroView()
    }
    .modelContainer(contenedorDePrueba)
}
