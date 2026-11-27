# Mis Libros: SwiftData y async/await

[![Compilar](https://github.com/marlonpya/MisLibros/actions/workflows/compilar.yml/badge.svg?branch=clase7)](https://github.com/marlonpya/MisLibros/actions/workflows/compilar.yml?query=branch%3Aclase7)

Proyecto del curso *Desarrollo de Aplicaciones Móviles II* (CIBERTEC).

| Rama | Clase | Tema |
|---|---|---|
| `main` | Clase 6 | Persistencia local con SwiftData |
| **`clase7`** (esta) | **Clase 7** | **Concurrencia con async/await** |

Una biblioteca personal: registras tus libros, los marcas como leídos y **siguen ahí al cerrar y volver a abrir la app**. En la Clase 7 se agrega la pestaña **Catálogo**: un "servidor" que tarda en responder, donde buscas libros y los agregas a tu biblioteca **sin que la app se congele**.

> **Funciona sin internet.** El catálogo es simulado dentro de la app. Descarga el proyecto **antes de la clase**; si el día de la clase no lo tienes, pídeselo a un compañero por AirDrop o USB. En el Tema 9 el catálogo se conecta a la API real de Open Library.

## Cómo abrirlo

1. Descarga la rama **`clase7`**:
   - En GitHub, cambia de `main` a **`clase7`** en el selector de ramas y luego **Code → Download ZIP**.
   - O con git: `git clone -b clase7 https://github.com/marlonpya/MisLibros.git`
   - Si ya tenías el proyecto de la Clase 6: `git fetch` y `git switch clase7`.
2. Abre `MisLibros.xcodeproj` con **Xcode 16 o posterior**.
3. Elige un simulador con **iOS 17 o superior** y presiona **⌘R**.
4. Deberías ver tres pestañas: **Biblioteca**, **Catálogo** y **Ajustes**.

## Clase 7: concurrencia con async/await

### Objetivo

Cargar datos lentos **sin congelar la pantalla**, mostrar estados de carga y error, y organizar ese código con **MVVM y una capa de servicio**.

### Arquitectura del catálogo

MVVM de la Clase 5 más una capa de servicio:

```
CatalogoView  ──►  CatalogoViewModel  ──►  CatalogoService
  (dibuja)          (@MainActor, estado)     (async throws, simulado)
```

- La **vista** solo dibuja el estado con un `switch`; no tiene `do/catch` ni `Task.sleep`.
- El **ViewModel** llama al servicio, maneja errores y cancelación.
- El **servicio** trae los datos. Hoy es simulado; en el Tema 9 se reemplaza por Open Library sin tocar la vista.

### Archivos nuevos y modificados

```
MisLibros/
├─ Modelo/
│  └─ LibroCatalogo.swift         NUEVO · struct DTO del "servidor"
├─ Servicios/
│  └─ CatalogoService.swift       NUEVO · async throws, Task.sleep, falla simulada
├─ VistaModelos/
│  └─ CatalogoViewModel.swift     NUEVO · @Observable @MainActor, EstadoCarga
└─ Vistas/
   ├─ CatalogoView.swift          NUEVO · lista, búsqueda, Reintentar
   ├─ DetalleCatalogoView.swift   NUEVO · async let, "Agregar a mi biblioteca"
   ├─ ContentView.swift           + pestaña Catálogo
   └─ AjustesView.swift           + "Simular errores" y demo Congelar / Esperar
```

| Archivo | Concepto | Qué mirar |
|---|---|---|
| `Vistas/AjustesView.swift` | El problema | Demo **Congelar 3 s** (`Thread.sleep`) frente a **Esperar 3 s** (`await`): mira el reloj |
| `Servicios/CatalogoService.swift` | `async` / `throws` | `Task.sleep` simula al servidor; `throw ErrorCatalogo.sinConexion` simula una falla |
| `Modelo/LibroCatalogo.swift` | DTO | `struct` que trae el servidor; `comoLibro()` lo convierte en `@Model Libro` |
| `VistaModelos/CatalogoViewModel.swift` | `@MainActor`, estados | `enum EstadoCarga` y `do / try await / catch`; se ignora `CancellationError` |
| `Vistas/CatalogoView.swift` | `.task(id:)`, `Task { }` | La búsqueda se cancela sola si sigues escribiendo; botón **Reintentar** |
| `Vistas/DetalleCatalogoView.swift` | `async let` | Sinopsis y valoración **en paralelo**: ~1,5 s en vez de 3 s (se muestra el tiempo) |

### Resumen de conceptos

| Concepto | Código | Para qué |
|---|---|---|
| Función asíncrona | `func buscar() async throws -> [LibroCatalogo]` | Puede esperar sin bloquear y puede fallar |
| Esperar | `let libros = try await servicio.buscar(texto)` | Pausa la tarea hasta tener el resultado |
| Errores | `do { … } catch { … }` | Decide qué mostrar si algo falla |
| Tarea desde un botón | `Task { await viewModel.buscar(texto) }` | Llamar código async desde código normal |
| Tarea al aparecer | `.task { … }` / `.task(id: texto) { … }` | Se cancela sola al salir o al cambiar el valor |
| Hilo principal | `@MainActor` | La pantalla solo se actualiza en el hilo principal |
| En paralelo | `async let a = …` y `try await (a, b)` | Dos llamadas independientes al mismo tiempo |
| Estados | `enum EstadoCarga { cargando, listo, vacio, error }` | Un `switch` dibuja cada caso |

### Pruébalo

1. Pestaña **Ajustes** → toca **Congelar 3 s** e intenta mover un interruptor. Luego toca **Esperar 3 s**.
2. Pestaña **Catálogo** → espera la carga. Busca `garcia` (sin tilde): encuentra a García Márquez.
3. Escribe rápido: solo se completa la última búsqueda.
4. Busca `xyz`: aparece el estado **vacío**.
5. Entra a un libro → mira el **tiempo de carga**. Luego, en `CatalogoViewModel.swift`, cambia a la versión sin paralelo (comentada) y compara.
6. Toca **Agregar a mi biblioteca** y ve a la pestaña **Biblioteca**.
7. Activa **Simular errores** en Ajustes y busca de nuevo hasta ver el botón **Reintentar**.

### Retos

1. **Básico (obligatorio en clase):** agrega *pull to refresh* al catálogo con `.refreshable { await viewModel.buscar(texto, simularErrores: simularErrores) }`.
2. **Intermedio:** muestra un botón **Cancelar** mientras carga. Pista: guarda la búsqueda en `var tarea: Task<Void, Never>?` y llama `tarea?.cancel()`.
3. **Avanzado:** agrega `func portada(de:) async throws -> String` (un emoji) al servicio y carga las portadas de los 3 primeros libros **en paralelo** con `async let`.

**Evidencia:** captura o video corto del reto funcionando.

### Errores comunes

| Mensaje o síntoma | Causa | Solución |
|---|---|---|
| *'async' call in a function that does not support concurrency* | `await` dentro de un botón o de una función normal | Envuélvelo en `Task { }` o marca la función `async` |
| *Call can throw but is not marked with 'try'* | Falta `try` antes de `await` | Escribe `try await` dentro de `do / catch` |
| Advertencia de MainActor al cambiar el estado | Se cambia la UI fuera del hilo principal | `@MainActor` en el ViewModel |
| Aparece un error al escribir rápido | No se ignora `CancellationError` | `catch is CancellationError { }` |
| La carga sigue después de salir de la pantalla | `onAppear` con un `Task` adentro | Usa `.task`, que se cancela sola |

### Preguntas de repaso

1. ¿Qué pasa si usas `Thread.sleep` en un botón?
2. ¿Dónde puedes escribir `await`?
3. ¿Qué ventaja tiene `.task` frente a `onAppear` con un `Task`?
4. Dos llamadas de 2 s con `async let`: ¿cuánto tardan en total?
5. ¿Por qué el ViewModel lleva `@MainActor`?

### Lo que viene

En el **Tema 9** se crea `protocol CatalogoServicio` con dos implementaciones: la simulada de esta clase y una que llama a la API de **Open Library** con `URLSession` y `Codable`. El ViewModel y las vistas no cambian.

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
