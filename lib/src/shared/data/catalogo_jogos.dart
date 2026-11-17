import '../domain/game.dart';

// CATÁLOGO ÚNICO de jogos do app (usado por Home, Explorar, Zerados e GOTY).
// Anos e estúdios conferem com fontes oficiais; as NOTAS são ilustrativas.
// As capas ficam em assets/covers/<id>.jpg (veja tools/baixar_capas.ps1).
// Se o arquivo não existir, o GameCover mostra um placeholder.

Game _j(String id, String titulo, int ano, String estudio, String genero, double nota) =>
    Game(
      id: id,
      title: titulo,
      coverUrl: 'assets/covers/$id.jpg',
      releaseYear: ano,
      developer: estudio,
      genre: genero,
      rating: nota,
    );

final List<Game> catalogoJogos = [
  // Lançamento: nota 0 = ainda sem avaliações da comunidade (não inventamos nota).
  _j('gta6', 'Grand Theft Auto VI', 2026, 'Rockstar Games', 'Ação', 0),
  // Vencedores do GOTY (The Game Awards).
  _j('cx33', 'Clair Obscur: Expedition 33', 2025, 'Sandfall Interactive', 'RPG', 4.6),
  _j('astro', 'Astro Bot', 2024, 'Team Asobi', 'Plataforma', 4.5),
  _j('bg3', "Baldur's Gate 3", 2023, 'Larian Studios', 'RPG', 4.7),
  _j('elden', 'Elden Ring', 2022, 'FromSoftware', 'RPG', 4.5),
  _j('ittakestwo', 'It Takes Two', 2021, 'Hazelight Studios', 'Aventura', 4.3),
  _j('tlou2', 'The Last of Us Part II', 2020, 'Naughty Dog', 'Ação', 4.2),
  _j('sekiro', 'Sekiro: Shadows Die Twice', 2019, 'FromSoftware', 'Ação', 4.3),
  _j('gow', 'God of War', 2018, 'Santa Monica Studio', 'Ação', 4.6),
  _j('botw', 'The Legend of Zelda: Breath of the Wild', 2017, 'Nintendo EPD', 'Aventura', 4.6),
  _j('ow', 'Overwatch', 2016, 'Blizzard Entertainment', 'FPS', 4.0),
  _j('w3', 'The Witcher 3: Wild Hunt', 2015, 'CD Projekt Red', 'RPG', 4.7),
  _j('dai', 'Dragon Age: Inquisition', 2014, 'BioWare', 'RPG', 4.0),
  // Outros jogos do catálogo.
  _j('hollow', 'Hollow Knight', 2017, 'Team Cherry', 'Metroidvania', 4.6),
  _j('celeste', 'Celeste', 2018, 'Maddy Makes Games', 'Plataforma', 4.5),
  _j('hades', 'Hades', 2020, 'Supergiant Games', 'Roguelike', 4.7),
  _j('stardew', 'Stardew Valley', 2016, 'ConcernedApe', 'Simulação', 4.6),
  _j('portal2', 'Portal 2', 2011, 'Valve', 'Puzzle', 4.8),
  _j('undertale', 'Undertale', 2015, 'tobyfox', 'RPG', 4.5),
  _j('disco', 'Disco Elysium', 2019, 'ZA/UM', 'RPG', 4.5),
  // Mais jogos do catálogo.
  _j('rdr2', 'Red Dead Redemption 2', 2018, 'Rockstar Games', 'Aventura', 4.8),
  _j('rdr1', 'Red Dead Redemption', 2010, 'Rockstar San Diego', 'Ação', 4.5),
  _j('gta5', 'Grand Theft Auto V', 2013, 'Rockstar North', 'Ação', 4.5),
  _j('cyberpunk', 'Cyberpunk 2077', 2020, 'CD Projekt Red', 'RPG', 4.1),
  _j('re4', 'Resident Evil 4', 2023, 'Capcom', 'Terror', 4.6),
  _j('silenthill2', 'Silent Hill 2', 2024, 'Bloober Team', 'Terror', 4.4),
  _j('doometernal', 'DOOM Eternal', 2020, 'id Software', 'FPS', 4.4),
  _j('p5r', 'Persona 5 Royal', 2022, 'Atlus', 'RPG', 4.7),
  _j('deathstranding', 'Death Stranding', 2019, 'Kojima Productions', 'Aventura', 4.0),
  _j('outerwilds', 'Outer Wilds', 2019, 'Mobius Digital', 'Aventura', 4.6),
];

/// Busca por id; `null` se não existir.
Game? buscarJogoPorId(String id) {
  for (final g in catalogoJogos) {
    if (g.id == id) return g;
  }
  return null;
}

/// Busca por título, ignorando maiúsculas e espaços nas pontas.
Game? buscarJogoPorTitulo(String titulo) {
  final t = titulo.trim().toLowerCase();
  for (final g in catalogoJogos) {
    if (g.title.toLowerCase() == t) return g;
  }
  return null;
}

/// Igual a [buscarJogoPorId], mas lança erro se o id não existir (dados fixos).
Game jogoDoCatalogo(String id) =>
    buscarJogoPorId(id) ?? (throw StateError('Jogo "$id" não está no catálogo'));

/// Gêneros disponíveis, em ordem alfabética (usados nos filtros de Explorar).
List<String> generosDoCatalogo() =>
    (catalogoJogos.map((g) => g.genre).toSet().toList()..sort());
