# README

## Identificação dos Membros do Grupo

| Nome          | Contribuição (%) | Funções Implementadas                                |
|---------------|------------------|----------------------------------------------------|
| Diogo Ramos      | 50%             | `cities`, `distance`, `pathDistance`, `isStronglyConnected`,    `shortestPath`, `travelSales`.   |
| Tiago Pires     | 50%              | `areAdjacent`, `adjacent`, `rome`, `isStronglyConnected`,    `shortestPath`, `travelSales`.  |


## Implementação da Função `shortestPath`

A função `shortestPath` foi implementada para encontrar todos os caminhos possíveis entre duas cidades e filtrar os caminhos de menor distância. Abaixo estão os principais componentes da função e as justificações para a seleção das estruturas de dados auxiliares e algoritmos utilizados:

### Estruturas de Dados Auxiliares
- **Lista de Caminhos (`[Path]`)**: Utilizada para armazenar todos os caminhos encontrados pela busca em largura (BFS) entre as cidades. A escolha de listas permite fácil concatenação e manutenção dos caminhos.
- **Lista de Resultados (`[Path]`)**: Armazena os caminhos válidos que atingem a cidade alvo. Essa lista é essencial para filtrar os caminhos mais curtos após a BFS.

### Algoritmo Utilizado
1. **(BFS)**: A função `bfsPaths` é utilizada para explorar todas as rotas possíveis a partir da cidade de início, garantindo que todos os caminhos até a cidade de destino sejam encontrados.
2. **Filtragem**: A função calcula a distância de cada caminho encontrado e filtra para manter apenas aqueles que possuem a menor distância.

### Justificação
A abordagem com o algoritmo de BFS é adequada para este problema, pois garante que todos os caminhos possíveis sejam explorados,e para testes como os dados funciona bem e de uma forma rápida ,permitindo encontrar a menor distância sem visitar cidades repetidas.

---

## Implementação da Função `travelSales`

A função `travelSales` visa encontrar o caminho mais curto que visita todas as cidades e retorna à cidade inicial. Abaixo estão os componentes da função e as justificativas para a seleção das estruturas de dados auxiliares:

### Estruturas de Dados Auxiliares
- **Lista de Distâncias**: Mantém uma associação entre os caminhos e as suas respetivas distâncias. Esta lista é fundamental para identificar o percurso mais curto.

### Algoritmo Utilizado
1. **Gerar Permutações**: Com a utilização da função `permutations` gerámos todas as ordens possíveis em que as cidades podem ser visitadas, começando na cidade inicial.
2. **Cálculo de Distância**: Para cada permutação anteriormente gerada, a função `totalDistance` é chamada para calcular a distância total, incluindo o retorno à cidade inicial.
3. **Filtragem do Caminho Mais Curto**: Filtra apenas os caminhos válidos e seleciona aquele com a menor distância.

### Justificação
A abordagem com permutações é viável para grafos menores, onde todas as possibilidades podem ser avaliadas. Embora não seja eficiente para grandes conjuntos de cidades devido à complexidade factorial, garante que todos os caminhos sejam considerados, resultando numa solução ótima.
