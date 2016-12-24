Sunos
===============

Por BrunoMine

Esse mod adiciona os povos sunos ao jogo que aparecem aleatoriamente pelo mapa.
Os sunos (do esperanto, "sol") são povoados humildes que vivem 
em planicies. Não possuem muita habilidade técnica e por isso 
só utilizam materiais simples de encontrar 
(Madeira, Pedras e etc). Leia mais sobre os sunos nó [wiki do projeto](https://github.com/BrunoMine/sociedades/wiki/Sunos)

==================================================================

# Licenças 

### Texturas CC BY-SA 3.0

As atribuições de autoria das texturas estão descritos no 
arquivo `ATRIBUICAO.txt` no diretório de texturas.
  
### Software LGPL v3

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

### Estruturas

As estruturas salvas no formato esquemático de minetest possuem 
sua devida atribuição descrita no arquivo `CATALOGO.md` que acompanha 
os arquivos de mídia correspondentes.

## Comandos

/sunos <func> | Opera algumas funcionalidades

funcionalidades:

- Salvar uma estrutura: `s <tipo> <nome> <largura>`
- Carrega uma estrutura: `c <tipo> <nome> <largura>`

## Configurações

Essas configurações são colocadas em minetest.conf
- `sunos_raridade = 33` (em porcentagem, apenas numeros inteiros, padrão é 33)
- `sunos_verif_fundamento = 10` (tempo em segundos para cada verificação de um fundamento ativo no mapa, padrão é 10)
- `sunos_casa_comunal_decadencia = 300` (tempo em segundos que a casa comunal pode ficar em decadencia, padrão é 300)

## Criar estruturas
Todas as estruturas desse mod devem obedecer aos seguintes parametros:
- Largura e comprimento (vetores x e z) iguais
- Altura (vetor y) de 15 nodes
- Largura de 3, 5, 7, 9, 11 ou 13
- Salvas e armazenadas no formato esquemático de minetest
- Nome do arquivo deve seguir o formato `<nome>.<largura>.mts`
- Descrição feita no arquivo `CATALOGO.md`

Formato para arquivos `CATALOGO.md`:

```md
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
```
