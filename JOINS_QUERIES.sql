USE indian_unicorns_analytics;
-- INNER JOIN — only matching rows from both tables
SELECT s.name AS startup, i.industry_name
FROM startups s
INNER JOIN industries i
  ON s.industry_id = i.industry_id;
-- Pitfall: If you expect a row for every startups row but use INNER JOIN, you’ll lose startups that don’t have an industry record.

-- LEFT JOIN (LEFT OUTER JOIN) — all rows from left table, matches from right
SELECT s.name, e.exit_type, e.exit_date
FROM startups s
LEFT JOIN exits e
  ON s.startup_id = e.startup_id;
-- pitfall (filter placement):
-- A WHERE on a column from the right table turns the LEFT JOIN into an INNER JOIN because WHERE right_col = ... removes NULL rows.

-- Wrong (unexpectedly becomes INNER):

SELECT s.name
FROM startups s
LEFT JOIN exits e ON s.startup_id = e.startup_id
WHERE e.exit_type = 'ipo';   -- removes rows with e.* IS NULL


-- Right (keep left rows, only attach IPO rows):

SELECT s.name, e.exit_date
FROM startups s
LEFT JOIN exits e
  ON s.startup_id = e.startup_id AND e.exit_type = 'ipo';
  
--  RIGHT JOIN (RIGHT OUTER JOIN) — all rows from right table, matches from left
SELECT inv.name AS investor, fr.round_type, fr.raised_amount_usd
FROM funding_rounds fr
RIGHT JOIN investors inv
  ON fr.lead_investor_id = inv.investor_id;
  
-- FULL OUTER JOIN — all rows from both tables, matched where possible
-- What it returns: union of LEFT and RIGHT: all rows from both tables; unmatched side columns are NULL.
-- Support: PostgreSQL, SQL Server and others support FULL OUTER JOIN. MySQL (pre-8 / common MySQL) does not support FULL OUTER JOIN directly — use a UNION workaround.
-- rows where startup exists (with or without exit)
SELECT s.startup_id, s.name, e.exit_type, e.exit_date
FROM startups s
LEFT JOIN exits e ON s.startup_id = e.startup_id

UNION

-- rows where exit exists but startup row is missing (rare here because exit.startup_id is FK)
SELECT s.startup_id, s.name, e.exit_type, e.exit_date
FROM startups s
RIGHT JOIN exits e ON s.startup_id = e.startup_id;

-- CROSS JOIN : Takes every row from table A and pairs it with every row from table B.
-- No condition is required.
-- each row of A paired with every row of B (A × B).
-- Typical use: generate combinations, test scenarios, or when intentionally pairing two independent sets. 
-- Use with caution — result size = rows(A) * rows(B).
SELECT i.industry_name, l.region
FROM industries i
CROSS JOIN (SELECT DISTINCT region FROM locations WHERE region IS NOT NULL) l;

-- SELF JOIN — joining a table to itself
-- lets you compare rows within the same table by using aliases (t1, t2).
-- Use cases: pairs in same category, hierarchical relationships (parent/child stored in same table), find duplicates, or nearest-neighbor comparisons.
SELECT s1.name AS startup_a, s2.name AS startup_b, i.industry_name
FROM startups s1
INNER JOIN startups s2
  ON s1.industry_id = s2.industry_id
 AND s1.startup_id < s2.startup_id   -- avoid duplicate reversed pairs and self-pair
INNER JOIN industries i
  ON s1.industry_id = i.industry_id;
  
-- NATURAL JOIN: automatically joins on all columns that have the same name in both tables.
-- Dangerous — it can silently add join columns if schema changes. Avoid in production.
-- USING(col): safer — explicitly lists a common column to join on and returns that column only once in the result set. 
SELECT s.name, fr.round_type, fr.raised_amount_usd
FROM funding_rounds fr
JOIN startups s USING (startup_id);

-- SEMI-JOIN (IN / EXISTS) — return left rows that have at least one match on the right
-- you get rows from left where a matching row exists on the right; 
-- you don’t get repeated rows based on number of matches. Implemented via EXISTS or IN
SELECT s.startup_id, s.name
FROM startups s
WHERE EXISTS (
  SELECT 1 FROM funding_rounds fr WHERE fr.startup_id = s.startup_id
);

-- IN Example
SELECT s.startup_id, s.name
FROM startups s
WHERE s.startup_id IN (SELECT startup_id FROM funding_rounds);
-- EXISTS often performs better when the subquery is correlated and when the right-side returns many rows. 
-- IN can be simpler but be careful with NULL values and large intermediate sets.

-- ANTI-JOIN — rows from left with NO matching row on right
-- Common pattern: LEFT JOIN ... WHERE right.key IS NULL or NOT EXISTS
-- LEFT JOIN + IS NULL
SELECT s.startup_id, s.name
FROM startups s
LEFT JOIN exits e ON s.startup_id = e.startup_id
WHERE e.exit_id IS NULL;

-- OR NOT EXISTS version (often preferred)
SELECT s.startup_id, s.name
FROM startups s
WHERE NOT EXISTS (
  SELECT 1 FROM exits e WHERE e.startup_id = s.startup_id
);

-- NON-EQUI JOIN (range joins) — join with <, >, BETWEEN
-- Use-case: when a row from A should match rows in B if a value falls into a range (e.g., bucketizing amounts).
-- Derived "buckets" table
SELECT fr.round_id, fr.raised_amount_usd, b.bucket_name
FROM funding_rounds fr
JOIN (
  SELECT 0 AS min_amt, 1000000 AS max_amt, 'under_1M' AS bucket_name
  UNION ALL
  SELECT 1000001, 10000000, '1M_to_10M' AS bucket_name
  UNION ALL
  SELECT 10000001, 100000000, '10M_to_100M' AS bucket_name
  UNION ALL
  SELECT 100000001,200000000, '100M_to_200M' AS bucket_name
  UNION ALL
  SELECT 200000001,300000000, '200M_to_300M' AS bucket_name
  UNION ALL
  SELECT 300000001,400000000, '300M_to_400M' AS bucket_name
  UNION ALL
  SELECT 400000001,500000000, '400M_to_500M' AS bucket_name
  UNION ALL
  SELECT 500000001,600000000, '500M_to_600M' AS bucket_name
  UNION ALL
  SELECT 600000001,700000000, '600M_to_700M' AS bucket_name
) b
  ON fr.raised_amount_usd BETWEEN b.min_amt AND b.max_amt;




