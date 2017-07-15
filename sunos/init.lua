--[[
	Mod Sunos para Minetest
	Copyright (C) 2017 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Inicializador de scripts
  ]]

-- Tabela global
sunos = {}

-- Versão do projeto
sunos.versao = "2.0"

-- Versoes compativeis
sunos.versao_comp = {}

-- Notificador de Inicializador
local notificar = function(msg)
	if minetest.setting_get("log_mods") then
		minetest.debug("[SUNOS]"..msg)
	end
end

-- Modpath
local modpath = minetest.get_modpath("sunos")


-- Tabela de estruturas e funções
sunos.estruturas = {}

-- Carregar scripts
notificar("Carregando...")
-- Metodos gerais
dofile(modpath.."/tradutor.lua")
dofile(modpath.."/banco_de_dados.lua")
dofile(modpath.."/checkvar.lua")
dofile(modpath.."/online.lua")
dofile(modpath.."/rollback.lua")
dofile(modpath.."/diretrizes.lua")
dofile(modpath.."/comum.lua")
dofile(modpath.."/estrutural.lua")
dofile(modpath.."/verif_terreno.lua")
dofile(modpath.."/verif_estrutura.lua")
dofile(modpath.."/estruturador.lua")
dofile(modpath.."/vila.lua")
dofile(modpath.."/mapgen.lua")
dofile(modpath.."/gerenciador_de_vilas.lua")
dofile(modpath.."/inimigos.lua")
dofile(modpath.."/verif_defesa.lua")
dofile(modpath.."/verif_ataques.lua")
dofile(modpath.."/compatibilidade.lua")
dofile(modpath.."/editor_schems.lua")
dofile(modpath.."/caixa_de_area.lua")
dofile(modpath.."/ajuste_fornos.lua")
dofile(modpath.."/ajuste_estantes.lua")
dofile(modpath.."/rua_manip.lua")
dofile(modpath.."/ajuste_jogador.lua")
dofile(modpath.."/verif_pop.lua")
dofile(modpath.."/planificador.lua")
dofile(modpath.."/troca.lua")
-- Nodes
dofile(modpath.."/nodes/estantes_nodrop.lua")
dofile(modpath.."/nodes/rua.lua")
dofile(modpath.."/nodes/fundamento.lua")
dofile(modpath.."/nodes/decor_repo.lua")
dofile(modpath.."/nodes/bancada.lua")
dofile(modpath.."/nodes/bancada_de_trabalho.lua")
dofile(modpath.."/nodes/compost.lua")
dofile(modpath.."/nodes/bau.lua")
dofile(modpath.."/nodes/carpete.lua")
dofile(modpath.."/nodes/tear.lua")
dofile(modpath.."/nodes/kit_culinario.lua")
dofile(modpath.."/nodes/vendas.lua")
-- Craftitens
dofile(modpath.."/craftitens/kit_reparador.lua")
dofile(modpath.."/craftitens/broa_de_frutas.lua")
dofile(modpath.."/craftitens/salada_de_frutas.lua")
-- Outros Recursos
dofile(modpath.."/comandos.lua")
-- NPCs e interface basica
sunos.npcs = {} -- Tabela global de NPCs
dofile(modpath.."/npc/npc.lua")
-- Estruturas básicas
dofile(modpath.."/estruturas/comunal/init.lua")
dofile(modpath.."/estruturas/casa/init.lua")
dofile(modpath.."/estruturas/decor/init.lua")
-- Estruturas adicionais
dofile(modpath.."/estruturas/loja/init.lua")
dofile(modpath.."/estruturas/emporio/init.lua")
dofile(modpath.."/estruturas/taverna/init.lua")
notificar("[OK]!")
