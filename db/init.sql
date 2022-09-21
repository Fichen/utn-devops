use sampleDB;


create table
  players (
    id int not null AUTO_INCREMENT,
    firstName varchar (50) not null,
    lastName varchar (50) not null,
    birthday bigint unsigned not null,
    PRIMARY KEY (id)
  ) DEFAULT CHARACTER
SET
  utf8 COLLATE utf8_general_ci;


insert into
  players (firstName, lastName, birthday)
values
  ('Lionel', 'Messi', 5515020000000),
  ('Angel', 'Di Maria', 571806000000);
