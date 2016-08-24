Sunos
===============

# Arquitetura de dados

O mod memor é usado para gerenciar essas tabelas de dados (use a API do memor para compreender o funcionamento)

## Dados gerais

Esses são dados gerais do mod sunos

```lua
geral = {
	vilas = <numero de vilas>
}
```

## Dados da vila

Esses são os dados que cada vila guarda dela mesma.

```lua
vila_<numero da vila> = {
	<tipo_estrutura>_<numero da estrutura> = <registro da estrutura>
}
```

### Casa

Esses são os dados que cada casa guarda dela mesma.

```lua
casa_x = {
	numero = x,
	tipo = <tipo>,
	estrutura = {
		dist = <distancia do centro para cada lado>,
		largura = <largura>,
		pos = <coordenada do centro no chao da estrutura>
	}
}
```
