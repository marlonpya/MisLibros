# Mis Libros: persistencia con SwiftData

[![Compilar](https://github.com/marlonpya/MisLibros/actions/workflows/compilar.yml/badge.svg)](https://github.com/marlonpya/MisLibros/actions/workflows/compilar.yml)

Proyecto de la **Clase 6** del curso *Desarrollo de Aplicaciones Móviles II* (CIBERTEC): **Tema 6, persistencia local con SwiftData**.

Una biblioteca personal: registras tus libros, los marcas como leídos y **siguen ahí al cerrar y volver a abrir la app**.

## Cómo abrirlo

1. Descarga el repositorio: botón verde **Code → Download ZIP** (o `git clone https://github.com/marlonpya/MisLibros.git`).
2. Abre `MisLibros.xcodeproj` con **Xcode 16 o posterior** (destino iOS 17).
3. Elige un simulador de iPhone y presiona **⌘R**.
4. Prueba la persistencia: agrega un libro, **detén la app desde Xcode (⌘.)** y vuelve a ejecutarla. El libro sigue ahí.

## Qué aprende cada archivo

| Archivo | Tema | Qué mirar |
|---|---|---|
| `MisLibrosApp.swift` | 2.2.2 | `.modelContainer(for: Libro.self)` crea la base de datos |
| `Modelo/Libro.swift` | 2.2.2 | `@Model` convierte la clase en un modelo persistente |
| `Vistas/BibliotecaView.swift` | 2.2.2 y 2.2.3 | `@Query` (leer), `contexto.delete` (eliminar), `@AppStorage` |
| `Vistas/NuevoLibroView.swift` | 2.2.3 | `contexto.insert` (crear) con validaciones y alerta |
| `Vistas/DetalleLibroView.swift` | 2.2.3 | `@Bindable` para editar un `@Model` sin botón Guardar |
| `Vistas/AjustesView.swift` | 2.2.1 | `@AppStorage` para preferencias simples |
| `Modelo/ContenedorDePrueba.swift` | — | Base de datos en memoria solo para los `#Preview` |

## CRUD con SwiftData

| Operación | Código |
|---|---|
| Crear | `contexto.insert(libro)` |
| Leer | `@Query(sort: \Libro.titulo) var libros: [Libro]` |
| Actualizar | `@Bindable var libro` y `$libro.titulo` (se guarda solo) |
| Eliminar | `contexto.delete(libro)` |

SwiftData guarda automáticamente (*autosave*); no hace falta llamar a `save()`.

## ¿@AppStorage o SwiftData?

| Uso | Herramienta |
|---|---|
| Un valor simple: nombre, interruptor, preferencia | `@AppStorage` |
| Una lista de objetos que se crean, editan y eliminan | SwiftData |

## Retos

1. Agrega una propiedad `calificacion: Int` (1 a 5) al modelo y muéstrala con estrellas.
2. Ordena la lista por autor o por título según una preferencia guardada con `@AppStorage`.
3. Agrega un buscador (`.searchable`) que filtre por título o autor.
