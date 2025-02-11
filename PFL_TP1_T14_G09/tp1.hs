import qualified Data.List
import qualified Data.Array
import qualified Data.Bits

-- PFL 2024/2025 Practical assignment 1

-- Uncomment the some/all of the first three lines to import the modules, do not change the code of these lines.

type City = String
type Path = [City]
type Distance = Int

type RoadMap = [(City, City, Distance)]

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- | 'cities' devolve uma lista de todas as cidades presentes no mapa de estradas.
-- A função remove duplicados e ordena as cidades.
-- Argumentos:
--   roadmap - O mapa de estradas representado como uma lista de tuplos (Cidade, Cidade, Distância).
cities :: RoadMap -> [City]
cities roadmap = isort([city | (city1, city2, _ ) <- roadmap, city <- [city1, city2]])

-- | 'insert' insere um elemento numa lista ordenada.
-- Argumentos:
--   x - O elemento a ser inserido.
--   ys - A lista ordenada onde o elemento será inserido.
insert :: Ord a => a -> [a] -> [a]
insert x [] = [x]
insert x (y:ys) 
    | x < y = x : y : ys  
    | x == y = y : ys 
    | otherwise = y : insert x ys

-- | 'isort' ordena uma lista utilizando o algoritmo de ordenação por inserção.
-- Argumentos:
--   xs - A lista a ser ordenada.
isort :: Ord a => [a] -> [a]
isort [] = []
isort (x:xs) = insert x (isort xs)

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- | 'areAdjacent' verifica se duas cidades são adjacentes no mapa de estradas.
-- Argumentos:
--   roadmap - O mapa de estradas.
--   cityA - A primeira cidade.
--   cityB - A segunda cidade.
areAdjacent :: RoadMap -> City -> City -> Bool
areAdjacent roadmap cityA cityB = any (\(city1, city2, _) -> (city1 == cityA && city2 == cityB) || (city2 == cityA && city1 == cityB)) roadmap 

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- | 'distance' devolve a distância entre duas cidades, se existir.
-- Argumentos:
--   roadmap - O mapa de estradas.
--   cityA - A primeira cidade.
--   cityB - A segunda cidade.
distance :: RoadMap -> City -> City -> Maybe Distance
distance roadmap cityA cityB = 
        case [distance | (city1, city2, distance) <- roadmap, (city1 == cityA && city2 == cityB) || (city1 == cityB && city2 == cityA)] of
            []     -> Nothing
            (distance: _) -> Just distance

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- | 'adjacent' devolve uma lista de cidades adjacentes a uma cidade dada, juntamente com as distâncias.
-- Argumentos:
--   roadmap - O mapa de estradas.
--   cityA - A cidade para a qual queremos encontrar as cidades adjacentes.
adjacent :: RoadMap -> City -> [(City, Distance)]
adjacent roadmap cityA = [if city1 == cityA then (city2, distance) else (city1, distance) | (city1, city2, distance) <- roadmap, city1 == cityA || city2 == cityA]

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- | 'pathDistance' calcula a distância total de um percurso, se todas as cidades no percurso estiverem conectadas.
-- Argumentos:
--   roadmap - O mapa de estradas.
--   path - O percurso representado como uma lista de cidades.
pathDistance :: RoadMap -> Path -> Maybe Distance
pathDistance roadmap path = go path 0
  where
    go [] total = Just total  -- Se não houver cidades, retornamos a distância total
    go [_] total = Just total  -- Se houver apenas uma cidade, retornamos a distância total
    go (city1:city2:rest) total =
      case distance roadmap city1 city2 of
        Nothing -> Nothing  -- Se não há distância entre city1 e city2, retornamos Nothing
        Just d -> go (city2:rest) (total + d)

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- | 'rome' devolve uma lista de cidades com o maior grau de conexão no mapa de estradas.
-- Argumentos:
--   roadmap - O mapa de estradas.
rome :: RoadMap -> [City]
rome roadmap =
    let cities = isort([city | (city1, city2, _ ) <- roadmap, city <- [city1, city2]]) 
        degCount city = length [(c1, c2) | (c1, c2, _) <- roadmap, c1 == city || c2 == city] 
        cityDeg = [(city, degCount city) | city <- cities]  
        maxDegree = maximum [degree | (_, degree) <- cityDeg]  
    in [city | (city, degree) <- cityDeg, degree == maxDegree]

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- | 'dfs' realiza uma busca em profundidade (DFS) para visitar todas as cidades conectadas.
-- Argumentos:
--   roadmap - O mapa de estradas.
--   city - A cidade inicial.
--   visited - A lista de cidades já visitadas.
dfs :: RoadMap -> City -> [City] -> [City]
dfs roadmap city visited = 
    foldl (\visited nextCity -> if nextCity `elem` visited then visited else dfs roadmap nextCity visited) 
          (city : visited) 
          (map fst (adjacent roadmap city)) -- cidades adjacentes ao current city

