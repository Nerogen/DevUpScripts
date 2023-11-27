"""
CREATE DATABASE IF NOT EXIST jundb;

CREATE TABLE credit_cards_numbers( record_id INT NOT NULL PRIMARY KEY, name varchar(50) NOT NULL, speciality varchar(50) NOT NULL);

INSERT INTO credit_cards_numbers (record_id, name, speciality) VALUES (1, 'Oleg', 'somelue'), (2, 'Vasya', 'python'), (3, 'Lena', 'ux');
"""
