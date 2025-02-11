% game_logic.pl

:- consult('utils.pl'). 


% Usar durante a apresentação
% gameover_board(Size, Board)

% Define o estado inicial do jogo.
% Aceita o tamanho do tabuleiro (5x5, 7x5, ou 9x5) e a lista de jogadores.
% Retorna o estado inicial do jogo, que inclui o tabuleiro e o jogador inicial (branco).

initial_state(Size, [Player1, Player2], game_state(Board, w)) :-
    board(Size, Board),
    !.


% Define o tabuleiro inicial para diferentes tamanhos (9x5, 7x5, 5x5).
% Cada tamanho possui uma configuração específica com peças brancas (w),pretas (b) e espaços vazios (.).

board(9, [ [w, b, w, b, w, b, w, b, w],
             [b, ., ., ., ., ., ., ., b],
             [., ., ., ., ., ., ., ., .],
             [w, ., ., ., ., ., ., ., w],
             [b, w, b, w, b, w, b, w, b] ]).

board(7, [ [w, b, w, b, w, b, w],
             [b, ., ., ., ., ., b],
             [., ., ., ., ., ., .],
             [w, ., ., ., ., ., w],
             [b, w, b, w, b, w, b] ]).


board(5, [ [w, b, w, b, w],
             [b, ., ., ., b],
             [., ., ., ., .],
             [w, ., ., ., w],
             [b, w, b, w, b] ]).


% Realiza o movimento de uma peça no tabuleiro.
% Valida o movimento, captura a peça adversária e atualiza o tabuleiro,muda para o próximo jogador.
% A estratégia usada foi dividir em vários predicados para facilitar a compreensão e também para facilitar o teste de cada parte do código.
% Assim primeiro foi testado se os valid moves estavam corretos, depois se a captura da peça adversária estava correta e por fim se a troca de jogador estava correta.

move(game_state(Board, CurrentPlayer), (X1, Y1), (X2, Y2), game_state(NewBoard, NextPlayer)) :-
    valid_move(Board, (X1, Y1), (X2, Y2), CurrentPlayer),
    capture_piece(Board, (X1, Y1), (X2, Y2), CurrentPlayer, NewBoard),
    switch_player(CurrentPlayer, NextPlayer).


% Verifica se um movimento é válido:
% 1. A peça na posição inicial pertence ao jogador atual.
% 2. A posição final contém uma peça adversária.
% 3. O caminho entre as posições está livre.

valid_move(Board, (X1, Y1), (X2, Y2), Player) :-
    nth1(Y1, Board, Row1),
    nth1(X1, Row1, Piece1),
    Piece1 = Player,
    nth1(Y2, Board, Row2),
    nth1(X2, Row2, Piece2),
    Piece2 \= Player,
    Piece2 \= '.',
    clear_path(Board, (X1, Y1), (X2, Y2)).
    

% Verifica se o caminho entre duas posições está livre.
% Suporta movimentos verticais, horizontais e diagonais.

clear_path(Board, (X1, Y1), (X2, Y2)) :-
    X1 =:= X2,
    clear_path_vertical(Board, X1, Y1, Y2).

clear_path(Board, (X1, Y1), (X2, Y2)) :-
    Y1 =:= Y2,
    clear_path_horizontal(Board, Y1, X1, X2).

clear_path(Board, (X1, Y1), (X2, Y2)) :-
    abs(X2 - X1) =:= abs(Y2 - Y1), 
    clear_path_diagonal(Board, X1, Y1, X2, Y2).


% Verifica se o caminho diagonal entre duas posições está livre.
% A primeira célula deve estar vazia, e a verificação continua recursivamente até alcançar o destino, para garantir que não haja peças no caminho.

clear_path_diagonal(Board, X1, Y1, X2, Y2) :-
    DX is sign(X2 - X1),
    DY is sign(Y2 - Y1),
    NextX is X1 + DX,
    NextY is Y1 + DY,
    % Verifica se a célula imediatamente adjacente está vazia
    within_board(NextX, NextY),
    nth1(NextY, Board, Row),
    nth1(NextX, Row, Cell),
    Cell = '.', % Primeira célula adjacente deve estar vazia
    clear_path_diagonal_recursive(Board, NextX, NextY, X2, Y2).

