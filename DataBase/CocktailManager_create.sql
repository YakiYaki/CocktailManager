CREATE TABLE "Ингредиенты" (
	"ID" serial NOT NULL UNIQUE,
	"Название" varchar NOT NULL,
	"Описание" TEXT NOT NULL,
	CONSTRAINT Ингредиенты_pk PRIMARY KEY ("ID")
) WITH (
  OIDS=FALSE
);



CREATE TABLE "Параметры" (
	"ID" serial NOT NULL UNIQUE,
	"Имя" integer NOT NULL,
	"ID связи" integer NOT NULL,
	CONSTRAINT Параметры_pk PRIMARY KEY ("ID")
) WITH (
  OIDS=FALSE
);



CREATE TABLE "Коктейли" (
	"ID" serial NOT NULL UNIQUE,
	"Название" varchar NOT NULL,
	"Описание" TEXT NOT NULL,
	"Рецепт" TEXT NOT NULL,
	"Рейтинг" integer NOT NULL,
	CONSTRAINT Коктейли_pk PRIMARY KEY ("ID")
) WITH (
  OIDS=FALSE
);



CREATE TABLE "Предпочтения" (
	"ID" serial NOT NULL UNIQUE,
	"ID пользователя" integer NOT NULL,
	"ID коктейля" integer NOT NULL,
	"Рейтинг" integer NOT NULL,
	CONSTRAINT Предпочтения_pk PRIMARY KEY ("ID")
) WITH (
  OIDS=FALSE
);



CREATE TABLE "Таблица связей" (
	"ID" serial NOT NULL UNIQUE,
	"ID коктейля" integer NOT NULL,
	"ID ингредиента" integer NOT NULL,
	"Количество ингредиентов" integer NOT NULL,
	CONSTRAINT Таблица связей_pk PRIMARY KEY ("ID")
) WITH (
  OIDS=FALSE
);




ALTER TABLE "Параметры" ADD CONSTRAINT "Параметры_fk0" FOREIGN KEY ("ID связи") REFERENCES "Таблица связей"("ID");


ALTER TABLE "Предпочтения" ADD CONSTRAINT "Предпочтения_fk0" FOREIGN KEY ("ID коктейля") REFERENCES "Коктейли"("ID");

ALTER TABLE "Таблица связей" ADD CONSTRAINT "Таблица связей_fk0" FOREIGN KEY ("ID коктейля") REFERENCES "Коктейли"("ID");
ALTER TABLE "Таблица связей" ADD CONSTRAINT "Таблица связей_fk1" FOREIGN KEY ("ID ингредиента") REFERENCES "Ингредиенты"("ID");


