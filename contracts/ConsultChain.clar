;; ConsultChain - Professional consulting project tracking and recognition platform
;; Version: 1.0.0

(define-data-var program-coordinator principal tx-sender)
(define-data-var total-consulting-hours uint u0)
(define-data-var recognition-multiplier uint u25) ;; recognition points per hour
(define-data-var last-recognition-cycle uint u0)

(define-map consultant-contributions principal uint)
(define-map consultant-industries principal (string-utf8 64))
(define-map industry-approvals (string-utf8 64) bool)

;; Error codes
(define-constant err-unauthorized-coordinator (err u1200))
(define-constant err-coordinator-already-exists (err u1201))
(define-constant err-invalid-hours (err u1202))
(define-constant err-no-recognition-due (err u1203))
(define-constant err-no-contributions (err u1204))
(define-constant err-invalid-industry (err u1205))
(define-constant err-industry-not-approved (err u1206))

;; Verify coordinator authorization
(define-private (is-program-coordinator (caller principal))
  (begin
    (asserts! (is-eq caller (var-get program-coordinator)) err-unauthorized-coordinator)
    (ok true)))

;; Initialize consulting tracking program
(define-public (launch-consulting-program (coordinator principal))
  (begin
    (asserts! (is-none (map-get? consultant-contributions coordinator)) err-coordinator-already-exists)
    (var-set program-coordinator coordinator)
    (ok "ConsultChain program launched successfully")))

;; Approve industry for consulting tracking
(define-public (approve-industry (industry-name (string-utf8 64)))
  (begin
    (try! (is-program-coordinator tx-sender))
    (asserts! (> (len industry-name) u0) err-invalid-industry)
    (map-set industry-approvals industry-name true)
    (ok "Industry approved for consulting tracking")))

;; Register consulting hours
(define-public (log-consulting-hours (hours uint) (industry (string-utf8 64)))
  (begin
    (asserts! (> hours u0) err-invalid-hours)
    (asserts! (default-to false (map-get? industry-approvals industry)) err-industry-not-approved)
    
    (let ((current-hours (default-to u0 (map-get? consultant-contributions tx-sender))))
      (map-set consultant-contributions tx-sender (+ current-hours hours))
      (map-set consultant-industries tx-sender industry)
      (var-set total-consulting-hours (+ (var-get total-consulting-hours) hours))
      (ok (+ current-hours hours)))))

;; Calculate recognition points
(define-public (calculate-recognition-points)
  (begin
    (try! (is-program-coordinator tx-sender))
    (let ((current-cycle (+ (var-get last-recognition-cycle) u1))
          (total-hours (var-get total-consulting-hours)))
      (asserts! (> total-hours (var-get last-recognition-cycle)) err-no-recognition-due)
      
      (let ((new-recognition-points (* (var-get recognition-multiplier) total-hours)))
        (var-set last-recognition-cycle current-cycle)
        (ok new-recognition-points)))))

;; Claim consulting recognition rewards
(define-public (claim-consulting-recognition)
  (begin
    (let ((consultant-hours (default-to u0 (map-get? consultant-contributions tx-sender))))
      (asserts! (> consultant-hours u0) err-no-contributions)
      
      (let ((total-hours (var-get total-consulting-hours))
            (recognition-points (* (var-get recognition-multiplier) consultant-hours))
            (contribution-percentage (/ (* consultant-hours u100000) total-hours)))
        
        (let ((final-recognition (/ (* contribution-percentage recognition-points) u100000)))
          (map-delete consultant-contributions tx-sender)
          (map-delete consultant-industries tx-sender)
          (var-set total-consulting-hours (- (var-get total-consulting-hours) consultant-hours))
          (ok (+ consultant-hours final-recognition)))))))

;; Read-only functions
(define-read-only (get-consulting-hours (consultant principal))
  (default-to u0 (map-get? consultant-contributions consultant)))

(define-read-only (get-consultant-industry (consultant principal))
  (map-get? consultant-industries consultant))

(define-read-only (get-total-consulting-hours)
  (var-get total-consulting-hours))

(define-read-only (is-industry-approved (industry-name (string-utf8 64)))
  (default-to false (map-get? industry-approvals industry-name)))

(define-read-only (get-program-stats)
  {
    coordinator: (var-get program-coordinator),
    total-hours: (var-get total-consulting-hours),
    recognition-multiplier: (var-get recognition-multiplier)
  })