clear_path_diagonal_recursive(Board, X, Y, X, Y) :- true. % Caso base: destino alcançado.

clear_path_diagonal_recursive(Board, X, Y, X2, Y2) :-
    within_board(X, Y),
    nth1(Y, Board, Row),
    nth1(X, Row, Cell),
    Cell = '.', 
    NextX is X + sign(X2 - X),
    NextY is Y + sign(Y2 - Y),
    clear_path_diagonal_recursive(Board, NextX, NextY, X2, Y2).


% Verifica se o caminho vertical entre duas posições está livre.
% Mais uma vez a mesma estratégia, a primeira célula deve estar vazia, e a verificação continua recursivamente até alcançar o destino, para garantir que não haja peças no caminho.

clear_path_vertical(Board, X, Y1, Y2) :-
    Y1 < Y2,
    Y is Y1 + 1,
    nth1(Y, Board, Row),
    nth1(X, Row, Piece),
    Piece = '.', % Primeira posição adjacente deve estar vazia
    clear_path_vertical_recursive(Board, X, Y, Y2).

clear_path_vertical(Board, X, Y1, Y2) :-
    Y1 > Y2,
    Y is Y1 - 1,
    nth1(Y, Board, Row),
    nth1(X, Row, Piece),
    Piece = '.', % Primeira posição adjacente deve estar vazia
    clear_path_vertical_recursive(Board, X, Y, Y2).

clear_path_vertical_recursive(Board, X, Y, Y) :- true. % Destino alcançado.

clear_path_vertical_recursive(Board, X, Y, Y2) :-
    within_board(X, Y),
    nth1(Y, Board, Row),
    nth1(X, Row, Piece),
    Piece = '.', 
    NextY is Y + sign(Y2 - Y),
    clear_path_vertical_recursive(Board, X, NextY, Y2).


% Verifica se o caminho horizontal entre duas posições está livre.
% Mais uma vez a mesma estratégia, a primeira célula deve estar vazia, e a verificação continua recursivamente até alcançar o destino, para garantir que não haja peças no caminho.


clear_path_horizontal(Board, Y, X1, X2) :-
    X1 < X2,
    X is X1 + 1,
    nth1(Y, Board, Row),
    nth1(X, Row, Piece),
    Piece = '.', % Primeira posição adjacente deve estar vazia
    clear_path_horizontal_recursive(Board, Y, X, X2).

clear_path_horizontal(Board, Y, X1, X2) :-
    X1 > X2,
    X is X1 - 1,
    nth1(Y, Board, Row),
    nth1(X, Row, Piece),
    Piece = '.', % Primeira posição adjacente deve estar vazia
    clear_path_horizontal_recursive(Board, Y, X, X2).

clear_path_horizontal_recursive(Board, Y, X, X) :- true. % Destino alcançado.

clear_path_horizontal_recursive(Board, Y, X, X2) :-
    within_board(X, Y),
    nth1(Y, Board, Row),
    nth1(X, Row, Piece),
    Piece = '.', 
    NextX is X + sign(X2 - X),
    clear_path_horizontal_recursive(Board, Y, NextX, X2).


% Captura uma peça adversária ao realizar um movimento válido.
% Atualiza o tabuleiro removendo a peça capturada e movendo a peça do jogador para a posição correspondente.

capture_piece(Board, (X1, Y1), (X2, Y2), Player, NewBoard) :-
    opponent(Player, Opponent),
    % format("Removing player's piece from (~w, ~w)~n", [X1, Y1]),
    replace(Board, Y1, X1, '.', TempBoard1),
    % format("Removing opponent's piece from (~w, ~w)~n", [X2, Y2]),
    replace(TempBoard1, Y2, X2, '.', TempBoard2),
    calculate_behind_position((X1, Y1), (X2, Y2), (XBehind, YBehind)),
    % format("Placing player's piece at (~w, ~w)~n", [XBehind, YBehind]),
    replace(TempBoard2, YBehind, XBehind, Player, NewBoard).


