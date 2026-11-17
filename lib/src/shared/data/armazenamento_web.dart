import 'dart:js_interop';

@JS('localStorage')
external _Storage get _localStorage;

extension type _Storage._(JSObject _) implements JSObject {
  external JSString? getItem(JSString key);
  external void setItem(JSString key, JSString value);
}

/// Lê do localStorage do navegador (`null` se não existir ou estiver bloqueado).
String? lerArmazenado(String chave) {
  try {
    return _localStorage.getItem(chave.toJS)?.toDart;
  } catch (_) {
    return null;
  }
}

/// Grava no localStorage (ignora erros, ex.: navegação anônima bloqueada).
void gravarArmazenado(String chave, String valor) {
  try {
    _localStorage.setItem(chave.toJS, valor.toJS);
  } catch (_) {}
}
