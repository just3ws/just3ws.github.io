---
layout: semantic
title: Improve Case-Insensitive Queries in PostgreSQL Using Smarter Indexes
published_on: February 25, 2016
tags: Database, Indexes, PostgreSQL, Postgres, RDBMS, RegEx, Ruby on Rails, SQL
---

One of the unique features of Postgres is it’s powerful index engine.
Using Postgres you can get much more fine grained control over how your
data is indexed. For example indexes on expressions which allow you to
create indexes on fields that have `UPPER` or `LOWER` functions applied
to them.

Typically a `VARCHAR` field is case-sensitive in Postgres. Meaning that
`fieldname = 'FOO'` and `fieldname = 'foo'` won’t match when the actual
value is "FOO". A common technique is to normalize the field value like
`lower(fieldname) = lower('FOO')` to coerce the fields to match using
their lower-case form. The problem is that this will ignore indexes and
cause Postgres to use a Sequential Scan to find the match evaluating
each row looking for a match. This is expensive and non-ideal for large
and frequently queried tables.

```postgres-console
postgresql=> explain select username from users where lower(username) = lower('just3ws');
                        QUERY PLAN
-----------------------------------------------------------
 Seq Scan on users  (cost=0.00..13327.36 rows=558 width=9)
   Filter: (lower((username)::text) = 'just3ws'::text)
(2 rows)

**Seq Scan on users  (cost=0.00..13327.36 rows=558 width=9)**
```

Compare that to the query with no expression and a simple index on the username
field.

```postgres-console
postgresql=> explain select username from users where username = lower('just3ws');
                                     QUERY PLAN
-------------------------------------------------------------------------------------
 Index Scan using index_users_on_username on users  (cost=0.00..4.07 rows=1 width=9)
   Index Cond: ((username)::text = 'just3ws'::text)
(2 rows)

**Index Scan using index\_users\_on\_username on users  (cost=0.00..4.07 rows=1 width=9)**
```

There’s a significant cost to pay when querying against expressions. But
all is not lost. Postgres will let you build [indexes against
expression](https://www.postgresql.org/docs/current/static/indexes-expressional.html).

In this case we’ll apply a index that will take the `lower()` expression
into account.

```postgres-console
create index ix_users_username_lower on users (lower(username) varchar_pattern_ops);
```

Now when we query for `lower(usernames)` we'll be able to take advantage
of the index to avoid full table scanning.

```postgres-console
postgresql=> explain select username from users where lower(username) = lower('just3ws');
                                       QUERY PLAN
----------------------------------------------------------------------------------------
 Bitmap Heap Scan on users  (cost=4.92..988.43 rows=558 width=9)
   Recheck Cond: (lower((username)::text) = 'just3ws'::text)
   ->  Bitmap Index Scan on ix_users_username_lower  (cost=0.00..4.90 rows=558 width=0)
         Index Cond: (lower((username)::text) = 'just3ws'::text)
(4 rows)

**Bitmap Heap Scan on users  (cost=4.92..988.43 rows=558 width=9)**
```

It’s much better than the Sequential Scan now although still a little
bit slower than just querying against the simple index.

The Bitmap Heap Scan is useful when there is a lot of variety in the
data and Postgres is able to intelligently segregate the data. Basically
the data is chunked into smaller sets that Postgres can filter though
and more intelligently decide which sets to scan and which to skip.
Where the Sequential Scan will touch every single row in the table.

Read more about the Postgres [Index on
Expressions](https://www.postgresql.org/docs/9.1/static/indexes-expressional.html)
in the official documentation and this explanation by the author of the
[Postgres Bitmap Heap Scan
algorithm](https://www.postgresql.org/message-id/12553.1135634231@sss.pgh.pa.us)
Tom Lane.

For a full explanation of what the `cost`, `rows`, and `width` values
mean please check out [Using
Explain](https://www.postgresql.org/docs/9.2/static/using-explain.html)
from the Postgres documentation.

`varchar_pattern_ops` is explained in Postgres
[Index](https://www.postgresql.org/docs/current/static/indexes-opclass.html)
documentation.
