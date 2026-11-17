/// Mapa em memória (testes e plataformas sem navegador). Os dados se perdem ao fechar o app.
final Map<String, String> armazenamentoMemoria = {};

String? lerArmazenado(String chave) => armazenamentoMemoria[chave];

void gravarArmazenado(String chave, String valor) {
  armazenamentoMemoria[chave] = valor;
}
