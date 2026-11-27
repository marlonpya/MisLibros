import Foundation

// DTO (Data Transfer Object): el libro tal como lo entrega el "servidor".
// Es un STRUCT porque solo transporta datos: no se guarda ni se edita.
// Si el usuario lo agrega a su biblioteca, se convierte en un @Model Libro.
//
// Los campos imitan a la API de Open Library (Tema 9):
//   key → clave, title → titulo, author_name → autores,
//   first_publish_year → anioPublicacion, number_of_pages_median → paginas
struct LibroCatalogo: Identifiable, Hashable, Codable {
    let clave: String
    let titulo: String
    let autores: [String]
    let anioPublicacion: Int
    let paginas: Int

    var id: String { clave }
    var autor: String { autores.joined(separator: ", ") }
}

// Lo que trae la pantalla de detalle: llega en DOS llamadas distintas.
struct DetalleCatalogo {
    let sinopsis: String
    let valoracion: Double
    let segundos: Double   // cuánto tardó la carga, para comparar con y sin async let
}

extension LibroCatalogo {
    // Convierte el DTO en el modelo de SwiftData (Clase 6).
    func comoLibro() -> Libro {
        Libro(titulo: titulo, autor: autor, paginas: paginas)
    }
}
