# Creating a Customer Summary Report

# In this exercise, you will create a customer summary report that summarizes key information about customers in the Sakila database, 
# including their rental history and payment details. The report will be generated using a combination of views, CTEs, and temporary tables.

# Step 1: Create a View
# First, create a view that summarizes rental information for each customer. 
# The view should include the customer's ID, name, email address, and total number of rentals (rental_count).

CREATE VIEW rental_information AS
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email,
    a.address,
    COUNT(r.rental_id) AS rental_count
FROM customer AS c
LEFT JOIN rental AS r
ON c.customer_id = r.customer_id
LEFT JOIN address AS a
ON c.address_id = a.address_id
GROUP BY c.customer_id, c.first_name, c.last_name, c.email, a.address;

SElECT * FROM payment;

# Step 2: Create a Temporary Table
# Next, create a Temporary Table that calculates the total amount paid by each customer (total_paid). 
# The Temporary Table should use the rental summary view created in Step 1 to join with the payment table and calculate the total amount paid by each customer.

CREATE TEMPORARY TABLE total_paid
SELECT 
	ri.customer_id,
    ri.first_name,
    ri.last_name,
    SUM(p.amount) AS total_paid
FROM payment AS p
INNER JOIN rental_information AS ri
	ON p.customer_id = ri.customer_id
GROUP BY ri.customer_id;

SELECT * FROM total_paid;

# Step 3: Create a CTE and the Customer Summary Report
# Create a CTE that joins the rental summary View with the customer payment summary Temporary Table created in Step 2. 
# The CTE should include the customer's name, email address, rental count, and total amount paid.
# Next, using the CTE, create the query to generate the final customer summary report, which should include: 
# customer name, email, rental_count, total_paid and average_payment_per_rental, this last column is a derived column from total_paid and rental_count.

WITH cte_customer_summary_report AS
	(Select 
		ri.first_name,
		ri.last_name,
		ri.email,
		ri.rental_count,
		tp.total_paid
	FROM rental_information AS ri
	INNER JOIN total_paid AS tp
	ON ri.customer_id = ri.customer_id
		)
SELECT 
	first_name,
    last_name,
    email,
    rental_count,
    total_paid,
    CASE 
		WHEN rental_count > 0 THEN total_paid / rental_count
		ELSE 0
	END AS average_payment_per_rental
FROM cte_customer_summary_report
ORDER BY total_paid DESC;
