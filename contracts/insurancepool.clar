;; ============================================================
;; Contract Name: insurance-pool-dao
;; Description:
;; A complex Clarity smart contract implementing:
;; - Decentralized insurance pool
;; - Premium payments & coverage purchase
;; - Claim submission & DAO voting approval
;; - Payout management
;; - Reputation & risk tracking
;; ============================================================

;; -------------------------
;; Errors
;; -------------------------
(define-constant ERR-AUTH (err u200))
(define-constant ERR-NOT-FOUND (err u201))
(define-constant ERR-STATE (err u202))
(define-constant ERR-BALANCE (err u203))

;; -------------------------
;; Data Variables
;; -------------------------
(define-data-var pool-funds uint u0)
(define-data-var policy-count uint u0)
(define-data-var claim-count uint u0)

;; -------------------------
;; Maps
;; -------------------------

;; Insurance policies
(define-map policies
  uint
  {
    holder: principal,
    premium: uint,
    coverage: uint,
    expiry: uint,
    active: bool
  }
)

;; Claims
(define-map claims
  uint
  {
    policy-id: uint,
    claimant: principal,
    amount: uint,
    yes: uint,
    no: uint,
    end-block: uint,
    resolved: bool
  }
)

;; Votes (prevent double voting)
(define-map claim-votes {claim: uint, voter: principal} bool)

;; Reputation
(define-map reputation principal uint)

;; -------------------------
;; Private Helpers
;; -------------------------

(define-private (add-rep (user principal))
  (map-set reputation user (+ (default-to u0 (map-get? reputation user)) u1)))

;; -------------------------
;; Pool Functions
;; -------------------------

;; Fund the insurance pool
(define-public (fund-pool (amount uint))
  (begin
    (asserts! (> amount u0) ERR-STATE)
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    (var-set pool-funds (+ (var-get pool-funds) amount))
    (ok true)))

;; -------------------------
;; Policy Functions
;; -------------------------

(define-public (buy-policy (premium uint) (coverage uint) (duration uint))
  (begin
    (asserts! (and (> premium u0) (and (> coverage u0) (> duration u0))) ERR-STATE)
    (try! (stx-transfer? premium tx-sender (as-contract tx-sender)))
    (let ((id (+ (var-get policy-count) u1)))
      (map-set policies id {
        holder: tx-sender,
        premium: premium,
        coverage: coverage,
        expiry: (+ u0 duration),
        active: true
      })
      (var-set pool-funds (+ (var-get pool-funds) premium))
      (var-set policy-count id)
      (ok id))))

(define-public (expire-policy (policy-id uint))
  (let ((policy (unwrap! (map-get? policies policy-id) ERR-NOT-FOUND)))
    (if (>= u0 (get expiry policy))
        (begin
          (map-set policies policy-id (merge policy {active: false}))
          (ok true))
        ERR-STATE)))

;; -------------------------
;; Claim Functions
;; -------------------------

(define-public (submit-claim (policy-id uint) (amount uint) (duration uint))
  (let ((policy (unwrap! (map-get? policies policy-id) ERR-NOT-FOUND)))
    (asserts! (and (> amount u0) (> duration u0)) ERR-STATE)
    (if (or (not (get active policy)) (> amount (get coverage policy)))
        ERR-STATE
        (let ((id (+ (var-get claim-count) u1)))
          (map-set claims id {
            policy-id: policy-id,
            claimant: tx-sender,
            amount: amount,
            yes: u0,
            no: u0,
            end-block: (+ u0 duration),
            resolved: false
          })
          (var-set claim-count id)
          (ok id)))))

(define-public (vote-claim (claim-id uint) (support bool))
  (let ((claim (unwrap! (map-get? claims claim-id) ERR-NOT-FOUND)))
    (if (or (>= u0 (get end-block claim))
            (is-some (map-get? claim-votes {claim: claim-id, voter: tx-sender})))
        ERR-STATE
        (begin
          (map-set claim-votes {claim: claim-id, voter: tx-sender} true)
          (if support
              (map-set claims claim-id (merge claim {yes: (+ (get yes claim) u1)}))
              (map-set claims claim-id (merge claim {no: (+ (get no claim) u1)})))
          (ok true)))))

(define-public (resolve-claim (claim-id uint))
  (let ((claim (unwrap! (map-get? claims claim-id) ERR-NOT-FOUND)))
    (if (or (get resolved claim)
            (< u0 (get end-block claim)))
        ERR-STATE
        (if (> (get yes claim) (get no claim))
            (begin
              (if (< (var-get pool-funds) (get amount claim))
                  ERR-BALANCE
                  (begin
                    (var-set pool-funds (- (var-get pool-funds) (get amount claim)))
                    (try! (stx-transfer? (get amount claim)
                                         (as-contract tx-sender)
                                         (get claimant claim)))
                    (add-rep (get claimant claim))
                    (map-set claims claim-id (merge claim {resolved: true}))
                    (ok true))))
            (begin
              (map-set claims claim-id (merge claim {resolved: true}))
              (ok true))))))

;; -------------------------
;; Read-only Functions
;; -------------------------

(define-read-only (get-policy (policy-id uint))
  (map-get? policies policy-id))

(define-read-only (get-claim (claim-id uint))
  (map-get? claims claim-id))

(define-read-only (get-pool-funds)
  (var-get pool-funds))

(define-read-only (get-reputation (user principal))
  (default-to u0 (map-get? reputation user)))

;; ============================================================
;; End of insurance-pool-dao
;; ============================================================
