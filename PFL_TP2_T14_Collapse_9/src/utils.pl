% utils.pl


% Exibe o estado atual do jogo no terminal.
% Mostra o jogador atual e desenha o tabuleiro, incluindo os números das colunas e linhas.
% Utiliza funções auxiliares para exibir o cabeçalho das colunas, as linhas horizontais,e cada linha do tabuleiro, na ordem correta (de baixo para cima).

display_game(game_state(Board, CurrentPlayer)) :-
    nl,
    write('Current Player: '), write(CurrentPlayer), nl,
    length(Board, NumRows),
    nth1(1, Board, FirstRow),
    length(FirstRow, NumCols),
    write('    '), display_column_headers(NumCols), nl,
    write('   +'), display_horizontal_line(NumCols), nl,
    display_rows(Board, NumRows),
    write('   +'), display_horizontal_line(NumCols), nl.


% Exibe os números das colunas no topo do tabuleiro.
% Os números são apresentados da esquerda para a direita (1 até N).

display_column_headers(0).
display_column_headers(N) :-
    N > 0,
    N1 is N - 1,
    display_column_headers(N1),
    write(' '), write(N), write(' ').


% Desenha uma linha horizontal com um formato padrão ("---") para separar as linhas do tabuleiro.
% A linha horizontal é delimitada por '+' no início e no fim.

display_horizontal_line(0) :- write('+').
display_horizontal_line(N) :-
    N > 0,
    N1 is N - 1,
    write('---'),
    display_horizontal_line(N1).


% Exibe todas as linhas do tabuleiro na ordem inversa (de baixo para cima).
% Utiliza a função `reverse/2` para inverter as linhas do tabuleiro.
% Na lógica interna as linhas começam no topo, mas devem ser exibidas de baixo para cima, porque (1,1) é no canto inferior esquerdo.

display_rows(Board, _) :-
    reverse(Board, ReversedBoard), % Inverter as linhas
    display_rows_reversed(ReversedBoard, 5). % Começa a contagem do número maior para o menor


% Função auxiliar para exibir as linhas já invertidas.
% Imprime o número da linha no início e chama `display_row/1` para exibir o conteúdo.
% Diminui o número da linha para cada linha subsequente.

display_rows_reversed([], _).
display_rows_reversed([Row|Rest], N) :-
    format(' ~d |', [N]), % Imprime o número da linha
    display_row(Row),
    write('|'), nl,
    N1 is N - 1, % Diminui o número da linha
    display_rows_reversed(Rest, N1).


% Exibe os elementos de uma linha do tabuleiro.
% Cada célula é exibida sequencialmente, chamando a função `display_cell/1`.

display_row([]).
display_row([Cell|Rest]) :-
    display_cell(Cell),
    display_row(Rest).


% Exibe uma célula individual do tabuleiro:
% - 'w' para peças brancas.
% - 'b' para peças pretas.
% - '.' para posições vazias.
% O espaçamento é mantido uniforme para uma exibição clara.

display_cell(w) :- write(' w '), !.
display_cell(b) :- write(' b '), !.
display_cell(.) :- write(' . '), !.