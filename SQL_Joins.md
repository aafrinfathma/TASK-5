# SQL Joins & Relationships — Study Guide

This document summarizes SQL join types and key relationship concepts with explanations and examples using the **Indian Unicorns Analytics** schema.

---

## 🔹 1. Database Relationships

- **One-to-Many (1 → ∞):** One startup → many funding rounds.
- **Many-to-One (∞ → 1):** Many funding rounds → one startup.
- **Many-to-Many (∞ ↔ ∞):** Many investors ↔ many funding rounds (via `round_participants`).

---

## 🔹 2. Core Joins

### INNER JOIN
- Returns rows that match in both tables.
```sql
SELECT s.name, i.industry_name
FROM startups s
INNER JOIN industries i ON s.industry_id = i.industry_id;
```

### LEFT JOIN (LEFT OUTER JOIN)
- Returns all rows from left, and matches from right if they exist.
```sql
SELECT s.name, e.exit_type
FROM startups s
LEFT JOIN exits e ON s.startup_id = e.startup_id;
```

### RIGHT JOIN (RIGHT OUTER JOIN)
- Returns all rows from right, with matches from left if they exist.
```sql
SELECT inv.name, fr.round_type
FROM funding_rounds fr
RIGHT JOIN investors inv ON fr.lead_investor_id = inv.investor_id;
```

### FULL OUTER JOIN
- Returns all rows from both sides, with NULLs for non-matches.  
- Not supported directly in MySQL — use `UNION` of LEFT + RIGHT joins.

---

## 🔹 3. Special Joins

### CROSS JOIN
- Cartesian product (all combinations).  
```sql
SELECT i.industry_name, l.region
FROM industries i
CROSS JOIN (SELECT DISTINCT region FROM locations) l;
```

### SELF JOIN
- Table joined to itself (compare rows).  
```sql
SELECT s1.name, s2.name, i.industry_name
FROM startups s1
JOIN startups s2 ON s1.industry_id = s2.industry_id
  AND s1.startup_id < s2.startup_id
JOIN industries i ON s1.industry_id = i.industry_id;
```

### SEMI JOIN
- Return rows from left table if a match exists on the right (no duplicates).  
```sql
SELECT s.startup_id, s.name
FROM startups s
WHERE EXISTS (SELECT 1 FROM funding_rounds fr WHERE fr.startup_id = s.startup_id);
```

### ANTI JOIN
- Return rows from left table with **no match** on right.  
```sql
SELECT s.startup_id, s.name
FROM startups s
LEFT JOIN funding_rounds fr ON s.startup_id = fr.startup_id
WHERE fr.round_id IS NULL;
```

### NATURAL JOIN
- Joins automatically on same-named columns. Risky, not recommended.
```sql
SELECT s.name, fr.round_type
FROM startups s
NATURAL JOIN funding_rounds fr;
```

### NON-EQUI JOIN
- Joins using `<, >, BETWEEN` instead of `=`.  
- Useful for ranges and time validity.
```sql
-- Funding rounds classified into buckets
SELECT fr.round_id, fr.raised_amount_usd, b.bucket_name
FROM funding_rounds fr
JOIN buckets b ON fr.raised_amount_usd BETWEEN b.min_amt AND b.max_amt;
```

---

## 🔹 4. IN, EXISTS, and their opposites

### EXISTS vs IN vs JOIN (finding startups with funding)
```sql
-- JOIN
SELECT DISTINCT s.startup_id, s.name
FROM startups s
JOIN funding_rounds fr ON s.startup_id = fr.startup_id;

-- IN
SELECT s.startup_id, s.name
FROM startups s
WHERE s.startup_id IN (SELECT fr.startup_id FROM funding_rounds fr);

-- EXISTS
SELECT s.startup_id, s.name
FROM startups s
WHERE EXISTS (SELECT 1 FROM funding_rounds fr WHERE fr.startup_id = s.startup_id);
```

### NOT EXISTS vs NOT IN vs LEFT JOIN IS NULL (finding startups without funding)
```sql
-- NOT IN (unsafe if NULLs exist)
SELECT s.startup_id, s.name
FROM startups s
WHERE s.startup_id NOT IN (SELECT fr.startup_id FROM funding_rounds fr);

-- NOT EXISTS (safest)
SELECT s.startup_id, s.name
FROM startups s
WHERE NOT EXISTS (SELECT 1 FROM funding_rounds fr WHERE fr.startup_id = s.startup_id);

-- LEFT JOIN IS NULL (common style)
SELECT s.startup_id, s.name
FROM startups s
LEFT JOIN funding_rounds fr ON s.startup_id = fr.startup_id
WHERE fr.round_id IS NULL;
```

---

## 🔹 5. Practical Notes

- **Use INNER JOIN** when you only want matching data.
- **Use LEFT JOIN** to keep all left rows even if no match exists.
- **Use EXISTS** for efficient existence checks.
- **Use NOT EXISTS / LEFT JOIN IS NULL** for "no match" queries.
- **Avoid NATURAL JOIN** in production (unpredictable if schema changes).
- **Know NON-EQUI JOIN** for ranges and time-based validity.

---

