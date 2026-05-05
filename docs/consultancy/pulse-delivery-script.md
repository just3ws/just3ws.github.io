# Postgres Pulse: Delivery Script (15-Minute Loom)

This script is designed to make you look like a "system whisperer" by moving quickly from data to insight.

## 0:00 - 1:00: The Context & Confidence
*   "Hi [Name], I've analyzed the query export you sent over. My goal for the next 15 minutes is to show you exactly where your system is 'bleeding' execution time and identify the 'Smoking Gun' that's likely causing your recent [slowness/incidents]."
*   **Show the Pulse Script output:** "We're looking at your `pg_stat_statements` data. No PII here, just the pure physics of your database."

## 1:00 - 5:00: The "Total Pain" Map
*   **Highlight the "Percentage of Total Time" column.**
*   "Look at this top query. It's taking up **35% of your total database time**. Even if it only runs once a second, it's the anchor dragging down your entire site."
*   **Explain the Query Preview:** "This looks like it's coming from the `Order#calculate_totals` method in Rails. It's doing a massive join on `line_items` without a selective filter."

## 5:00 - 10:00: The "Smoking Gun" (Wait Events & Locks)
*   **Switch to the Wait Event data.**
*   "This is where it gets interesting. Your top query isn't just slow; it's causing **Lock Contention** (Wait Event: `Relation`)."
*   **The Insight:** "This means when this query runs, it's actually blocking other requests from writing to the `orders` table. This is why you're seeing those 'Ghost Bugs' where users say the site hangs for 5 seconds."

## 10:00 - 13:00: Three Immediate Moves (Quick Wins)
*   "I'm not going to give you a 40-page report. Here are three things you should do tomorrow morning:"
*   1.  **Index Move:** "Add a concurrent index on `orders.account_id`—it's currently a sequential scan."
*   2.  **Query Move:** "Rewrite this specific sub-select into a CTE to help the Postgres planner."
*   3.  **Config Move:** "Your `work_mem` is low for these types of sorts; consider bumping it by 64MB."

## 13:00 - 15:00: The Bridge (The Upsell)
*   "We found the 'What.' We know this query is the pain point."
*   "The 'Why' is usually deeper. It’s often a divergence between how the business thinks the data flows and how the Rails models are actually executing it."
*   **The Offer:** "If you want me to spend 48 hours mapping the **Topography** of this specific path—finding exactly where the code diverges from the model—my **Behavior Audit** is the next move. I'll send the details along with this video."
