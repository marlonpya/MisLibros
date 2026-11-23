import SwiftUI
import SwiftData

@main
struct MisLibrosApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        // Crea la base de datos de Libro y la comparte con todas las vistas.
        // Sin esta línea, @Query y modelContext no funcionan.
        .modelContainer(for: Libro.self)
    }
}
