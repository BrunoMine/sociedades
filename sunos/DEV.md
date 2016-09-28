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

## Fundamentos

Os fundamentos são blocos que ficam no centro do chão das estruturas e 
possuem os seguintes metadados obrigatórios:

```lua
vila = <numero> -- Numero da vila
tipo = <string> -- Tipo de estrutura
estrutura = <numero> -- Numero da estrutura
dist = <numero> -- Distancia centro a borda
```

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

## NPCs

### NPC Suno Comum

Esse é o típico morador das vilas e possuem os seguintes dados em si mesmos:

```lua
vila = <numero> -- Número da vila
casa = <numero> -- Numero da casa
registro = <pos> -- Pos do bau da casa a qual pertence
}
```

### NPC Casa Comunal

Esse é da casa comunal e possuem os seguintes dados em si mesmos:

```lua
vila = <numero> -- Número da vila
registro = <pos> -- Pos do bau da casa a qual pertence
}
```
