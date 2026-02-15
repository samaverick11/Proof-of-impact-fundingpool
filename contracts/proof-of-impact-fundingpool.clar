;; =====================================================
;; ProofOfImpactFundingPool
;; Milestone-based grant distribution pool
;; =====================================================

;; -----------------------------
;; Data Variables
;; -----------------------------

(define-data-var admin principal tx-sender)
(define-data-var pool-balance uint u0)
(define-data-var project-count uint u0)

;; -----------------------------
;; Data Maps
;; -----------------------------

(define-map projects
  uint
  {
    owner: principal,
    total-approved: uint,
    claimed: uint,
    active: bool
  }
)

(define-map milestones
  { project-id: uint, milestone-id: uint }
  {
    amount: uint,
    approved: bool,
    claimed: bool
  }
)

(define-map milestone-count uint uint)

;; -----------------------------
;; Errors
;; -----------------------------

(define-constant ERR-NOT-AUTHORIZED u100)
(define-constant ERR-NOT-FOUND u101)
(define-constant ERR-NOT-APPROVED u102)
(define-constant ERR-ALREADY-CLAIMED u103)
(define-constant ERR-INSUFFICIENT-POOL u104)

;; -----------------------------
;; Helpers
;; -----------------------------

(define-read-only (is-admin)
  (is-eq tx-sender (var-get admin))
)

;; -----------------------------
;; Funding
;; -----------------------------

(define-public (deposit (amount uint))
  (begin
    ;; Fixed: Wrapped in 'begin' and added try! for the transfer
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    (var-set pool-balance (+ (var-get pool-balance) amount))
    (ok true)
  )
)

;; -----------------------------
;; Project Registration
;; -----------------------------

(define-public (register-project)
  (let ((id (var-get project-count)))
    (map-set projects id {
      owner: tx-sender,
      total-approved: u0,
      claimed: u0,
      active: true
    })
    (map-set milestone-count id u0)
    (var-set project-count (+ id u1))
    (ok id)
  )
)

;; -----------------------------
;; Milestone Creation (Admin)
;; -----------------------------

(define-public (add-milestone (project-id uint) (amount uint))
  (begin
    (asserts! (is-admin) (err ERR-NOT-AUTHORIZED))
    (let ((count (default-to u0 (map-get? milestone-count project-id))))
      (map-set milestones
        { project-id: project-id, milestone-id: count }
        {
          amount: amount,
          approved: false,
          claimed: false
        }
      )
      (map-set milestone-count project-id (+ count u1))
      (ok count)
    )
  )
)

;; -----------------------------
;; Approve Milestone
;; -----------------------------

(define-public (approve-milestone (project-id uint) (milestone-id uint))
  (begin
    (asserts! (is-admin) (err ERR-NOT-AUTHORIZED))
    (let ((m (map-get? milestones { project-id: project-id, milestone-id: milestone-id })))
      (match m data
        (begin
          (map-set milestones
            { project-id: project-id, milestone-id: milestone-id }
            {
              amount: (get amount data),
              approved: true,
              claimed: (get claimed data)
            }
          )
          (ok true)
        )
        (err ERR-NOT-FOUND)
      )
    )
  )
)

;; -----------------------------
;; Claim Milestone
;; -----------------------------

(define-public (claim (project-id uint) (milestone-id uint))
  (let (
    (project (map-get? projects project-id))
    (milestone (map-get? milestones { project-id: project-id, milestone-id: milestone-id }))
  )
    (match project p
      (match milestone m
        (begin
          (asserts! (is-eq tx-sender (get owner p)) (err ERR-NOT-AUTHORIZED))
          (asserts! (get approved m) (err ERR-NOT-APPROVED))
          (asserts! (not (get claimed m)) (err ERR-ALREADY-CLAIMED))
          (asserts! (>= (var-get pool-balance) (get amount m)) (err ERR-INSUFFICIENT-POOL))

          ;; Update state BEFORE transfer (Checks-Effects-Interactions pattern)
          (map-set milestones
            { project-id: project-id, milestone-id: milestone-id }
            {
              amount: (get amount m),
              approved: true,
              claimed: true
            }
          )
          (var-set pool-balance (- (var-get pool-balance) (get amount m)))

          ;; Fixed: Added as-contract wrapper for the source of funds
          (as-contract (stx-transfer? (get amount m) tx-sender (get owner p)))
        )
        (err ERR-NOT-FOUND)
      )
      (err ERR-NOT-FOUND)
    )
  )
)

;; -----------------------------
;; Read-only Views
;; -----------------------------

(define-read-only (get-project (project-id uint))
  (map-get? projects project-id)
)

(define-read-only (get-milestone (project-id uint) (milestone-id uint))
  (map-get? milestones { project-id: project-id, milestone-id: milestone-id })
)