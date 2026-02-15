Proof-of-Impact-FundingPool

A decentralized milestone-based funding pool smart contract built in **Clarity** for the **Stacks Blockchain**.

---

Overview

**Proof-of-Impact-FundingPool** is a transparent, trust-minimized smart contract that enables pooled capital funding for impact-driven projects. 

Contributors deposit STX into a shared pool, and funds are released to registered beneficiaries only after verified proof of measurable impact. The contract ensures that capital allocation is strictly tied to milestone completion and validated outcomes.

This system promotes accountability, transparency, and performance-based funding on-chain.

---

Problem Statement

Traditional funding models suffer from:
- Lack of transparency
- Misallocation of capital
- No enforceable milestone validation
- Weak accountability mechanisms

Proof-of-Impact-FundingPool solves this by:
- Locking funds on-chain
- Enforcing milestone-based release logic
- Requiring impact verification before disbursement
- Maintaining immutable public records of contributions and payouts

---

Architecture

Built With
- **Language:** Clarity
- **Blockchain:** Stacks
- **Framework:** Clarinet (recommended for development & testing)

---

Roles

1.Contributor
- Deposits STX into the funding pool
- Can view funding allocations
- Participates in transparent funding cycles

2.Beneficiary
- Registers an impact project
- Defines funding milestones
- Receives funds after milestone verification

3.Verifier
- Validates proof-of-impact submissions
- Confirms milestone completion
- Triggers milestone payout authorization

4.Admin (Optional)
- Assigns verifier roles
- Configures pool parameters
- Manages emergency controls (if enabled)

---

Contract Workflow

1. Contributors deposit STX into the funding pool.
2. Beneficiaries register projects and define milestones.
3. Beneficiaries submit proof-of-impact for completed milestones.
4. Verifiers validate the milestone submission.
5. Approved milestones trigger fund disbursement from the pool.
6. All actions are logged via on-chain events.

---

Core Features

- Shared Impact Funding Pool
- Milestone-Based Fund Release
- On-Chain Impact Verification
- Transparent Contribution Tracking
- Event Logging for Off-Chain Indexing
- Deterministic State Transitions
- Designed to Pass Clarinet Checks

---

Security Design

- Explicit state lifecycle management
- No premature withdrawal logic
- Controlled verifier permissions
- Minimal surface area for reentrancy-style risks
- Deterministic Clarity execution (no unexpected behavior)

---

 Project Structure (Example)
contracts/
└── proof-of-impact-fundingpool.clar

tests/
└── fundingpool_test.ts

Clarinet.toml
README.md


---

License

MIT License


Deployment

Install Clarinet
Follow official Stacks documentation to install Clarinet.

Initialize Project
```bash
clarinet new proof-of-impact-fundingpool


