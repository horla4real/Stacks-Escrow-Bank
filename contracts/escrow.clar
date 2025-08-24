;; Decentralized Escrow Banking Contract
;; Enables secure peer-to-peer transactions with escrow protection

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_NOT_AUTHORIZED (err u100))
(define-constant ERR_INVALID_AMOUNT (err u101))
(define-constant ERR_ESCROW_NOT_FOUND (err u102))
(define-constant ERR_INVALID_STATE (err u103))
(define-constant ERR_INSUFFICIENT_FUNDS (err u104))

(define-data-var escrow-counter uint u0)

(define-map escrows uint {
    buyer: principal,
    seller: principal,
    amount: uint,
    status: (string-ascii 20),
    created-at: uint
})

(define-map user-escrows principal (list 100 uint))

;; Create new escrow
(define-public (create-escrow (seller principal) (amount uint))
    (let ((escrow-id (+ (var-get escrow-counter) u1)))
        (asserts! (> amount u0) ERR_INVALID_AMOUNT)
        (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
        (map-set escrows escrow-id {
            buyer: tx-sender,
            seller: seller,
            amount: amount,
            status: "pending",
            created-at: stacks-block-height
        })
        (var-set escrow-counter escrow-id)
        (ok escrow-id)
    )
)

;; Release escrow funds to seller
(define-public (release-escrow (escrow-id uint))
    (let ((escrow (unwrap! (map-get? escrows escrow-id) ERR_ESCROW_NOT_FOUND)))
        (asserts! (is-eq (get buyer escrow) tx-sender) ERR_NOT_AUTHORIZED)
        (asserts! (is-eq (get status escrow) "pending") ERR_INVALID_STATE)
        (try! (as-contract (stx-transfer? (get amount escrow) tx-sender (get seller escrow))))
        (map-set escrows escrow-id (merge escrow { status: "completed" }))
        (ok true)
    )
)

;; Cancel escrow and refund buyer
(define-public (cancel-escrow (escrow-id uint))
    (let ((escrow (unwrap! (map-get? escrows escrow-id) ERR_ESCROW_NOT_FOUND)))
        (asserts! (or (is-eq (get buyer escrow) tx-sender) 
                     (is-eq (get seller escrow) tx-sender)) ERR_NOT_AUTHORIZED)
        (asserts! (is-eq (get status escrow) "pending") ERR_INVALID_STATE)
        (try! (as-contract (stx-transfer? (get amount escrow) tx-sender (get buyer escrow))))
        (map-set escrows escrow-id (merge escrow { status: "cancelled" }))
        (ok true)
    )
)

;; Get escrow details
(define-read-only (get-escrow (escrow-id uint))
    (map-get? escrows escrow-id)
)

;; Get total escrows created
(define-read-only (get-total-escrows)
    (var-get escrow-counter)
)