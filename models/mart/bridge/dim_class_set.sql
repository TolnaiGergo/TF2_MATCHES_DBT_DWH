WITH classes_set AS 
(
    SELECT seq4() as classes_played
    FROM table(generator(ROWCOUNT => 512))
)
SELECT classes_played,
    {{ generate_audit_metadata() }}
FROM classes_set