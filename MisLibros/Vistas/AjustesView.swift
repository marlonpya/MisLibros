import SwiftUI

struct AjustesView: View {
    // Mismas claves que en BibliotecaView: leen y escriben el mismo valor guardado.
    @AppStorage("nombreLector") private var nombreLector = ""
    @AppStorage("soloPendientes") private var soloPendientes = false
    // Lo lee CatalogoView para que el servicio falle a propósito.
    @AppStorage("simularErrores") private var simularErrores = false

    @State private var esperando = false

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

                Section {
                    Toggle("Simular errores en el catálogo", isOn: $simularErrores)
                } header: {
                    Text("Catálogo")
                } footer: {
                    Text("Con esta opción, la búsqueda falla la mitad de las veces para probar el botón Reintentar.")
                }

                demoConcurrencia
            }
            .navigationTitle("Ajustes")
        }
    }

    // Demo de clase: la misma espera de 3 s, bloqueando y sin bloquear.
    private var demoConcurrencia: some View {
        Section {
            // El reloj se actualiza 10 veces por segundo: si se detiene, la app está congelada.
            TimelineView(.periodic(from: .now, by: 0.1)) { contexto in
                LabeledContent("Reloj", value: contexto.date.formatted(.dateTime.hour().minute().second()))
                    .monospacedDigit()
            }

            Button("Congelar 3 s (Thread.sleep)", systemImage: "snowflake", role: .destructive) {
                // ❌ MAL: duerme el hilo principal. Nada responde durante 3 segundos.
                Thread.sleep(forTimeInterval: 3)
            }

            Button("Esperar 3 s (await)", systemImage: "hourglass") {
                // ✅ BIEN: la tarea espera, pero la pantalla sigue respondiendo.
                Task {
                    esperando = true
                    try? await Task.sleep(for: .seconds(3))
                    esperando = false
                }
            }
            .disabled(esperando)

            if esperando {
                Text("Esperando… intenta mover el interruptor de arriba.")
                    .foregroundStyle(.secondary)
            }
        } header: {
            Text("Demo: ¿por qué async/await?")
        } footer: {
            Text("Toca cada botón y mira el reloj. Con Thread.sleep el reloj se detiene; con await sigue avanzando.")
        }
    }
}

#Preview {
    AjustesView()
}
