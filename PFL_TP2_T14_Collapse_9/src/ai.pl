% ai.pl

:- consult('game_logic.pl').  % Importa a lógica do jogo do game_logic.pl
:- use_module(library(random)). 

% Determina a jogada escolhida pelo computador, com base no nível de dificuldade.
% Nível 1: Escolhe uma jogada aleatória.
% Nível 2: Escolhe a melhor jogada, considerando a resposta do oponente.

choose_move(game_state(Board, Player), Level, Move) :-
    (Level = 1 -> random_move(Board, Player, Move); 
     Level = 2 -> best_move(Board, Player, Move)).


% Escolhe uma jogada válida aleatória para o jogador atual.
% A lista de movimentos válidos é obtida através do predicado `valid_moves/2`,
% Um deles é selecionado aleatoriamente usando `random_member/2`.

random_move(Board, Player, (X1, Y1, X2, Y2)) :-
    valid_moves(game_state(Board, Player), Moves),
    random_member((X1, Y1, X2, Y2), Moves).


% Encontra o melhor movimento possível.
% Para cada jogada válida:
% 1. Simula o estado do jogo após essa jogada.
% 2. Calcula o impacto dessa jogada considerando as possíveis respostas do oponente.
% 3. Atribui uma pontuação à jogada com base no impacto calculado.
% Finalmente, seleciona o movimento com a pontuação mais alta.

best_move(Board, Player, BestMove) :-
    valid_moves(game_state(Board, Player), Moves),
    findall(Score-Move, (
        member(Move, Moves),
        simulate_move(game_state(Board, Player), Move, FutureState),
        opponent_moves_score(FutureState, Player, Score)
    ), ScoredMoves),
    max_member(_-BestMove, ScoredMoves).


% Avalia o impacto das possíveis respostas do oponente.
% Para cada jogada válida do oponente:
% 1. Simula o estado futuro do jogo.
% 2. Determina a quantidade de movimentos válidos disponíveis para o AI após a jogada do oponente.
% 3. Soma os valores de todas as possibilidades para obter uma pontuação global.
% Jogadas que limitam as opções do oponente são favorecidas.

opponent_moves_score(game_state(Board, CurrentPlayer), AIPlayer, TotalScore) :-
    switch_player(CurrentPlayer, Opponent),
    valid_moves(game_state(Board, Opponent), OpponentMoves),
    findall(AIMoveCount, (
        member(OpponentMove, OpponentMoves),
        simulate_move(game_state(Board, Opponent), OpponentMove, FutureState),
        valid_moves(FutureState, AIMoves),
        length(AIMoves, AIMoveCount)
    ), Scores),
    sum_list(Scores, TotalScore).

% Soma os elementos de uma lista

sum_list([], 0).
sum_list([Head|Tail], Sum) :-
    sum_list(Tail, TailSum),
    Sum is Head + TailSum.


% Simula um movimento no tabuleiro.

simulate_move(game_state(Board, Player), (X1, Y1, X2, Y2), game_state(NewBoard, NextPlayer)) :-
    move(game_state(Board, Player), (X1, Y1), (X2, Y2), game_state(NewBoard, NextPlayer)).