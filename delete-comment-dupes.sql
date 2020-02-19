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
      comments
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
  , tables AS (
    SELECT
      table_name
    FROM
      all_tab_columns
    WHERE
      owner = 'USERLOGINS5'
      AND column_name = 'COMMENT_ID'
  )
SELECT
  'DELETE FROM ' || b.table_name || ' WHERE comment_id = ' || a.id || ';'
FROM
  filtered_group_ids a
  CROSS JOIN tables b
;
