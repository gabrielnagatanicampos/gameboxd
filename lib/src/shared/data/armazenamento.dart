// Armazenamento chave/valor simples, SEM plugins (não exige Modo Desenvolvedor).
// No navegador usa o localStorage (dados sobrevivem ao F5); nos testes e fora
// da web usa um mapa em memória.
export 'armazenamento_memoria.dart' if (dart.library.js_interop) 'armazenamento_web.dart';
