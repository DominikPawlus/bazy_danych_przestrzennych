CREATE EXTENSION postgis;

CREATE EXTENSION postgis;

-- 1

SELECT * FROM T2019_BUILDINGS AS B19, T2018_BUILDINGS AS B18
WHERE B19.polygon_id = B18.polygon_id AND ST_Equals(B19.geom, B18.geom) = false


-- 2

SELECT * FROM T2019_POI
SELECT * FROM T2018_POI

SELECT DISTINCT(P19.geom) FROM T2019_POI as P19, T2019_BUILDINGS as B19, T2018_BUILDINGS as B18
WHERE P19.poi_id NOT IN (
	SELECT P18.poi_id FROM T2018_POI AS P18
) AND ST_DWithin(P19.geom, B19.geom, 500) AND B19.polygon_id = B18.polygon_id AND ST_Equals(B19.geom, B18.geom) = false


-- 3


CREATE TABLE streets_reprojected AS (
	SELECT gid, link_id, st_name, ref_in_id, nref_in_id, func_class, speed_cat, fr_speed_l, to_speed_l, dir_travel, ST_Transform(geom, 3068) as geom
	FROM T2019_STREETS
)


SELECT * FROM streets_reprojected

-- 4

CREATE TABLE input_points (
	p_id INT PRIMARY KEY,
	geom GEOMETRY
)


INSERT INTO input_points(p_id, geom)
	VALUES (1, ST_GeomFromText('POINT(8.36093 49.03174)', 4326)), (2, ST_GeomFromText('POINT(8.39876 49.00644)', 4326));
	
SELECT * FROM input_points
DROP TABLE input_points

-- 5

UPDATE input_points SET geom = ST_Transform(geom, 3068);
ALTER TABLE input_points ALTER COLUMN geom TYPE geometry(POINT, 3068);

SELECT
	p_id,
	ST_AsText(geom)
FROM input_points

-- 6

SELECT * FROM T2019_STREET_NODE AS SN
WHERE
	ST_DWithin(ST_Transform(ST_SETSRID(SN.geom,4326), 3068), (SELECT ST_MakeLine(P.geom) FROM input_points AS P), 200) AND
	SN.intersect = 'Y';

-- 7

SELECT
	COUNT(DISTINCT(poi.gid))
FROM T2019_POI as poi, T2019_LAND_USE_A as land_use
WHERE
	poi.type = 'Sporting Goods Store' AND
	ST_DWithin(poi.geom, land_use.geom, 300) AND
	land_use.type = 'Park (City/County)'


-- 8

CREATE TABLE T2019_BRIDGES AS (
	SELECT DISTINCT(ST_Intersection(R.geom, W.geom))
	FROM T2019_RAILWAYS AS R, T2019_WATER_LINES AS W
)

SELECT * FROM T2019_BRIDGES