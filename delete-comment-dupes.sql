WITH
    comparable AS (
        SELECT
            comment_id,
            comment_target_id,
            COALESCE(location_string, '') as location_string,
            COALESCE(organism, '') as organism,
            stable_id,
            user_id,
            COALESCE(email, '') as email,
            project_name,
            COALESCE(prev_comment_id, 0) as prev_comment_id,
            headline,
            DBMS_LOB.SUBSTR(content, 4000, 1) as conhash
        FROM
            userlogins5.comments
        WHERE
                is_visible = 1
    )
  , dupes AS (
    SELECT
        MIN(comment_id) AS first,
        listagg(comment_id, ',') WITHIN GROUP (ORDER BY comment_id) AS comment_ids,
        COUNT(1) AS counts,
        comment_target_id,
        location_string,
        organism,
        stable_id,
        user_id,
        email,
        project_name,
        prev_comment_id,
        headline,
        conhash
    FROM comparable
    GROUP BY
        stable_id,
        user_id,
        comment_target_id,
        prev_comment_id,
        headline,
        location_string,
        organism,
        project_name,
        conhash,
        email
    HAVING
            COUNT(1) > 1
)
  , dupe_group_ids AS (
    SELECT
        first,
        TO_NUMBER(COLUMN_VALUE) AS id
    FROM dupes,
        XMLTABLE(('"' || REPLACE(comment_ids, ',', '","') || '"'))
)
  , filtered_group_ids AS (
    SELECT id
    FROM dupe_group_ids
    WHERE id != first
)
SELECT 'DELETE FROM locations WHERE comment_id = ' || id || ';'
FROM filtered_group_ids
WHERE id IN (SELECT comment_id FROM userlogins5.locations)
UNION
SELECT 'DELETE FROM comment_external_database WHERE comment_id = ' || id || ';'
FROM filtered_group_ids
WHERE id IN (SELECT comment_id FROM userlogins5.comment_external_database)
UNION
SELECT 'DELETE FROM commentreference WHERE comment_id = ' || id || ';'
FROM filtered_group_ids
WHERE id IN (SELECT comment_id FROM userlogins5.commentreference)
UNION
SELECT 'DELETE FROM commentsequence WHERE comment_id = ' || id || ';'
FROM filtered_group_ids
WHERE id IN (SELECT comment_id FROM userlogins5.commentsequence)
UNION
SELECT 'DELETE FROM commentfile WHERE comment_id = ' || id || ';'
FROM filtered_group_ids
WHERE id IN (SELECT comment_id FROM userlogins5.commentfile)
UNION
SELECT 'DELETE FROM commentstableid WHERE comment_id = ' || id || ';'
FROM filtered_group_ids
WHERE id IN (SELECT comment_id FROM userlogins5.commentstableid)
UNION
SELECT 'DELETE FROM commenttargetcategory WHERE comment_id = ' || id || ';'
FROM filtered_group_ids
WHERE id IN (SELECT comment_id FROM userlogins5.commenttargetcategory)
UNION
SELECT 'DELETE FROM comments WHERE comment_id = ' || id || ';'
FROM filtered_group_ids
WHERE id IN (SELECT comment_id FROM userlogins5.comments)
;
