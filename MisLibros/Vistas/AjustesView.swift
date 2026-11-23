import SwiftUI

struct AjustesView: View {
    // Mismas claves que en BibliotecaView: leen y escriben el mismo valor guardado.
    @AppStorage("nombreLector") private var nombreLector = ""
    @AppStorage("soloPendientes") private var soloPendientes = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Lector") {
                    TextField("Tu nombre", text: $nombreLector)
                }
                Section {
                    Toggle("Mostrar solo pendientes", isOn: $soloPendientes)
                } footer: {
                    Text("Estos ajustes se guardan con @AppStorage y se conservan al cerrar la app.")
                }
            }
            .navigationTitle("Ajustes")
        }
    }
}

#Preview {
    AjustesView()
}
