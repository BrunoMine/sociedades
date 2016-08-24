Sunos
===============

Por BrunoMine

Esse mod adiciona os povos sunos ao jogo.
Eles aparecem aleatoriamente

# Sobre os Sunos
Os sunos (do esperanto, "sol") são povoados humildes que vivem 
em planicies. Não possuem muita habilidade técnica e por isso 
só utilizam materiais simples de encontrar 
(Madeira, Pedras e etc). Suas casas possuem materiais 
predominantemente de madeira comum e muitas janelas para que a 
luz do sol entre no interior da casa.
Recipientes, estantes, flores e fornos são muito comuns de serem 
encontrados nas casas dos sunos.

==================================================================

### Licenças 

Software LGPL v3

Sunos é um software livre; você pode redistribuí-lo e/ou 
modificá-lo dentro dos termos da Licença Pública Geral Menor GNU 
como publicada pela Fundação do Software Livre (FSF); na versão 3 
da Licença, ou (na sua opinião) qualquer versão.
Este programa é distribuído na esperança de que possa ser útil, 
mas SEM NENHUMA GARANTIA; sem uma garantia implícita de ADEQUAÇÃO
a qualquer MERCADO ou APLICAÇÃO EM PARTICULAR. Veja a
Licença Pública Geral Menor GNU para maiores detalhes.
Você deve ter recebido uma cópia da Licença Pública 
Geral Menor GNU junto com este programa, 
se não, veja <http://www.gnu.org/licenses/>.

## Comandos

/sunos <func> | Opera algumas funcionalidades

funcionalidades:

- Salvar uma estrutura: `s <tipo> <nome> <largura>`

## Estruturas

### Criar
Todas as estruturas tem largura e comprimento iguais e altura
maxima de 15.
As estruturas são salvas no modo schematic do minetest dentro 
a pasta `estruturas` dentro da pasta de sua desiginação 
(casa, decor e etc).
O nome do arquivo deve seguir a regra:
`<nome>.<largura>.mts`
Todas as estruturas devem ser mencionadas no arquivo CATALOGO.md 
de documentação de estruturas dentro da pasta do tipo referente às 
estruturas no seguinte formato:

	Estruturas:
		<Nomde de um arquivo>
		<Nome de outro arquivo>
		<Nome de mais outro arquivo>
	Autor: <Nome>
	Data: <Data de termino>
	Licença: <Licença>
	Nodes: <OPCIONAL>
		<ID de um node>
		<ID de outro node>
		<ID de mais outro node>
	Descrição: <OPCIONAL para descrever como funciona a estrutura>

Ao montar uma estrutura para os sunos, certifique-se de que esteja seguindo 
os parâmetros culturais estabelecidos para essa sociedade.

### Casas

Podem ter largura de 5, 7 ou 9 blocos de largura.
Devem ficar na pasta `casa` de estruturas.

### Estruturas decorativas

Podem ter largura de 3, 5, 7 ou 9 blocos de largura.
Devem ficar na pasta `decor` de estruturas.

