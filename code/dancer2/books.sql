create database if not exists books;

use books;

create table if not exists author (
  id integer primary key auto_increment,
  name varchar(100)
) engine innodb;

create table if not exists book (
  id integer primary key auto_increment,
  isbn char(10),
  author integer,
  title varchar(250),
  started datetime,
  ended datetime,
  image_url varchar(250),
  foreign key (author) references author (id)
) engine innodb;

create user 'books'@'localhost' identified by 'README';

grant all privileges on books.* to books;
