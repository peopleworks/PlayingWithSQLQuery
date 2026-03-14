/*
Purpose:
- Generate random latitude and longitude points around a central coordinate.

Customization:
- Replace the sample central coordinates, radius, and number of points before execution.
*/

-- Define the central point and search radius.
DECLARE @central_lat FLOAT = 18.450555555556;
DECLARE @central_lon FLOAT = -66.538611111111;
DECLARE @radius FLOAT = 0.01;

-- Create the table to store the generated points.
CREATE TABLE RandomCoordinates (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    Latitude FLOAT,
    Longitude FLOAT
);

-- Generate random latitude and longitude points within the radius.
DECLARE @i INT = 0;
DECLARE @num_points INT = 8000;

WHILE @i < @num_points
BEGIN
    DECLARE @rand_lat FLOAT = (@central_lat + ((RAND() - 0.5) * 2 * @radius));
    DECLARE @rand_lon FLOAT = (@central_lon + ((RAND() - 0.5) * 2 * @radius));

    INSERT INTO RandomCoordinates (Latitude, Longitude)
    VALUES (@rand_lat, @rand_lon);

    SET @i = @i + 1;
END;

-- Review the generated coordinates.
SELECT *
FROM RandomCoordinates;