% Calcula a posição "atrás" da peça capturada em relação ao movimento, uma vez que, basicamente depois de colidir e capturar a peça dá um bounce back.
% Assegura que a posição resultante está dentro dos limites do tabuleiro.

calculate_behind_position((X1, Y1), (X2, Y2), (XBehind, YBehind)) :-
    DX is X2 - X1,
    DY is Y2 - Y1,
    XBehind is X2 - sign(DX),  % Move one step back toward the starting position
    YBehind is Y2 - sign(DY),  % Move one step back toward the starting position
    within_board(XBehind, YBehind).  % Ensure the position is within the board
    % format("DX: ~w, DY: ~w, XBehind: ~w, YBehind: ~w~n", [DX, DY, XBehind, YBehind]).


% Verifica se uma posição está dentro dos limites do tabuleiro.

within_board(X, Y) :-
    X >= 1, X =< 9,
    Y >= 1, Y =< 5.


% Define o adversário de cada jogador.
% Branco (w) -> Preto (b) e vice-versa.

opponent(w, b).
opponent(b, w).


% Substitui o valor de uma célula numa posição específica do tabuleiro.
% `replace/5` atua na linha correspondente, enquanto `replace_row/4` substitui a célula dentro da linha

replace([Row|Rest], 1, Column, Value, [NewRow|Rest]) :-
    replace_row(Row, Column, Value, NewRow).

replace([Row|Rest], RowNumber, Column, Value, [Row|NewRest]) :-
    RowNumber > 1,
    RowNumber1 is RowNumber - 1,
    replace(Rest, RowNumber1, Column, Value, NewRest).

replace_row([_|Rest], 1, Value, [Value|Rest]).
replace_row([H|T], Column, Value, [H|NewT]) :-
    Column > 1,
    Column1 is Column - 1,
    replace_row(T, Column1, Value, NewT).


% Alterna entre os jogadores branco (w) e preto (b).

switch_player(w, b).
switch_player(b, w).

% Gera uma lista de todos os movimentos válidos para o jogador atual.
% Baseia-se no predicado `valid_move/4`.

valid_moves(game_state(Board, CurrentPlayer), ListOfMoves) :-
    findall((X1, Y1, X2, Y2), valid_move(Board, (X1, Y1), (X2, Y2), CurrentPlayer), ListOfMoves).


% Verifica se o jogo terminou:
% 1. O jogador atual não possui movimentos válidos.
% 2. Retorna o adversário como vencedor.

game_over(game_state(Board, CurrentPlayer), Winner) :-
    valid_moves(game_state(Board, CurrentPlayer), []),
    switch_player(CurrentPlayer, Winner).


% Board para a apresentação
gameover_board(9 , [
    ['w', '.', '.', '.', '.', '.', '.', '.', '.'],
    ['.', '.', '.', '.', '.', '.', '.', '.', '.'],
    ['.', '.', 'b', '.', '.', '.', 'b', 'w', '.'],
    ['.', '.', '.', '.', '.', '.', '.', '.', '.'],
    ['.', '.', '.', '.', '.', '.', '.', '.', '.']
]).




% Predicados de teste para verificar a implementação de `game_over/2`,movimentos válidos e a posição de peças no tabuleiro. Feitos durante a implementação.

test_game_over :-
    test_board(Board),
    game_over(game_state(Board, w), Winner),
    format('Game over! Winner: ~w~n', [Winner]).

test_valid_moves :-
    test_board(Board),
    valid_moves(game_state(Board, w), WhiteMoves),
    valid_moves(game_state(Board, b), BlackMoves),
    format('Valid moves for White: ~w~n', [WhiteMoves]),
    format('Valid moves for Black: ~w~n', [BlackMoves]).


test_piece_at_position(X, Y, Piece) :-
    initial_board(Board),
    nth1(Y, Board, Row),
    nth1(X, Row, Piece).


