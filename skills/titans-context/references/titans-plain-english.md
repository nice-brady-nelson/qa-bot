# Titans in Plain English — The Beginner's Companion

> A simpler, analogy-first walkthrough of the Titans / Agent Integrations system.
> Read this **first** to build intuition, then use `titans-architecture-deep-dive.md`
> when you need the exact payloads, file paths, and code. Same system, friendlier words.

---

## The 30-second version

A customer calls (or chats). Our system automatically looks them up in the company's CRM
(Salesforce, ServiceNow, etc.), shows the agent who they are, and — when the call ends —
writes the call details back into the CRM so there's a record. That's it. Everything below
is just *how* that happens without a human copy-pasting anything.

---

## The cast of characters (who does what)

Think of it like a restaurant kitchen. An order comes in, and several specialists each do
one job and pass it along.

| The piece | Restaurant analogy | What it actually does |
|-----------|-------------------|------------------------|
| **CXone Studio** | The phone that takes the order | The IVR script that runs when a call arrives and kicks everything off |
| **CXone Agent / Customer Card** | The waiter's notepad | The screen the agent looks at — shows who's calling, related records |
| **C# Monolith** | The head chef / expediter | The one "front door." Checks you're allowed in, then hands the job to the right cook |
| **Lambda** (Node.js) | The line cook | Does the actual prep: figures out what to send and to which CRM |
| **DynamoDB** | The recipe book | Permanent storage of *how* each customer's CRM is set up |
| **Redis / Valkey** | The order ticket clipped to the rail | Temporary scratchpad holding *this call's* results |
| **Tray.io** | The universal translator / waiter who speaks every language | Talks to each CRM in its own language so we don't have to |
| **The CRM** | The customer's home pantry | Salesforce / ServiceNow / Dynamics — where the real data lives |

**The one thing newcomers get wrong:** the repo named `cxone-webapp-agent-integration`
(Angular) is the **admin setup screen** — where a manager configures the integration. It is
**not** the screen the agent sees on a call. That agent screen lives in a *different* repo
(`webapp-acd-agent-apps`, React). Our team (Titans) owns the **setup screen** and the
**backend Lambda**.

---

## How a request travels (the "telephone game")

Every feature follows the same basic chain. Data gets passed hand-to-hand, and at each step
it's reshaped a little for the next person:

```
Customer call
   │
   ▼
CXone Studio / Agent screen      "Hey, look up this caller"
   │
   ▼
C# Monolith (the front door)     checks you're allowed, then forwards the job
   │   (calls the Lambda directly — there's no separate "API gateway" middleman)
   ▼
Lambda (the worker)              looks up the recipe, builds the request
   │
   ├──► reads DynamoDB            "How is THIS customer's CRM set up?"
   │
   ▼
Tray.io (the translator)         turns our generic request into Salesforce-speak
   │
   ▼
The CRM                          actually does the search / creates the record
   │
   ▼
Redis/Valkey (the scratchpad)    results get parked here for the call's duration
   │
   ▼
Agent's Customer Card            reads the scratchpad and shows the agent
```

That's the whole system. Every feature (search, screen pop, data memorialization, etc.) is
just a variation of this one journey.

---

## The two "memory" systems (the part everyone mixes up)

This is worth slowing down on, because the system has **two** places it stores data and they
do completely different jobs.

### DynamoDB = the filing cabinet (permanent setup)

A database is just "a place data is stored." **DynamoDB** is Amazon's cloud database, and for
us it holds the **setup** — the stuff an admin configured once and that doesn't change during
a call:

- "Acme Corp connects to Salesforce, in the US region."
- "When we save call data, put the agent's name into the Salesforce `Owner` field." (a *data mapping*)
- "Here's the list of workflows available: Search, Create, Save-to-CRM."

It's permanent. It sits there until someone edits or deletes it. When a call comes in, the
Lambda **reads** DynamoDB to learn how to handle *this* customer's CRM.

> Tiny extra detail you can ignore at first: DynamoDB is "NoSQL," meaning you look things up
> by a key (like a label on a folder) instead of writing SQL queries. Everything lives in one
> table. Not important for understanding the flow.

### Redis / Valkey = the sticky note (temporary, this-call-only)

**Redis** is a different kind of database — it keeps everything in memory (RAM), which makes
it *blazing* fast but temporary. It's the **scratchpad for what's happening right now**:

