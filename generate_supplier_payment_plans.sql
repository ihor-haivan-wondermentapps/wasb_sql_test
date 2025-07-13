-- Generate monthly payment plans for each supplier based on their outstanding invoices

WITH invoice_months AS (
    SELECT
        supplier_id,
        invoice_ammount,
        date_trunc('month', CURRENT_DATE) AS start_month,
        date_trunc('month', due_date) AS end_month,
        (date_diff('month', date_trunc('month', CURRENT_DATE), date_trunc('month', due_date)) + 1) AS payment_months
    FROM memory.default.invoice
), payment_schedule AS (
    SELECT
        supplier_id,
        sequence(start_month, end_month, interval '1' month) AS payment_dates,
        ROUND(invoice_ammount / payment_months, 2) AS monthly_payment
    FROM invoice_months
), exploded_payments AS (
    SELECT
        supplier_id,
        date_trunc('month', payment_date) + interval '1' month - interval '1' day AS payment_date,
        monthly_payment
    FROM payment_schedule
    CROSS JOIN UNNEST(payment_dates) AS t(payment_date)
), aggregated_payments AS (
    SELECT
        supplier_id,
        payment_date,
        SUM(monthly_payment) AS payment_amount
    FROM exploded_payments
    GROUP BY supplier_id, payment_date
), balances AS (
    SELECT
        supplier_id,
        SUM(invoice_ammount) AS total_amount
    FROM memory.default.invoice
    GROUP BY supplier_id
), cumulative_payments AS (
    SELECT
        supplier_id,
        payment_date,
        payment_amount,
        SUM(payment_amount) OVER (PARTITION BY supplier_id ORDER BY payment_date) AS cumulative_paid
    FROM aggregated_payments
)
SELECT
    s.supplier_id,
    s.name AS supplier_name,
    cp.payment_amount,
    ROUND(b.total_amount - cp.cumulative_paid, 2) AS balance_outstanding,
    cp.payment_date
FROM cumulative_payments cp
JOIN memory.default.supplier s ON cp.supplier_id = s.supplier_id
JOIN balances b ON cp.supplier_id = b.supplier_id
ORDER BY s.supplier_id, cp.payment_date;
