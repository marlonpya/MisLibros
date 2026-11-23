import SwiftData

// Base de datos en memoria SOLO para los #Preview:
// no toca los datos reales de la app y empieza con libros de ejemplo.
@MainActor
let contenedorDePrueba: ModelContainer = {
    do {
        let configuracion = ModelConfiguration(isStoredInMemoryOnly: true)
        let contenedor = try ModelContainer(for: Libro.self, configurations: configuracion)
        for libro in Libro.ejemplos() {
            contenedor.mainContext.insert(libro)
        }
        return contenedor
    } catch {
        fatalError("No se pudo crear el contenedor de prueba: \(error)")
    }
}()