-- | 'isStronglyConnected' verifica se o grafo é fortemente conexo.
-- Argumentos:
--   roadmap - O mapa de estradas.
isStronglyConnected :: RoadMap -> Bool
isStronglyConnected roadmap
    | null roadmap = True -- Um grafo vazio é fortemente conexo
    | otherwise = 
        let citiesList = cities roadmap
            inicCity = head citiesList
            visitedFrominic = dfs roadmap inicCity []
            reversedMap = [(city2, city1, distance) | (city1, city2, distance) <- roadmap]
            visitedFrominicReversed = dfs reversedMap inicCity []
        in length visitedFrominic == length citiesList && length visitedFrominicReversed == length citiesList

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- | 'shortestPath' encontra todos os caminhos mais curtos entre duas cidades.
-- Argumentos:
--   roadMap - O mapa de estradas.
--   inic - A cidade inicial.
--   fin - A cidade final.
shortestPath :: RoadMap -> City -> City -> [Path]
shortestPath roadMap inic fin
    | inic == fin = [[inic]] -- Caso base: caminho de uma cidade para si mesma
    | otherwise =
        let paths = bfsPaths roadMap [[inic]] fin [] -- Busca todos os caminhos
            minDist = minimum (map (pathDistance roadMap) paths) -- Encontra a menor distância
        in filter (\p -> pathDistance roadMap p == minDist) paths -- Filtra os caminhos com a menor distância

-- | 'bfsPaths' realiza uma busca em largura (BFS) para encontrar todos os caminhos entre duas cidades.
-- Argumentos:
--   roadMap - O mapa de estradas.
--   paths - A lista de caminhos a serem explorados.
--   goal - A cidade destino.
--   res - A lista de caminhos encontrados até agora.
bfsPaths :: RoadMap -> [Path] -> City -> [Path] -> [Path]
bfsPaths _ [] _ res = res
bfsPaths roadMap (path:queue) goal res
    | currentCity == goal = bfsPaths roadMap queue goal (path : res)
    | otherwise =
        let nextCities = [next | (next, _) <- adjacent roadMap currentCity, next `notElem` path]
            newPaths = [path ++ [next] | next <- nextCities]
        in bfsPaths roadMap (queue ++ newPaths) goal res
  where
    currentCity = last path

----------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- | 'travelSales' resolve o problema, encontrando o percurso mais curto que visita todas as cidades e retorna à cidade inicial.
-- Argumentos:
--   roadmap - O mapa de estradas.
travelSales :: RoadMap -> Path
travelSales roadmap =
    let citiesList = cities roadmap
        inicingCity = head citiesList  -- primeira cidade como porto de partida
        otherCities = tail citiesList  -- restantes cidades

        -- | 'totalDistance' calcula a distância total de um percurso, incluindo o retorno à cidade inicial.
        -- Argumentos:
        --   path - O percurso representado como uma lista de cidades.
        totalDistance :: Path -> Maybe Distance
        totalDistance path =
            let fullPath = path ++ [inicingCity]  -- volta à cidade inicial
            in pathDistance roadmap fullPath
        
        -- | 'permutations' gera todas as permutações de uma lista.
        -- Argumentos:
        --   xs - A lista a ser permutada.
        permutations :: Eq a => [a] -> [[a]]
        permutations [] = [[]]
        permutations xs = [x : ps | x <- xs, ps <- permutations (filter (/= x) xs)]

        -- Gera todas as permutações das outras cidades
        allPaths = [inicingCity : path | path <- permutations otherCities]
        
        -- Distância de todos os percursos
        distances = [(p, totalDistance p) | p <- allPaths]  -- associa percurso a distância
        
        -- Filtra percursos com distância Nothing
        validPaths = [(p, d) | (p, Just d) <- distances]  -- mantém distâncias válidas

        -- Encontra o percurso com a menor distância
        findShortest :: [(Path, Distance)] -> Maybe (Path, Distance)
        findShortest [] = Nothing
        findShortest paths = Just $ foldl1 minByDistance paths
          where
            minByDistance (p1, d1) (p2, d2) = if d1 < d2 then (p1, d1) else (p2, d2)

    in case findShortest validPaths of
         Nothing -> []  -- retorna vazio se não houver nenhum caminho válido
         Just (shortestPath, _) -> 
             let lastCity = last shortestPath  -- última cidade do percurso
             -- verifica se a última cidade é adjacente à cidade inicial
             in if areAdjacent roadmap lastCity inicingCity
                then shortestPath ++ [inicingCity]  -- retorna o percurso completo com a cidade inicial no fim
                else
                    -- procura outros percursos que retornem à cidade inicial
                    let validReturningPaths = filter (\(p, _) -> areAdjacent roadmap (last p) inicingCity ) validPaths
                    in case findShortest validReturningPaths of
                         Nothing -> []  -- se não houver caminhos que retornem, retorna vazio
                         Just (returningPath, _) -> returningPath ++ [inicingCity]  -- retorna o caminho que retorna à cidade inicial


----------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Alguns grafos para testar o nosso trabalho
gTest1 :: RoadMap
gTest1 = [("7","6",1),("8","2",2),("6","5",2),("0","1",4),("2","5",4),("8","6",6),("2","3",7),("7","8",7),("0","7",8),("1","2",8),("3","4",9),("5","4",10),("1","7",11),("3","5",14)]

gTest2 :: RoadMap
gTest2 = [("0","1",10),("0","2",15),("0","3",20),("1","2",35),("1","3",25),("2","3",30)]

gTest3 :: RoadMap -- grafo desconectado
gTest3 = [("0","1",4),("2","3",2)]