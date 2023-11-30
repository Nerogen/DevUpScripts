"""
CREATE DATABASE IF NOT EXIST jundb;

CREATE TABLE credit_cards_numbers( record_id INT NOT NULL PRIMARY KEY, name varchar(50) NOT NULL, speciality varchar(50) NOT NULL);

INSERT INTO credit_cards_numbers (record_id, name, speciality) VALUES (1, 'Oleg', 'somelue'), (2, 'Vasya', 'python'), (3, 'Lena', 'ux');
"""

"""
CREATE TABLE credit_cards_numbers (
  id SERIAL PRIMARY KEY,
  card_number VARCHAR(16)
);
"""

"""
INSERT INTO credit_cards_numbers (card_number) VALUES
  ('1234567890123456'),
  ('9876543210987654'),
  ('1111222233334444');
"""

"""
SELECT * FROM credit_cards_numbers;
"""

"""
DROP DATABASE jundb;
"""

"\list" or "\l"
"\c" or "\connect"
"\dt"

"show databases;"
"use 'db_name'"