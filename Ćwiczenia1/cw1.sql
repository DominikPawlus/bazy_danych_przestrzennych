-- 2

CREATE DATABASE gisdb
    WITH 
    OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'C'
    LC_CTYPE = 'C'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1;

--3 

CREATE EXTENSION postgis;

-- 4

CREATE TABLE buildings(building_id SERIAL PRIMARY KEY, geometry geometry, building_name name);
CREATE TABLE roads(road_id SERIAL PRIMARY KEY, geometry geometry, road_name name);
CREATE TABLE poi(point_id SERIAL PRIMARY KEY, geometry geometry, point_name name);

-- 5

INSERT INTO poi(geometry, point_name) VALUES(st_geomfromtext('POINT(1 3.5)', -1), 'G');
INSERT INTO poi(geometry, point_name) VALUES(st_geomfromtext('POINT(5.5 1.5)', -1), 'H');
INSERT INTO poi(geometry, point_name) VALUES(st_geomfromtext('POINT(9.5 6)', -1), 'I');
INSERT INTO poi(geometry, point_name) VALUES(st_geomfromtext('POINT(6.5 6)', -1), 'J');
INSERT INTO poi(geometry, point_name) VALUES(st_geomfromtext('POINT(6 9.5)', -1), 'K');


INSERT INTO roads(geometry, road_name) VALUES(st_geomfromtext('LINESTRING(0 4.5, 12 4.5)', -1), 'RoadX');
INSERT INTO roads(geometry, road_name) VALUES(st_geomfromtext('LINESTRING(7.5 0, 7.5 10.5)', -1), 'RoadY');

INSERT INTO buildings(geometry, building_name) VALUES(st_geomfromtext('POLYGON((8 4, 10.5 4, 10.5 1.5, 8 1.5, 8 4))', -1), 'BuildingA');
INSERT INTO buildings(geometry, building_name) VALUES(st_geomfromtext('POLYGON((4 7, 6 7, 6 5, 4 5, 4 7))', -1), 'BuildingB');
INSERT INTO buildings(geometry, building_name) VALUES(st_geomfromtext('POLYGON((3 8, 5 8, 5 6, 3 6, 3 8))', -1), 'BuildingC');
INSERT INTO buildings(geometry, building_name) VALUES(st_geomfromtext('POLYGON((9 9, 10 9, 10 8, 9 8, 9 9))', -1), 'BuildingD');
INSERT INTO buildings(geometry, building_name) VALUES(st_geomfromtext('POLYGON((1 2, 2 2, 2 1, 1 1, 1 2))', -1), 'BuildingF');

-- 6
-- a
SELECT sum(st_length(geometry)) FROM roads;

--b
SELECT ST_GeometryType(geometry), ST_Area(geometry), ST_Perimeter(geometry) FROM buildings WHERE building_name = 'BuildingA';

--c
SELECT building_name, ST_Area(geometry) FROM buildings ORDER BY building_name;

--d
SELECT building_name, ST_Perimeter(geometry) FROM buildings ORDER BY ST_Perimeter(geometry) DESC LIMIT 2;

--e
 SELECT ST_Length(ST_Shortestline(buildings.geometry, poi.geometry)) FROM buildings, poi
    WHERE buildings.building_name = 'BuildingC' AND poi.point_name = 'G';
	
-- f
SELECT ST_Area(ST_Difference(m.geometry, ST_Buffer(t.geometry, 0.5) )) FROM buildings t, buildings m
	WHERE t.building_name = 'BuildingB' AND m.building_name = 'BuildingC'
	
-- g
SELECT building_name FROM buildings
	WHERE ST_Y(ST_Centroid(buildings.geometry)) > ST_Y(ST_PointN((SELECT geometry FROM roads WHERE road_name = 'RoadX'), 1));
	
SELECT ST_Area(ST_SymDifference(buildings.geometry, ST_GeomFromText('POLYGON((4 7, 6 7, 6 8, 4 8, 4 7))', 0))) FROM buildings
WHERE building_name = 'BuildingC';



