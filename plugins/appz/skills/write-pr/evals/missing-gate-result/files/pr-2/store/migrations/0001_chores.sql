CREATE TABLE chores (
	id      INTEGER PRIMARY KEY,
	name    TEXT NOT NULL,
	done_at TEXT
);
INSERT INTO chores (id, name) VALUES (1, 'Water the ferns'), (2, 'Take out the bins');
