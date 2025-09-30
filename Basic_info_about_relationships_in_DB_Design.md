Types of Relationships in database design and especially in joins.

One-to-Many (1 → ∞)

Definition: One record in table A can relate to many records in table B, but each record in table B belongs to only one record in table A.

Schema example:

One startup can have many funding_rounds.

In your schema: startups.startup_id → funding_rounds.startup_id.

Visual:

Startup(1) ----> (many) Funding_Rounds


Why: Because each funding round belongs to exactly one startup, but a startup can raise multiple rounds.

🔹 Many-to-One (∞ → 1)

Definition: Just the reverse perspective of one-to-many. Many records in table A map back to a single record in table B.

Schema example:

Many funding_rounds belong to one startup.

Visual:

Funding_Rounds(many) ----> (1) Startup


Why: It’s just flipping the direction of the same relationship.

🔹 Many-to-Many (∞ ↔ ∞)

Definition: Many records in table A can be linked to many records in table B. This usually needs a junction (bridge) table to break it down into two one-to-many relationships.

Schema example:

A funding_round can have many investors (participants).

An investor can participate in **many funding_rounds`.

The link is stored in the round_participants table.

Visual:

Funding_Round(many) <--> (many) Investor


Implemented as:

Funding_Round(1) ----> (many) Round_Participants <---- (many) Investor(1)


✅ Summary in plain words:

One-to-many: A parent with multiple children (e.g., one startup → many funding rounds).

Many-to-one: Many children sharing the same parent (e.g., many funding rounds → one startup).

Many-to-many: A relationship where both sides can have multiple connections (e.g., many investors ↔ many rounds).