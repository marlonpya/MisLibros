import SwiftUI

struct FilaLibro: View {
    // Solo muestra datos: basta con let.
    let libro: Libro

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: libro.leido ? "book.closed.fill" : "book")
                .font(.title2)
                .foregroundStyle(libro.leido ? .green : .orange)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(libro.titulo)
                    .font(.headline)
                Text("\(libro.autor) · \(libro.paginas) págs.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
