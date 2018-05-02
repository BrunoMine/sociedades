API do Mod Sunos v1.4

Variaveis Auxiliares
--------------------
Essas variaveis ficam armazenadas na tabela global `sunos.var` e podem ser encontradas no arquivo `diretrizes.lua`.
Não é recomendado modificar essas variaveis manualmente para que seja mantida a reprodução integral do repositório oficial.


Estruturas
----------
Devem ser criadas dentro da tabela `sunos.estruturas`. Alguns valores dentro 
do índice da estrutura na tabela são para propositos especificos.

sunos.estruturas.estrut : armazenara todos os dados da estrutura.
    índices padrões para estruturas
    {
        pop = [true] : Define que a estrutura possui população.
        
        fund_on_rightclick = function(...) end : chamada `on_rightclick` do node de fundamento.
        
        fund_on_destruct = function(...) end : chamada `on_destruct` do node de fundamento.
        
        fund_on_timer = function(...) end : chamada `on_timer` do node de fundamento.
        
        defendido = function(pos) end : função que verifica se a estrutura está defendida.
            * `pos` é a coordenada do fundamento da estrutura.
            * Deve retornar `true` caso a estrutura esteja defendida.
            
        verificar = function(pos) end : verifica se uma estrutura está destruida e toma as providencias caso esteja.
            * `pos` é a coordenada do fundamento da estrutura.    
    }


NPCs
----

### Registro de NPC
* `sunos.npcs.npc.registrar(tipo, Definições de NPC)` : Registrar um NPC comum
  * `tipo` é o nome da tipagem particular do npc (exemplo: "casa", "comunal")

### Registro e spawner
* `sunos.npc_checkin.register_spawner(nodename, Definições de Spawner)` : Registra um node spawner
  * `nodename` é o itemstring do node spawner

### Definições de NPC
    {
        max_dist = 15,
            ^ Distancia maxima que o mob pode ficar da coordenada de origem

        node_spawner = "sunos:nodename",
            ^ Node do bau que vai spawnar o npc no sentido de estar associado com o mesmo
    
        nodes_spawn = {"sunos:meu_bau"},
            ^ Node sobre o qual o npc pode spawnar aleatoriamente
            ^ Por padrao será madeira, pedregulho e tijolos de pedra
        
        on_step = function(self),
            ^ O tempo entre cada iteração é o valor definido em `tempo_verif_bau` (não documentado)
        
        on_rightclick(self, player)
            ^ função on_rightclick padrão (você pode atribuir argumentos extras #3, #4, ...)
        
        drops = {{name = "default:wood", chance = 1, min = 1, max = 3}}
            ^ lista de itens que caem quando o npc morre (conforme definido nos mobs do mobs_redo)
    }

### Definições de Spawner
    {
        func_spawn = function(pos, tipo) end,
            ^ pos é a coordenada do spawner que vai spawnar um npc
            ^ tipo é o tipo de NPC registrado
    }

Tabelas Globais
-----------------
Alguns aspectos do mod podem ser dinamicamente alterados sem que haja a necessidade de alteração no código desse mod.
Para isso basta que mods terceiros modifiquem as tabelas globais que estão aqui mostradas.

* `sunos.estruturas.casa.var.estante_livros`
    * itens que aparecem aleatóriamente nas estantes de livros das casas
    * tabela ordenada com itemstacks no formato tabela ou string
    * podem ser modificadas a qualquer momento
    * não repete itens na mesma estante

* `sunos.estruturas.casa.var.estante_frascos`
    * itens que aparecem aleatóriamente nas estantes de frascos das casas
    * tabela ordenada com itemstacks no formato tabela ou string 
    * podem ser modificadas a qualquer momento
    * não repete itens na mesma estante
    
### Exemplo
`
table.insert(sunos.estruturas.casa.var.estante_livros, {name="monname:book", count=5, wear=0, metadata=""})
table.insert(sunos.estruturas.casa.var.estante_frascos, "vessels:glass_bottle")
`


Registros Reservados
--------------------
Essa seção busca informar alguns dados de registro que não devem ser mexidos em códigos contribuidos

### Metadados do node de fundamento
Metadados do fundamento de uma estrutura (todos são armazenados no formato de strings)
* "vila" : numero da vila correspondente (exemplo: "12")
* "tipo" : nome do tipo de estrutura (exemplo: "casa")
* "dist" : distância do centro até a borda em blocos (exemplo: "3")

### Dados estáticos de entidades
* variaveis da engine : Variaveis reservadas pela engine mobs_redo (veja a documentação da engine)
* `tipo` : Nome do tipo de npc suno
* `loop` : Controle de temporizador
* `temp` : Temporizador gerenciado pelo mod sunos
* `mypos` : Coordenada do node de origem
* `mynode` : Nome do node onde o npc spawnou

### Metadados de spawner
* `"sunos_npc_checkin_"..time`: Armazena tabelas de dados serializados
  * time varia de 0 a 23
  * Estrutura dos dados
    {
        ["x y z"] = { -- coordenada do node que registrou o checkin e que registra em si mesmo o NPC
            nodename = "itemstring", -- do node que registrou o checkin
        },
        ["x y z"] = {
            nodename = "itemstring",
        },
    }

### Metadados de nodes de NPCs
* `"sunos_npchash"` : Hash do NPC
* `"sunos_npc_tipo"` : Tipo do NPC registrado nos sunos
* `"sunos_mynpc_checkin"`: Armazena tabelas de dados serializados
  * Estrutura dos dados
    {
        checkin = { -- Tabel a de checkins
            ["0"] = {x=0, y=0, z=0}, -- Index é a hora em formato string e armazena a tabela pos do node spawner
            ["1"] = {x=0, y=0, z=0},
            ["2"] = {x=0, y=0, z=0},
        }
    }

Métodos Auxiliares
------------------

* `minetest.get_node_light(pos, timeofday)`
    * Gets the light value at the given position. Note that the light value
      "inside" the node at the given position is returned, so you usually want
      to get the light value of a neighbor.
    * `pos`: The position where to measure the light.
    * `timeofday`: `nil` for current time, `0` for night, `0.5` for day
    * Returns a number between `0` and `15` or `nil`
    
* `sunos.montar_estrutura(pos, dist, tipo, rotat)`
    * Monta uma estrutura aleatoria de um `tipo` definido dentre as estruturas salvas no formato esquemático
    * `pos` é a coordenada do centro do chão da estrutura
    * `dist` é a distancia do centro até a borda
    * `rotat` é a rotação opcional da estrutura ("0", "90", "180" ou "270")
    * Retorna um valor booleano `true` e `arquivo esquemático` se ocorrer corretamente 
    * Ocorre uma troca de itens durante a montagem da estrutura conforme definido em `sunos.var.nodes_trocados`
