CREATE AGGREGATE array_accum (
    sfunc = array_append,
    basetype = anyelement,
    stype = anyarray,
    initcond = '{}'
);


CREATE AGGREGATE array_accum_cat(
  BASETYPE=anyarray,
  SFUNC=array_cat,
  STYPE=anyarray,
  INITCOND='{}'
);


CREATE OR REPLACE FUNCTION array_to_relation(anyarray)
  RETURNS SETOF anyelement AS
$BODY$
DECLARE
    i int;
    n int;
BEGIN
    n := coalesce(array_upper($1, 1), 0);
    i := 1;

    LOOP
       IF i > n THEN
          EXIT;
       END IF;
       RETURN NEXT $1[i];
       i := i + 1;
    END LOOP;
    RETURN;
END
$BODY$
  LANGUAGE 'plpgsql' IMMUTABLE;

