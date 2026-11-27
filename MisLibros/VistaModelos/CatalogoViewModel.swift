import Foundation
import Observation

// Los posibles estados de una carga. La vista hace un `switch` y dibuja cada uno.
enum EstadoCarga<Valor> {
    case cargando
    case listo(Valor)
    case vacio
    case error(String)
}

// ViewModel del catálogo (MVVM, Clase 5):
//   Vista → ViewModel → Servicio
// La vista solo dibuja; el ViewModel llama al servicio y maneja los errores.
//
// @MainActor: todo lo que cambia la pantalla debe ocurrir en el hilo principal.
// Como `estado` actualiza la UI, el ViewModel completo vive en el MainActor.
@Observable
@MainActor
final class CatalogoViewModel {
    private(set) var estado: EstadoCarga<[LibroCatalogo]> = .cargando
    private let servicio = CatalogoService()

    func buscar(_ texto: String, simularErrores: Bool) async {
        estado = .cargando
        do {
            // Pequeña pausa: si el usuario sigue escribiendo, esta búsqueda se cancela
            // antes de llamar al servicio (la vista usa .task(id:)).
            try await Task.sleep(for: .milliseconds(400))

            let resultados = try await servicio.buscar(texto, simularErrores: simularErrores)
            estado = resultados.isEmpty ? .vacio : .listo(resultados)
        } catch is CancellationError {
            // La búsqueda fue reemplazada por otra más nueva: no es un error para el usuario.
        } catch {
            estado = .error(error.localizedDescription)
        }
    }
}

// ViewModel del detalle: carga la sinopsis y la valoración AL MISMO TIEMPO.
@Observable
@MainActor
final class DetalleCatalogoViewModel {
    private(set) var estado: EstadoCarga<DetalleCatalogo> = .cargando
    private let servicio = CatalogoService()

    func cargar(_ libro: LibroCatalogo) async {
        estado = .cargando
        let reloj = ContinuousClock()
        let inicio = reloj.now
        do {
            // async let: las dos llamadas empiezan YA y corren en paralelo.
            async let sinopsis = servicio.sinopsis(de: libro)
            async let valoracion = servicio.valoracion(de: libro)

            // Aquí se espera a las dos: tarda ~1,5 s en total, no 3 s.
            let detalle = try await (sinopsis, valoracion)

            // Versión SIN paralelo, para comparar en clase (~3 s):
            // let s = try await servicio.sinopsis(de: libro)
            // let v = try await servicio.valoracion(de: libro)

            let duracion = reloj.now - inicio
            let segundos = Double(duracion.components.seconds)
                + Double(duracion.components.attoseconds) / 1e18
            estado = .listo(DetalleCatalogo(sinopsis: detalle.0, valoracion: detalle.1, segundos: segundos))
        } catch is CancellationError {
            // El usuario salió de la pantalla antes de que terminara.
        } catch {
            estado = .error(error.localizedDescription)
        }
    }
}
