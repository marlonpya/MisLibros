import Foundation
import SwiftData

// @Model convierte la clase en un modelo de SwiftData:
// sus propiedades se guardan en el dispositivo y la clase se vuelve observable.
// Es una clase (no struct) porque SwiftData necesita referencias.
@Model
final class Libro {
    var titulo: String
    var autor: String
    var paginas: Int
    var leido: Bool
    var fechaRegistro: Date

    init(titulo: String, autor: String, paginas: Int, leido: Bool = false) {
        self.titulo = titulo
        self.autor = autor
        self.paginas = paginas
        self.leido = leido
        self.fechaRegistro = .now
    }
}

extension Libro {
    // Función (no constante): cada llamada crea objetos nuevos,
    // porque un mismo objeto @Model no puede insertarse dos veces.
    static func ejemplos() -> [Libro] {
        [
            Libro(titulo: "Cien años de soledad", autor: "Gabriel García Márquez", paginas: 471, leido: true),
            Libro(titulo: "La ciudad y los perros", autor: "Mario Vargas Llosa", paginas: 408),
            Libro(titulo: "Los ríos profundos", autor: "José María Arguedas", paginas: 256),
            Libro(titulo: "El principito", autor: "Antoine de Saint-Exupéry", paginas: 96, leido: true)
        ]
    }
}