- "On call #12345, we found these 2 Salesforce contacts."
- "The agent pinned this record to the top."

Each note is filed under a `cacheKey` (basically the call's ID) and **auto-deletes after 2 days**.

| | DynamoDB (filing cabinet) | Redis/Valkey (sticky note) |
|---|---|---|
| Holds | Setup / configuration | This call's live results |
| Lasts | Forever | 2 days, then gone |
| Used to | Tell the Lambda *how* to work | Remember results so the agent can see them |

> **"Wait, isn't Redis becoming Valkey?"** Yes. Redis changed its license, so the open-source
> community forked it and named the fork **Valkey** — it's the *same thing* with the same
> commands. We're swapping the engine underneath, but **our code doesn't change at all**. So
> anywhere you see "Redis," just think "Redis/Valkey — the fast scratchpad."

---

## What is Tray.io and why do we need it?

Every CRM speaks its own "language" (its own API). Salesforce, ServiceNow, and Zendesk all
want requests in totally different formats. Writing and maintaining custom code for each one
would be miserable.

**Tray.io** is a paid third-party service that specializes in exactly this. It's a **universal
translator**. Our Lambda speaks *one* simple language to Tray, and Tray handles the messy
details of talking to each specific CRM — including logging in securely (so we never store
the customer's CRM password).

```
Our Lambda  ──"create a case"──►  Tray.io  ──►  speaks Salesforce  ──►  Salesforce
                                          ──►  speaks ServiceNow ──►  ServiceNow
                                          ──►  speaks Zendesk    ──►  Zendesk
```

A Tray **"workflow"** is just a pre-built recipe like "Search for a contact" or "Create a
case." It has an ID, and the Lambda triggers it with a simple web request.

---

## The features, in one line each

How the big features map onto that same journey:

- **Search** — caller arrives → look them up in the CRM → show matches as *Related Interactions*.
- **Screen Pop** — found exactly one match → automatically open that record on the agent's screen.
- **Pinned Records** — a record the agent (or the system) sticks to the top as the *Current Interaction*; auto-linked for saving later.
- **Relates To** — link two CRM records together (e.g. attach a case to an account), done live during the call.
- **Agent Create** — the agent makes a brand-new CRM record (a case, a contact) right from their screen.
- **Data Memorialization (DM)** — the big one: when the call ends, automatically **write the call details back into the CRM** (who handled it, how long, disposition notes, etc.) so there's a permanent record. No manual data entry.
- **Dynamic Data** — show specific CRM fields *to* the agent during the call (view-only), vs DM which is about *writing* data back.
- **Script Variables** — custom values collected in the IVR (like an account number the caller typed) that get written back during DM.

---

## Two quick stories (start to finish)

### Story 1: A customer calls in

1. Call arrives. The Studio script says "look up this phone number."
2. The front door (Monolith) checks the tenant is allowed, then hands it to the Lambda.
3. The Lambda reads DynamoDB ("how is this customer's Salesforce set up?"), then asks Tray to search.
4. Tray searches Salesforce, finds 2 contacts, sends them back.
5. Results get parked on the Redis sticky note under this call's ID.
6. The agent's Customer Card reads that note and shows the 2 contacts. If there was exactly one match, it auto-opens (screen pop).

### Story 2: The call ends (saving the record)

1. Agent hangs up. The system looks at its notes to see which "save" recipe to run and which records the agent linked.
2. It sends the call details (agent name, duration, notes, any IVR values) to the Lambda.
3. The Lambda matches each detail to the right CRM field (using the *data mapping* from DynamoDB) and asks Tray to write it.
4. Tray writes it into Salesforce. Done — there's now a permanent record of the call, with zero manual typing.

---

## When you're ready for more

Everything here is the simplified version. When you need the **exact** request shapes, field
names, file paths, status codes, and edge cases, jump to:

➡️ **`titans-architecture-deep-dive.md`** (the detailed companion)

A rough map of where to look there:
- Exact payloads at each step → §4 "The end-to-end payload journey"
- The call-data object (CXoneContactModel) → §5
- How "save to CRM" really works → §6 "Data Memorialization"
- Real per-CRM examples → §7
- Where code lives in each repo → §15

And the official diagrams live in Confluence (links are in the deep-dive's §17).
