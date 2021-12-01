-- Database: shpdb

-- DROP DATABASE shpdb;

CREATE DATABASE shpdb
    WITH 
    OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'C'
    LC_CTYPE = 'C'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1;
	
CREATE EXTENSION postgis;

-- 4

SELECT popp.* INTO tableB FROM popp, majrivers WHERE st_length(st_shortestline(popp.geom, majrivers.geom)) < 1000 and popp.f_codedesc = 'Building'

-- 5 

SELECT name, geom, elev INTO airportsNew FROM airports;

-- a
-- west
SELECT name FROM airportsNew
  ORDER BY ST_X(geom)
  LIMIT 1;
  
-- east
SELECT name FROM airportsNew
  ORDER BY ST_X(geom) DESC
  LIMIT 1;
  
-- b
INSERT INTO airportsNew 
VALUES ('airportB', (SELECT ST_Centroid (ST_MakeLine(
    (SELECT geom FROM airportsNew WHERE name = 'ATKA'),
    (SELECT geom FROM airportsNew WHERE name = 'ANNETTE ISLAND')))), 300);
	
-- 6
SELECT ST_Area(ST_Buffer(ST_Shortestline(lakes.geom, airports.geom),1000)) FROM lakes lakes, airports airports
	WHERE lakes.names = 'Iliamna Lake' AND airports.name = 'AMBLER';

-- 7
SELECT SUM(ST_Area(tree.geom)), tree.vegdesc FROM trees tree, swamp swamp, tundra tundra
	WHERE ST_Contains(tree.geom, tundra.geom) OR ST_Contains(tree.geom, swamp.geom)
	GROUP BY tree.vegdesc;
