ALTER TABLE "Параметры" DROP CONSTRAINT IF EXISTS "Параметры_fk0";

ALTER TABLE "Предпочтения" DROP CONSTRAINT IF EXISTS "Предпочтения_fk0";

ALTER TABLE "Таблица связей" DROP CONSTRAINT IF EXISTS "Таблица связей_fk0";

ALTER TABLE "Таблица связей" DROP CONSTRAINT IF EXISTS "Таблица связей_fk1";

DROP TABLE IF EXISTS "Ингредиенты";

DROP TABLE IF EXISTS "Параметры";

DROP TABLE IF EXISTS "Коктейли";

DROP TABLE IF EXISTS "Предпочтения";

DROP TABLE IF EXISTS "Таблица связей";

