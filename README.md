# Mis Libros: SwiftData y async/await

[![Compilar](https://github.com/marlonpya/MisLibros/actions/workflows/compilar.yml/badge.svg)](https://github.com/marlonpya/MisLibros/actions/workflows/compilar.yml)

Proyecto del curso *Desarrollo de Aplicaciones Móviles II* (CIBERTEC).

| Rama | Clase | Tema |
|---|---|---|
| `main` | Clase 6 | Persistencia local con SwiftData |
| **`clase7`** (esta) | **Clase 7** | **Concurrencia con async/await** |

Una biblioteca personal: registras tus libros, los marcas como leídos y **siguen ahí al cerrar y volver a abrir la app**. En la Clase 7 se agrega la pestaña **Catálogo**: un "servidor" que tarda en responder, donde buscas libros y los agregas a tu biblioteca **sin que la app se congele**.

> El catálogo es **simulado**: funciona sin internet. En el Tema 9 se cambia por la API real de Open Library.

## Cómo abrirlo

1. Descarga el repositorio:
   - **Clase 7:** elige la rama **`clase7`** en GitHub y luego **Code → Download ZIP**, o `git clone -b clase7 https://github.com/marlonpya/MisLibros.git`.
   - **Clase 6:** la rama `main`.
2. Abre `MisLibros.xcodeproj` con **Xcode 16 o posterior** (destino iOS 17).
3. Elige un simulador de iPhone y presiona **⌘R**.
4. Prueba la persistencia: agrega un libro, **detén la app desde Xcode (⌘.)** y vuelve a ejecutarla. El libro sigue ahí.

## Clase 7: qué se agregó

Arquitectura del catálogo (MVVM de la Clase 5 + una capa de servicio):

```
Vista  →  ViewModel  →  Servicio
CatalogoView   CatalogoViewModel   CatalogoService (async throws)
```

| Archivo | Concepto | Qué mirar |
|---|---|---|
| `Vistas/AjustesView.swift` | El problema | Demo **"Congelar 3 s"** (`Thread.sleep`) frente a **"Esperar 3 s"** (`await`): mira el reloj |
| `Servicios/CatalogoService.swift` | `async` / `throws` | `Task.sleep` simula al servidor; `throw ErrorCatalogo.sinConexion` simula una falla |
| `Modelo/LibroCatalogo.swift` | DTO | `struct` que trae el servidor; `comoLibro()` lo convierte en `@Model Libro` |
| `VistaModelos/CatalogoViewModel.swift` | `@MainActor`, estados | `enum EstadoCarga` y `do / try await / catch`; se ignora `CancellationError` |
| `Vistas/CatalogoView.swift` | `.task(id:)`, `Task { }` | La búsqueda se cancela sola si sigues escribiendo; botón **Reintentar** |
| `Vistas/DetalleCatalogoView.swift` | `async let` | Sinopsis y valoración **en paralelo**: ~1,5 s en vez de 3 s (se muestra el tiempo) |

### Pruébalo

1. Pestaña **Ajustes** → toca **Congelar 3 s** e intenta mover un interruptor. Luego toca **Esperar 3 s**.
2. Pestaña **Catálogo** → espera la carga. Busca `garcia` (sin tilde): encuentra a García Márquez.
3. Escribe rápido: solo se completa la última búsqueda.
4. Entra a un libro → mira el **tiempo de carga**. Luego, en `CatalogoViewModel.swift`, cambia a la versión sin paralelo (comentada) y compara.
5. Toca **Agregar a mi biblioteca** y ve a la pestaña **Biblioteca**.
6. Activa **Simular errores** en Ajustes y busca de nuevo hasta ver el botón **Reintentar**.

### Retos de la Clase 7

1. **Básico:** agrega *pull to refresh* al catálogo con `.refreshable { await viewModel.buscar(...) }`.
2. **Intermedio:** muestra un botón **Cancelar** mientras carga. Pista: guarda la búsqueda en `var tarea: Task<Void, Never>?` y llama `tarea?.cancel()`.
3. **Avanzado:** agrega `func portada(de:) async throws -> String` (un emoji) al servicio y carga las portadas de los 3 primeros libros **en paralelo** con `async let`.

---

## Clase 6: SwiftData

### Qué aprende cada archivo

| Archivo | Tema | Qué mirar |
|---|---|---|
| `MisLibrosApp.swift` | 2.2.2 | `.modelContainer(for: Libro.self)` crea la base de datos |
| `Modelo/Libro.swift` | 2.2.2 | `@Model` convierte la clase en un modelo persistente |
| `Vistas/BibliotecaView.swift` | 2.2.2 y 2.2.3 | `@Query` (leer), `contexto.delete` (eliminar), `@AppStorage` |
| `Vistas/NuevoLibroView.swift` | 2.2.3 | `contexto.insert` (crear) con validaciones y alerta |
| `Vistas/DetalleLibroView.swift` | 2.2.3 | `@Bindable` para editar un `@Model` sin botón Guardar |
| `Vistas/AjustesView.swift` | 2.2.1 | `@AppStorage` para preferencias simples |
| `Modelo/ContenedorDePrueba.swift` | — | Base de datos en memoria solo para los `#Preview` |

### CRUD con SwiftData

| Operación | Código |
|---|---|
| Crear | `contexto.insert(libro)` |
| Leer | `@Query(sort: \Libro.titulo) var libros: [Libro]` |
| Actualizar | `@Bindable var libro` y `$libro.titulo` (se guarda solo) |
| Eliminar | `contexto.delete(libro)` |

SwiftData guarda automáticamente (*autosave*); no hace falta llamar a `save()`.

### ¿@AppStorage o SwiftData?

| Uso | Herramienta |
|---|---|
| Un valor simple: nombre, interruptor, preferencia | `@AppStorage` |
| Una lista de objetos que se crean, editan y eliminan | SwiftData |

### Retos de la Clase 6

1. Agrega una propiedad `calificacion: Int` (1 a 5) al modelo y muéstrala con estrellas.
2. Ordena la lista por autor o por título según una preferencia guardada con `@AppStorage`.
3. Agrega un buscador (`.searchable`) que filtre por título o autor.
