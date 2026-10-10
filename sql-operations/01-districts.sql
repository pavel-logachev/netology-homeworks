-- Task 1: strictly uppercase K and lowercase a; exclude ASCII spaces.
SELECT DISTINCT district
FROM address
WHERE district COLLATE utf8mb4_bin LIKE 'K%a'
  AND district NOT LIKE '% %'
ORDER BY district;
