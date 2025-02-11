:- use_module(library(lists)).
:- consult('utils.pl').
:- consult('game_logic.pl').
:- consult('ai.pl').

% Predicado principal que inicializa o menu do jogo.
% Apresenta as opções disponíveis e lê a escolha do utilizador,redirecionando para o predicado correspondente.

play :-
    write('Welcome to Collapse!'), nl,
    write('----------------------'), nl,
    write('Choose an option:'), nl,
    write('1. Human vs Human'), nl,
    write('2. Human vs PC'), nl,
    write('3. PC vs Human'), nl,
    write('4. PC vs PC'), nl,
    write('5. How to Play'), nl,
    write('6. Exit'), nl,
    write('----------------------'), nl,
    read(Choice),
    handle_choice(Choice).


% Processa a escolha do utilizador no menu principal:
% 1. Inicia jogos com diferentes combinações de jogadores (Humanos e/ou Computador).
% 2. Mostra instruções do jogo ("How to Play").
% 3. Sai do programa ou avisa em caso de escolha inválida.

handle_choice(1) :-
    write('Starting Human vs Human game...'), nl,
    initialize_game(human, human, 0, 0).
handle_choice(2) :-
    write('Starting Human vs PC game...'), nl,
    ask_difficulty(Level),
    initialize_game(human, pc, 0, Level).
handle_choice(3) :-
    write('Starting PC vs Human game...'), nl,
    ask_difficulty(Level),
    initialize_game(pc, human, Level, 0).
handle_choice(4) :-
    write('Starting PC vs PC game...'), nl,
    ask_difficulty(Level1),
    ask_difficulty(Level2),
    initialize_game(pc, pc, Level1, Level2).
handle_choice(5) :-
    how_to_play, nl,
    play.
handle_choice(6) :-
    write('Exiting the game. Goodbye!'), nl.
handle_choice(_) :-
    write('Invalid choice. Try again.'), nl,
    play.

% Apresenta as instruções de como jogar Collapse.
% Explica as regras básicas, formato das coordenadas e condições de vitória.

how_to_play :-
    nl,
    write('How to Play Collapse'), nl,
    write('---------------------------------------------------------'), nl,
    write('1. The game starts with the white pieces (w).'), nl,
    write('2. Coordinates are in the format (x, y):'), nl,
    write('   - x represents the column (1 to 9, from left to right).'), nl,
    write('   - y represents the row (1 to 5, from bottom to top).'), nl,
    write('   - For example, (1, 1) is the bottom-left corner.'), nl,
    write('3. On each turn, a player must move one of their pieces:'), nl,
    write('   - The piece moves in a straight line towards an opponent piece.'), nl,
    write('   - The opponent piece is captured and removed.'), nl,
    write('4. The game ends when a player cannot make a valid move.'), nl,
    write('---------------------------------------------------------'), nl.


% Solicita ao utilizador o nível de dificuldade para a IA.
% As opções são:
% 1. Movimentos aleatórios.
% 2. Movimentos ótimos (baseados numa estratégia gananciosa).
% Continua a pedir input em caso de escolha inválida.

% Ask the user for the AI difficulty level
ask_difficulty(Level) :-
    write('Choose AI Difficulty:'), nl,
    write('1. Random Moves'), nl,
    write('2. Optimal Moves'), nl,
    read(Level),
    (   Level = 1 ; Level = 2 -> true
    ;   write('Invalid difficulty. Try again.'), nl, ask_difficulty(Level) ).


% Solicita ao utilizador o tamanho do tabuleiro desejado.
% As opções são 9x5, 7x5 ou 5x5. Redireciona para `map_board_size/2` para mapear a escolha ao tamanho correspondente.

ask_board_size(Size) :-
    write('Choose a board size:'), nl,
    write('1. 9x5'), nl,
    write('2. 7x5'), nl,
    write('3. 5x5'), nl,
    read(Choice),
    map_board_size(Choice, Size).

% Mapeia a escolha do tamanho do tabuleiro para o valor correspondente.
% Valores válidos: 1 -> 9x5, 2 -> 7x5, 3 -> 5x5.
% Garante que escolhas inválidas são tratadas com uma nova tentativa.

map_board_size(1, 9).
map_board_size(2, 7).
map_board_size(3, 5).
map_board_size(_, _) :-
    write('Invalid choice. Try again.'), nl,
    ask_board_size(Size).


% Inicializa o jogo com as configurações escolhidas:
% - Tipos de jogadores (humano ou computador).
% - Níveis de dificuldade (caso inclua IA).
% - Tamanho do tabuleiro.
% Após inicializar o estado inicial, verifica se o jogo terminou ou inicia o loop de jogadas.

initialize_game(Player1, Player2, Level1, Level2) :-
    ask_board_size(Size),
    initial_state(Size, [Player1, Player2], GameState),
    Players = [w-Player1-Level1, b-Player2-Level2], % Associate colors, players, and levels
    display_game(GameState),
    (   game_over(GameState, Winner) ->
        format('Game Over! The winner is: ~w', [Winner]), nl
    ;   game_loop(GameState, Players)
    ).


% Fluxo principal do jogo:
% 1. Verifica se o jogo terminou. Se sim, anuncia o vencedor.
% 2. Caso contrário, identifica o jogador atual e o seu tipo (humano ou computador).
% 3. Executa o movimento do jogador (lê input ou escolhe jogada da IA).
% 4. Atualiza o estado do jogo e chama-se recursivamente para o próximo turno.

game_loop(game_state(Board, CurrentPlayer), Players) :-
    (   game_over(game_state(Board, CurrentPlayer), Winner) ->
        format('Game Over! The winner is: ~w', [Winner]), nl
    ;   member(CurrentPlayer-PlayerType-Level, Players),
        format('Player ~w\'s turn.', [PlayerType]), nl,
        nl,
        (   PlayerType = human ->
            ask_move(game_state(Board, CurrentPlayer), (X1, Y1), (X2, Y2)),
            move(game_state(Board, CurrentPlayer), (X1, Y1), (X2, Y2), game_state(NewBoard, NextPlayer))
        ;   PlayerType = pc ->
            choose_move(game_state(Board, CurrentPlayer), Level, Move),
            Move = (X1, Y1, X2, Y2),
            move(game_state(Board, CurrentPlayer), (X1, Y1), (X2, Y2), game_state(NewBoard, NextPlayer))
        ),
        display_game(game_state(NewBoard, NextPlayer)),
        game_loop(game_state(NewBoard, NextPlayer), Players)
    ).


% Solicita ao jogador, se for humano, as coordenadas para realizar um movimento.
% 1. Valida o formato do input das coordenadas de origem e destino.
% 2. Verifica se o movimento é válido no tabuleiro atual.
% 3. Em caso de erro, permite repetir até que seja fornecido um movimento válido.

ask_move(game_state(Board, Player), (X1, Y1), (X2, Y2)) :-
    repeat, % Allow retrying until valid input is provided
    write('Enter the coordinates of the piece to move (X1, Y1): '),
    read(Input1),
    (   Input1 = (X1, Y1) -> true
    ;   write('Invalid input format. Use (X, Y). Try again.'), nl, fail),
    write('Enter the destination coordinates (X2, Y2): '),
    read(Input2),
    (   Input2 = (X2, Y2) -> true
    ;   write('Invalid input format. Use (X, Y). Try again.'), nl, fail),
    (   valid_move(Board, (X1, Y1), (X2, Y2), Player) ->
        true
    ;   write('Invalid move. Try again.'), nl, fail).
