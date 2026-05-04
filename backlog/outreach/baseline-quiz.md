# The Diagnostic Baseline Quiz

This quiz is the first step of the **Process Discovery Sprint**. It is designed to establish the "Normal State" of your system and identify the diagnostic surface before we begin mapping.

---

## 1. Technical Inventory
*   **Languages**: Which language(s) and their versions are you using for this path? (e.g., Ruby 3.2, Node 18, Python 3.11)
*   **Frameworks**: Which frameworks and their versions are you using? (e.g., Rails 7.1, Express 4.x, Django 5)
*   **Infrastructure Ownership**: Do you manage your own infrastructure for these systems, or is it delegated to another group? If delegated, which group?

## 2. Business Process Identification
*   **The Starting Point**: Who is the internal SME that can identify where the business considers the start of this critical flow?
*   **Initiation Type**: Is this a customer-initiated flow (e.g., UI interaction), a scheduled event, or a third-party trigger?
*   **Intent Baseline**: Where exactly does the business understand this starting point to begin? (e.g., "When the user clicks the 'Apply' button," or "When the webhook arrives from Stripe.")

## 3. Evidence Readiness (The Boundary Layer)
To establish high-confidence insights, what will it take to capture telemetry at this starting point?
*   [ ] **Browser/UI**: Can we capture a HAR file of the initial interaction?
*   [ ] **Web Layer**: Do we have access to Nginx/Apache/Ingress logs for the entry point?
*   [ ] **Application Layer**: Are Rails/App production logs available with unique identifiers?
*   [ ] **Database**: Can we take a sanitized snapshot of the tables involved in the initial write?

## 4. Data Mapping & Reach Analysis
At the entry point of the business process:
*   **Initial Write**: Exactly where (which table/service) is the initial data written?
*   **Logical Reach**: How many downstream systems or tables (Foreign Keys, logical or physical) can be reached from this initial data point?
*   **System of Record**: As data flows from System A to System B, which system is authorized to modify it? 
*   **Decision Risk**: Are there processes in System A (the original stack) that make business decisions based on its local data after System B has become the system of record?

## 5. Deeper System Discovery
...

## 6. The Goal: Token Identification
*   What systems are involved in getting to the creation of the **Process Token** (Request ID, Correlation ID, or unique identifier relevant to the business flow)?
*   Once we find the token, how is it propagated to the next system in the stack?
