# SQL Joins & Relationships — Study Guide (with Visuals)

This document summarizes SQL join types and key relationship concepts with explanations, examples, and visual diagrams.

---

## 🔹 1. Database Relationships

**One-to-Many (1 → ∞):**
```
Startup (1) ----> (∞) Funding Rounds
```

**Many-to-One (∞ → 1):**
```
Funding Rounds (∞) ----> (1) Startup
```

**Many-to-Many (∞ ↔ ∞):**
```
Funding Round (∞) <----> (∞) Investor
   (via Round Participants bridge table)
```

---

## 🔹 2. Core Joins

### INNER JOIN
**Definition:** Rows must exist in both tables.
```
A:  ● ● ●
B:    ● ● ●
Result: overlap only (intersection)
```

**Example:**
```sql
SELECT s.name, i.industry_name
FROM startups s
INNER JOIN industries i ON s.industry_id = i.industry_id;
```

---

### LEFT JOIN (LEFT OUTER JOIN)
**Definition:** All rows from left + matches from right.
```
A:  ● ● ●
B:    ● ●
Result: ● ● ● (with NULLs where no match in B)
```

**Example:**
```sql
SELECT s.name, e.exit_type
FROM startups s
LEFT JOIN exits e ON s.startup_id = e.startup_id;
```

---

### RIGHT JOIN (RIGHT OUTER JOIN)
**Definition:** All rows from right + matches from left.
```
A:  ● ●
B:    ● ● ●
Result: ● ● ● (with NULLs where no match in A)
```

**Example:**
```sql
SELECT inv.name, fr.round_type
FROM funding_rounds fr
RIGHT JOIN investors inv ON fr.lead_investor_id = inv.investor_id;
```

---

### FULL OUTER JOIN
**Definition:** All rows from both sides, matched where possible.
```
A:  ● ●
B:    ● ●
Result: ● ● ● ● (everything, matches and non-matches)
```

---

## 🔹 3. Special Joins

### CROSS JOIN
**Definition:** Cartesian product (all combinations).
```
A: ● ●
B: ● ● ●
Result: 2 × 3 = 6 rows
```

```sql
SELECT i.industry_name, l.region
FROM industries i
CROSS JOIN (SELECT DISTINCT region FROM locations) l;
```

---

### SELF JOIN
**Definition:** Table joined to itself.
```
s1 ●---● s2   (same table, different aliases)
```

```sql
SELECT s1.name, s2.name, i.industry_name
FROM startups s1
JOIN startups s2 ON s1.industry_id = s2.industry_id
  AND s1.startup_id < s2.startup_id
JOIN industries i ON s1.industry_id = i.industry_id;
```

---

### SEMI JOIN
**Definition:** Return rows from left table if a match exists (no duplicates).
```
A rows where a match in B exists → keep once
```

```sql
SELECT s.startup_id, s.name
FROM startups s
WHERE EXISTS (SELECT 1 FROM funding_rounds fr WHERE fr.startup_id = s.startup_id);
```

---

### ANTI JOIN
**Definition:** Return rows from left with no match on right.
```
A rows with no corresponding row in B → keep
```

```sql
SELECT s.startup_id, s.name
FROM startups s
LEFT JOIN funding_rounds fr ON s.startup_id = fr.startup_id
WHERE fr.round_id IS NULL;
```

---

### NATURAL JOIN
**Definition:** Joins on columns with same names (not recommended).
```
Auto-match by column names
```

```sql
SELECT s.name, fr.round_type
FROM startups s
NATURAL JOIN funding_rounds fr;
```

---

### NON-EQUI JOIN
**Definition:** Joins using <, >, BETWEEN instead of =.

**Example:** Funding rounds into buckets.
```sql
SELECT fr.round_id, fr.raised_amount_usd, b.bucket_name
FROM funding_rounds fr
JOIN buckets b ON fr.raised_amount_usd BETWEEN b.min_amt AND b.max_amt;
```

**Time validity example:**
```sql
SELECT m.startup_id, m.metric_month, m.revenue_usd, p.price_per_user
FROM monthly_metrics m
JOIN pricing_plans p
  ON m.startup_id = p.startup_id
 AND m.metric_month BETWEEN p.start_date AND p.end_date;
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

- **INNER JOIN** → Only matches.  
- **LEFT JOIN** → Keep all left rows, even if no match.  
- **RIGHT JOIN** → Keep all right rows.  
- **FULL OUTER JOIN** → Everything from both sides.  
- **CROSS JOIN** → All combinations.  
- **SELF JOIN** → Compare rows within same table.  
- **SEMI JOIN** → Existence check (like EXISTS).  
- **ANTI JOIN** → Non-existence check (like NOT EXISTS).  
- **NATURAL JOIN** → Auto-match columns with same name (avoid in practice).  
- **NON-EQUI JOIN** → Match ranges (BETWEEN, <, >).  

---

✅ **Bottom line:** Master INNER/LEFT/RIGHT/FULL first. Then learn EXISTS/NOT EXISTS. Understand CROSS, SELF, ANTI, and NON-EQUI joins for advanced use cases.  
