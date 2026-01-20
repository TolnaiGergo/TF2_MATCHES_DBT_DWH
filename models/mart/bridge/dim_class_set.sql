WITH classes_set AS 
(
    SELECT seq4() as classes_played
    FROM table(generator(ROWCOUNT => 512))
)
SELECT classes_played
FROM classes_set