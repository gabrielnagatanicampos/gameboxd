# GameBoxd

Um diário de jogos no estilo Letterboxd, feito em **Flutter**. Você marca o que já zerou, dá uma nota de 0 a 5 estrelas, escreve um comentário e acompanha seu progresso. Projeto da faculdade (Atividade M2), desenvolvido em grupo.

## O que o app faz

- **Jogos zerados:** checklist com progresso (`2 de 4 zerados`), filtros (todos, zerados, faltam), Desfazer ao remover e sugestões ao digitar o nome do jogo.
- **Avaliação:** 5 estrelinhas com frase para cada nota, comentário de até 280 caracteres e média das notas.
- **Explorar:** busca por jogo ou estúdio e filtro por gênero, sobre um catálogo de 30 jogos.
- **Home:** progresso, seu melhor jogo e lançamentos em destaque.
- **GOTY:** vencedores de 2014 a 2025 e votação da comunidade em 5 categorias (Jogo do Ano, Direção, Narrativa, Trilha Sonora e Indie), com indicados diferentes em cada uma e 1 voto por categoria.
- Tema claro e escuro (Material 3). Os dados ficam salvos no `localStorage` do navegador.

## Tecnologias

Flutter 3 / Dart 3, Riverpod (estado), GoRouter (navegação), Material 3.

## Como rodar

```bash
flutter pub get
flutter run -d chrome
```

A primeira execução leva 1 a 2 minutos para compilar.

### Capas dos jogos

As capas são arte oficial dos jogos e **não estão neste repositório** (direitos autorais). Sem elas o app funciona e mostra um placeholder com o título. Para baixar as capas para uso local (Windows, PowerShell):

```powershell
powershell -ExecutionPolicy Bypass -File tools\baixar_capas.ps1
```

O script busca as imagens na Steam e na Wikipedia e salva em `assets/covers/`.

### Testes e análise

```bash
flutter analyze
flutter test
```

## Estrutura

```
lib/src/
├── app/        # app, rotas (GoRouter) e tema
├── shared/     # modelos (Game, Review), catálogo, armazenamento, widgets comuns
└── features/
    ├── home/
    ├── explore/
    ├── zerados/   # Jogo, ColecaoJogos, notifier e telas
    └── goty/      # edições, votação por categoria e telas
test/           # testes de modelo, notifiers e telas
tools/          # script que baixa as capas
```

## Decisões de código

- **Modelo imutável:** `Jogo` não muda; `marcarZerado()`, `alternar()` e `avaliar()` devolvem uma cópia. `avaliar` valida a nota (0 a 5) e só aceita jogo zerado.
- **Getters que calculam tudo:** `ColecaoJogos` expõe `progresso`, `percentual`, `metaBatida`, `mediaNotas` e `melhorAvaliado`, sem guardar valores duplicados.
- **Estado com Riverpod:** o `ZeradosNotifier` opera sempre por `id` (não por posição na lista) e devolve o item removido para permitir o Desfazer.
- **Persistência sem plugin:** `localStorage` via `dart:js_interop` na web e um mapa em memória nos testes.
- **Sem nota inventada:** jogos ainda sem avaliações (como lançamentos) têm nota 0 e a tela mostra "Ainda sem avaliações".

## Como o projeto foi gerenciado

O trabalho foi organizado em um quadro Kanban no Notion, com 3 sprints (fundação, polimento e entrega), prioridade, pontos e prazo em cada cartão, e papéis definidos no grupo: código, UI/UX e gestão. Antes de dar um cartão de código como pronto, rodamos `flutter analyze`, os testes e o build.

## Aviso

Projeto acadêmico. Notas e placares de votação de exemplo são ilustrativos. Os jogos e suas capas pertencem aos respectivos titulares.
