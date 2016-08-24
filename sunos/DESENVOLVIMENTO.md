Sunos
===============

# Arquitetura de dados

O mod memor é usado para gerenciar essas tabelas de dados

## Dados gerais

```lua
geral = {
	vilas = <numero de vilas>
}
```

## Dados da vila

```lua
vila_<numero da vila> = {
	<tipo_estrutura>_<numero da estrutura> = <registro da estrutura>
}
```

### Casa

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
