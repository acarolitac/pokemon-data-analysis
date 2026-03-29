-- Projeto: Pokémon Data Analytics --
-- ETL - Transform, Extract and Load --
-- Autor: Ana Carolina Itacarambi --
-- 03/2026 --

-- Criação da tabela no PostgreSQL para, posteriormente, importar os dados do arquivo CSV --
CREATE TABLE pokemon (
    "#" INT,
    "Name" VARCHAR(100),
    "Type 1" VARCHAR(50),
    "Type 2" VARCHAR(50),
    "Total" INT,
    "HP" INT,
    "Attack" INT,
    "Defense" INT,
    "Sp. Atk" INT,
    "Sp. Def" INT,
    "Speed" INT,
    "Generation" INT,
    "Legendary" BOOLEAN
);

-- Renomeando colunas para snake_case para melhorar a legibilidade e eliminar a necessidade de aspas duplas no código
-- Os nomes originais causam case sensitivity

ALTER TABLE pokemon RENAME COLUMN "#" TO pokedex_number;
ALTER TABLE pokemon RENAME COLUMN "Name" TO name;
ALTER TABLE pokemon RENAME COLUMN "Type 1" TO type_1;
ALTER TABLE pokemon RENAME COLUMN "Type 2" TO type_2;
ALTER TABLE pokemon RENAME COLUMN "Total" TO base_stat_total;
ALTER TABLE pokemon RENAME COLUMN "HP" TO hp;
ALTER TABLE pokemon RENAME COLUMN "Attack" TO attack;
ALTER TABLE pokemon RENAME COLUMN "Defense" TO defense;
ALTER TABLE pokemon RENAME COLUMN "Sp. Atk" TO special_attack;
ALTER TABLE pokemon RENAME COLUMN "Sp. Def" TO special_defense;
ALTER TABLE pokemon RENAME COLUMN "Speed" TO speed;
ALTER TABLE pokemon RENAME COLUMN "Generation" TO generation;
ALTER TABLE pokemon RENAME COLUMN "Legendary" TO is_legendary;

-- Verificando Valores Nulos --
SELECT 
    COUNT(*) AS "Total Registros",
    COUNT(*) FILTER (WHERE name IS NULL) AS "Qntd Nome Nulos",
    COUNT(*) FILTER (WHERE type_1 IS NULL) AS "Qntd Type 1 Nulos",
    COUNT(*) FILTER (WHERE type_2 IS NULL) AS "Qntd Type 2 Nulos", -- 386 valores nulos, ou seja, 386 pokémons são mono-type
    COUNT(*) FILTER (WHERE base_stat_total IS NULL) AS "Qntd base_stat_total Nulos",
    COUNT(*) FILTER (WHERE hp IS NULL) AS "Qntd HPs Nulos",
	COUNT(*) FILTER (WHERE attack IS NULL) AS "Qntd Attack Nulos",
	COUNT(*) FILTER (WHERE defense IS NULL) AS "Qntd Defense Nulos",
	COUNT(*) FILTER (WHERE special_attack IS NULL) AS "Qntd special_attack Nulos",
	COUNT(*) FILTER (WHERE special_defense IS NULL) AS "Qntd special_defense Nulos",
	COUNT(*) FILTER (WHERE speed IS NULL) AS "Qntd speed Nulos",
	COUNT(*) FILTER (WHERE generation IS NULL) AS "Qntd Gerações Nulos",
	COUNT(*) FILTER (WHERE is_legendary IS NULL) AS "Qntd is_legendary Nulos"
FROM pokemon;

-- Resultado: Não há valores nulos que comprometam a análise
-- Coluna type_2: 386 registros nulos (comportamento esperado)
-- Representa Pokémon mono-type (apenas tipo primário)
-- Demais colunas: 100% preenchidas

-- Verificação e correção da coluna is_legendary --
SELECT COUNT(is_legendary) 
FROM pokemon 
WHERE is_legendary IS True;
-- Total de TRUE: 65 registros

SELECT name, type_1, type_2, base_stat_total, generation
FROM pokemon
WHERE is_legendary IS True
ORDER BY generation, name;

-- A coluna 'is_legendary, neste dataset, classifica como TRUE pokémons lendários, míticos e alternativos

