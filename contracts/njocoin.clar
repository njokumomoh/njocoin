;; njocoin.clar
;; A simple fungible token implementation for the Njocoin project.
;;
;; This contract defines a fungible token using Clarity's built-in
;; fungible token primitives. It exposes a minimal interface for
;; minting, transferring, and querying balances and total supply.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Token metadata
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-constant token-name "Njocoin")
(define-constant token-symbol "NJO")
(define-constant token-decimals u6)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Token definition
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; This creates a fungible token within this contract identified
;; by the name `njocoin`.
(define-fungible-token njocoin)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Error codes
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-constant err-amount-zero u100)
(define-constant err-not-authorized u101)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; State
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Track the total supply of tokens minted by this contract.
(define-data-var total-supply uint u0)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Read-only functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-read-only (get-name)
  (ok token-name))

(define-read-only (get-symbol)
  (ok token-symbol))

(define-read-only (get-decimals)
  (ok token-decimals))

(define-read-only (get-total-supply)
  (ok (var-get total-supply)))

(define-read-only (get-balance (who principal))
  (ok (ft-get-balance njocoin who)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Public functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Mint new tokens to the caller of the transaction.
;;
;; This is intentionally simple and acts like a faucet: any principal
;; can mint tokens to themselves. For production usage you would
;; normally restrict minting to a contract owner or governance
;; mechanism.
(define-public (mint (amount uint))
  (begin
    (if (is-eq amount u0)
        (err err-amount-zero)
        (let ((mint-result (ft-mint? njocoin amount tx-sender)))
          (match mint-result
            success
              (begin
                (var-set total-supply (+ (var-get total-supply) amount))
                (ok true))
            err-code
              (err err-code))))))

;; Transfer tokens from `sender` to `recipient`.
;;
;; The caller must be the `sender` to prevent unauthorized transfers.
(define-public (transfer (amount uint)
                         (sender principal)
                         (recipient principal))
  (begin
    (if (not (is-eq sender tx-sender))
        (err err-not-authorized)
        (if (is-eq amount u0)
            (err err-amount-zero)
            (let ((transfer-result (ft-transfer? njocoin amount sender recipient)))
              (match transfer-result
                success (ok true)
                err-code (err err-code)))))))
