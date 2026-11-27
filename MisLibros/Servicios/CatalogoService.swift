import Foundation

// Errores que puede devolver el catálogo.
// LocalizedError permite mostrar un mensaje claro con error.localizedDescription.
enum ErrorCatalogo: LocalizedError {
    case sinConexion
    case noEncontrado

    var errorDescription: String? {
        switch self {
        case .sinConexion:  "No se pudo conectar con el catálogo. Inténtalo de nuevo."
        case .noEncontrado: "No se encontró información de este libro."
        }
    }
}

// Servicio SIMULADO: se comporta como un servidor lento, pero funciona sin internet.
// En el Tema 9 se reemplaza por uno que llama a la API real de Open Library.
//
// Sus funciones son `async`: mientras "esperan al servidor" no bloquean la pantalla.
// Son `throws`: pueden fallar, y quien las llama debe usar `try`.
struct CatalogoService {

    // Búsqueda: tarda 2 segundos.
    func buscar(_ texto: String, simularErrores: Bool) async throws -> [LibroCatalogo] {
        try await Task.sleep(for: .seconds(2))     // "esperando al servidor"

        if simularErrores && Bool.random() {       // falla la mitad de las veces
            throw ErrorCatalogo.sinConexion
        }

        let busqueda = texto.trimmingCharacters(in: .whitespaces)
        guard !busqueda.isEmpty else { return Self.libros }

        // localizedStandardContains ignora mayúsculas y tildes: "garcia" encuentra "García".
        return Self.libros.filter {
            $0.titulo.localizedStandardContains(busqueda) ||
            $0.autor.localizedStandardContains(busqueda)
        }
    }

    // Sinopsis: tarda 1,5 segundos.
    func sinopsis(de libro: LibroCatalogo) async throws -> String {
        try await Task.sleep(for: .seconds(1.5))
        guard let texto = Self.sinopsis[libro.clave] else { throw ErrorCatalogo.noEncontrado }
        return texto
    }

    // Valoración: tarda otros 1,5 segundos.
    func valoracion(de libro: LibroCatalogo) async throws -> Double {
        try await Task.sleep(for: .seconds(1.5))
        guard let nota = Self.valoraciones[libro.clave] else { throw ErrorCatalogo.noEncontrado }
        return nota
    }
}

// MARK: - Datos simulados del "servidor"

extension CatalogoService {
    static let libros: [LibroCatalogo] = [
        LibroCatalogo(clave: "demo-01", titulo: "Cien años de soledad", autores: ["Gabriel García Márquez"], anioPublicacion: 1967, paginas: 471),
        LibroCatalogo(clave: "demo-02", titulo: "La ciudad y los perros", autores: ["Mario Vargas Llosa"], anioPublicacion: 1963, paginas: 408),
        LibroCatalogo(clave: "demo-03", titulo: "Los ríos profundos", autores: ["José María Arguedas"], anioPublicacion: 1958, paginas: 256),
        LibroCatalogo(clave: "demo-04", titulo: "Conversación en La Catedral", autores: ["Mario Vargas Llosa"], anioPublicacion: 1969, paginas: 729),
        LibroCatalogo(clave: "demo-05", titulo: "Pedro Páramo", autores: ["Juan Rulfo"], anioPublicacion: 1955, paginas: 124),
        LibroCatalogo(clave: "demo-06", titulo: "Rayuela", autores: ["Julio Cortázar"], anioPublicacion: 1963, paginas: 600),
        LibroCatalogo(clave: "demo-07", titulo: "Ficciones", autores: ["Jorge Luis Borges"], anioPublicacion: 1944, paginas: 224),
        LibroCatalogo(clave: "demo-08", titulo: "La casa de los espíritus", autores: ["Isabel Allende"], anioPublicacion: 1982, paginas: 448),
        LibroCatalogo(clave: "demo-09", titulo: "El túnel", autores: ["Ernesto Sabato"], anioPublicacion: 1948, paginas: 160),
        LibroCatalogo(clave: "demo-10", titulo: "Crónica de una muerte anunciada", autores: ["Gabriel García Márquez"], anioPublicacion: 1981, paginas: 122),
        LibroCatalogo(clave: "demo-11", titulo: "Tradiciones peruanas", autores: ["Ricardo Palma"], anioPublicacion: 1872, paginas: 320),
        LibroCatalogo(clave: "demo-12", titulo: "El principito", autores: ["Antoine de Saint-Exupéry"], anioPublicacion: 1943, paginas: 96)
    ]

    static let sinopsis: [String: String] = [
        "demo-01": "La historia de la familia Buendía a lo largo de siete generaciones en el pueblo de Macondo.",
        "demo-02": "Un grupo de cadetes del Colegio Militar Leoncio Prado de Lima enfrenta la violencia y el código de silencio.",
        "demo-03": "Ernesto, un adolescente entre el mundo andino y el mundo criollo, recorre el Perú junto a su padre.",
        "demo-04": "Dos hombres conversan en un bar de Lima y se preguntan en qué momento se jodió el Perú.",
        "demo-05": "Juan Preciado viaja a Comala para buscar a su padre y encuentra un pueblo habitado por voces.",
        "demo-06": "Una novela que se puede leer en más de un orden, entre París y Buenos Aires.",
        "demo-07": "Cuentos sobre laberintos, bibliotecas infinitas, espejos y mundos imaginarios.",
        "demo-08": "La saga de la familia Trueba a lo largo de cuatro generaciones en un país sudamericano.",
        "demo-09": "El pintor Juan Pablo Castel cuenta desde la cárcel su obsesión por María Iribarne.",
        "demo-10": "La reconstrucción de un crimen que todo el pueblo sabía que iba a ocurrir.",
        "demo-11": "Relatos breves y llenos de humor sobre la historia del Perú, desde el Virreinato hasta la República.",
        "demo-12": "Un aviador perdido en el desierto conoce a un pequeño príncipe que viene de otro planeta."
    ]

    // Valoraciones SIMULADAS (no son datos reales).
    static let valoraciones: [String: Double] = [
        "demo-01": 4.6, "demo-02": 4.3, "demo-03": 4.4, "demo-04": 4.5,
        "demo-05": 4.2, "demo-06": 4.1, "demo-07": 4.5, "demo-08": 4.3,
        "demo-09": 4.0, "demo-10": 4.2, "demo-11": 4.0, "demo-12": 4.7
    ]
}