-- Renomeando a coluna is_legendary para melhor entendimento, visto que ela não retorna apenas pokémons lendários --
ALTER TABLE pokemon RENAME COLUMN is_legendary TO is_special_pokemon;

SELECT name, is_special_pokemon
FROM pokemon
WHERE is_special_pokemon IS True
ORDER BY name;

-- Criando nova coluna para classificar os pokémons especiais em: Lendário, Mítico, Alternativos e Regulares --
ALTER TABLE pokemon 
ADD COLUMN special_category VARCHAR(100);

UPDATE pokemon SET special_category = 'Regular';

UPDATE pokemon SET special_category = CASE 

	WHEN name IN (
		'Arceus',
        'Darkrai',
        'Diancie',
        'DiancieMega Diancie',
        'HoopaHoopa Confined',
        'HoopaHoopa Unbound',
        'Jirachi',
        'ShayminLand Forme',
        'ShayminSky Forme',
        'Victini',
        'Volcanion'
	) THEN 'Mythical'

	 WHEN name IN (
        'Articuno',
        'Azelf',
        'Cobalion',
        'Dialga',
        'Entei',
        'GiratinaAltered Forme',
        'GiratinaOrigin Forme',
        'Groudon',
        'GroudonPrimal Groudon',
        'Heatran',
        'Ho-oh',
        'Kyogre',
        'KyogrePrimal Kyogre',
        'Kyurem',
        'KyuremBlack Kyurem',
        'KyuremWhite Kyurem',
        'LandorusIncarnate Forme',
        'LandorusTherian Forme',
        'Latias',
        'LatiasMega Latias',
        'Latios',
        'LatiosMega Latios',
        'Lugia',
        'Mesprit',
        'Moltres',
        'Palkia',
        'Raikou',
        'Rayquaza',
        'RayquazaMega Rayquaza',
        'Regice',
        'Regigigas',
        'Regirock',
        'Registeel',
        'Reshiram',
        'Suicune',
        'Terrakion',
        'ThundurusIncarnate Forme',
        'ThundurusTherian Forme',
        'TornadusIncarnate Forme',
        'TornadusTherian Forme',
        'Uxie',
        'Virizion',
        'Xerneas',
        'Yveltal',
        'Zapdos',
        'Zekrom',
        'Zygarde50% Forme',
		'Mewtwo', 
		'MewtwoMega Mewtwo X', 
		'MewtwoMega Mewtwo Y'
    ) THEN 'Legendary'

	 WHEN name IN (
        'DeoxysAttack Forme',
        'DeoxysDefense Forme',
        'DeoxysNormal Forme',
        'DeoxysSpeed Forme'
    ) THEN 'Special_Form'

	 ELSE special_category

END
Where is_special_pokemon IS True;

SELECT COUNT(*)
FILTER (WHERE special_category IS NULL) AS "Qntd valores nulos"
FROM pokemon;
-- Não retornou valores nulos, então, o UPDATE deu certo e categorizou todos os pokémons!

-- Verificando se há nomes duplicados --
SELECT name, COUNT(*)
FROM pokemon
GROUP BY name
HAVING COUNT(*) > 1;

-- Verificando pokedex_number duplicados --
SELECT pokedex_number, COUNT(*) AS quantidade
FROM pokemon
GROUP BY pokedex_number
HAVING COUNT(*) > 1;
-- Resultado: Os valores duplicados não comprometem a análise
-- Coluna pokedex_number: 65 registros duplicados (comportamento esperado)
-- Representa pokémons que são especiais (lendário, mítico ou alternativo)

-- Criação de nova tabela com os dados tratados e prontos para análise --
-- Essa tabela será utilizada para a análise no Power BI
-- Fonte para criação de dashboards e KPIs

CREATE TABLE pokemon_clean AS
SELECT
	pokedex_number,
	name,
	type_1,
	type_2,
	base_stat_total,
	hp,
	attack,
	defense,
	special_attack,
	special_defense,
	speed,
	generation,
	is_special_pokemon,
	special_category
FROM pokemon;

-- Verificando se deu tudo certo na criação da nova tabela --
SELECT * FROM pokemon_clean;