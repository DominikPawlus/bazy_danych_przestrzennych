CREATE EXTENSION postgis;
CREATE EXTENSION postgis_raster;

-- 2

SELECT * FROM rasters.uk_250k;

-- a

ALTER TABLE rasters.uk_250k
ADD COLUMN rid SERIAL PRIMARY KEY;

-- b

CREATE INDEX idx_uk_250k ON rasters.uk_250k
USING gist (ST_ConvexHull(rast));

-- c

SELECT AddRasterConstraints('rasters'::name,
'uk_250k'::name,'rast'::name);


-- 3 

CREATE TABLE rasters.uk_250k_mosaic AS
SELECT ST_Union(r.rast)
FROM rasters.uk_250k AS r

CREATE TABLE tmp_out AS
SELECT lo_from_bytea(0,
       ST_AsGDALRaster(ST_Union(rast), 'GTiff',  ARRAY['COMPRESS=DEFLATE', 'PREDICTOR=2', 'PZLEVEL=9'])
        ) AS loid
FROM rasters.uk_250k_mosaic;

SELECT lo_export(loid, 'dominikpawlus/Documents/AGH/BDP/lab8/mosaic.tif')
FROM tmp_out;

-- 5

SELECT * FROM vectors.uk_national_parks;

-- 6

CREATE TABLE rasters.uk_lake_district AS
SELECT r.rid, ST_Clip(r.rast, u.wkb_geometry, true) AS rast, u.id
FROM rasters.uk_250k AS r, vectors.uk_national_parks AS u
WHERE ST_Intersects(r.rast, u.wkb_geometry) AND u.id = 1;

SELECT UpdateRasterSRID('rasters','uk_lake_district','rast', 27700);

DROP TABLE rasters.uk_lake_district

-- 7

CREATE TABLE tmp_out AS
SELECT lo_from_bytea(0,
       ST_AsGDALRaster(ST_Union(rast), 'GTiff',  ARRAY['COMPRESS=DEFLATE', 'PREDICTOR=2', 'PZLEVEL=9'])
        ) AS loid
FROM rasters.uk_lake_district;

SELECT lo_export(loid, 'dominikpawlus/Documents/AGH/BDP/lab8/lake.tif')
FROM tmp_out;

-- 9

SELECT * FROM rasters.sentinel2


-- 10

DROP TABLE rasters.sentinel2_ndvi

SELECT * FROM rasters.sentinel2_ndvi

CREATE TABLE rasters.sentinel2_ndvi AS
WITH r AS (
	SELECT r.rid, r.rast AS rast
	FROM rasters.sentinel2 AS r
)
SELECT
	r.rid, ST_MapAlgebra(
		r.rast, 8,
		r.rast, 4,
		'([rast2.val] - [rast1.val]) / ([rast2.val] + [rast1.val])::float','32BF'
	) AS rast
FROM r;

ALTER TABLE rasters.sentinel2_ndvi
ADD COLUMN rid SERIAL PRIMARY KEY;

CREATE INDEX idx_sentinel2_ndvi ON rasters.sentinel2_ndvi
USING gist (ST_ConvexHull(rast));

SELECT AddRasterConstraints('rasters'::name,
'sentinel2_ndvi'::name,'rast'::name);

-- 11

CREATE TABLE tmp_out AS
SELECT lo_from_bytea(0,
       ST_AsGDALRaster(ST_Union(rast), 'GTiff',  ARRAY['COMPRESS=DEFLATE', 'PREDICTOR=2', 'PZLEVEL=9'])
        ) AS loid
FROM rasters.sentinel2_ndvi;

SELECT lo_export(loid, 'dominikpawlus/Documents/AGH/BDP/lab8/lake_ndvi.tif')
FROM tmp_out;

SELECT lo_unlink(loid)
FROM tmp_out;

DROP TABLE tmp_out;