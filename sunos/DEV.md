Sunos
===============

## Dados gerais

Esses são dados gerais do mod sunos são armazenados no banco de dados do mod

```lua
geral = {
	vilas = <numero de vilas>
}
```

## Vilas

Esses são os dados que cada vila guarda dela mesma.

```lua
vila_<numero da vila> = {
	numero = <numero da vila>
	<estrutura> = <registros da estrutura>
}
```

## Estruturas

Cada estrutura possui (e precisa possuir para ser ativa) necessariamente:

- Entorno de gramado ou pedregulho
- Fundamento no centro do chão da estrutura

Casa estrutura guarda dados de registro no bando de dados do mod.

### Casas

As casas armazenadas no banco de dados da seguinte maneira.

```lua
casa_<x> = {
	numero = <x>,
	tipo = <tipo>,
	estrutura = {
		dist = <distancia do centro para cada lado>,
		largura = <largura>,
		pos = <coordenada do fundamento>
	}
}
```

### Casa Comunal

```lua
casa_comunal = {
	pos = <coordenada do fundamento>, -- Pos do fundamento
	vila = <número>, -- Numero da vila
	nivel = <nível>, -- Nivel da casa comunal
}
```
