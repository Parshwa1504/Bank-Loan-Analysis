-- CREATING TABLE : 

DROP TABLE IF EXISTS bank_loan;

CREATE TABLE bank_loan(
	id_no int ,
	address_state VARCHAR(100),
	application_type VARCHAR(100),
	emp_length VARCHAR(100),
	emp_title VARCHAR(100),
	grade VARCHAR(100),
	home_ownership VARCHAR(100),
	issue_date DATE ,
	last_credit_pull_date DATE ,
	last_payment_date DATE ,
	Good_Bad_Loan VARCHAR(100),
	loan_status VARCHAR(100),
	next_payment_date DATE ,
	member_id int,
	purpose VARCHAR(100),
	sub_grade VARCHAR(100),
	term VARCHAR(100),
	verification_status VARCHAR(100),
	annual_income FLOAT ,
	dti FLOAT,
	installment FLOAT,
	int_rate FLOAT,
	loan_amount INT ,
	total_acc INT,
	total_payment INT
);

SELECT 
	* 
FROM
	bank_loan ;


-- PROBLEM STATEMENT SOLUTION : 

-- Key Performance Indicators (KPIs) Requirements:

-- 1.	Total Loan Applications: We need to calculate the total number of loan applications received during a specified period. Additionally, it is essential to monitor the Month-to-Date (MTD) Loan Applications and track changes Month-over-Month (MoM).

SELECT 
	Total_loan_applications,
	month_no,
	Total_loan_applications - LAG(Total_loan_applications,1) OVER(ORDER BY month_no) AS Current_month_performance_wrt_previous_month ,
	CASE
	WHEN LAG(Total_loan_applications,1) OVER(ORDER BY month_no) IS NULL THEN 0
	ELSE (Total_loan_applications - LAG(Total_loan_applications,1) OVER(ORDER BY month_no))*100/CAST(LAG(Total_loan_applications,1) OVER(ORDER BY month_no) AS FLOAT) 
	END AS Month_ON_Month_Percentage_Inc_or_Dec
FROM 
	(
	SELECT 
		COUNT(id_no) AS Total_loan_applications ,
		EXTRACT( MONTH FROM issue_date) AS month_no
	FROM 
		bank_loan 
	GROUP BY 2
	ORDER BY 2
	);

-- 2.	Total Funded Amount: Understanding the total amount of funds disbursed as loans is crucial. We also want to keep an eye on the MTD Total Funded Amount and analyse the Month-over-Month (MoM) changes in this metric.

SELECT 
	Total_funded_amount,
	month_no,
	Total_funded_amount - LAG(Total_funded_amount,1) OVER(ORDER BY month_no) AS Current_month_performance_wrt_previous_month ,
	CASE
	WHEN LAG(Total_funded_amount,1) OVER(ORDER BY month_no) IS NULL THEN 0
	ELSE (Total_funded_amount - LAG(Total_funded_amount,1) OVER(ORDER BY month_no))*100/CAST(LAG(Total_funded_amount,1) OVER(ORDER BY month_no) AS FLOAT) 
	END AS Month_ON_Month_Percentage_Inc_or_Dec
FROM 
	(
	SELECT 
		SUM(loan_amount) AS Total_funded_amount ,
		EXTRACT( MONTH FROM issue_date) AS month_no
	FROM 
		bank_loan 
	GROUP BY 2
	ORDER BY 2
	);

-- 3.	Total Amount Received: Tracking the total amount received from borrowers is essential for assessing the bank's cash flow and loan repayment. We should analyse the Month-to-Date (MTD) Total Amount Received and observe the Month-over-Month (MoM) changes.

SELECT 
	Total_amount_received,
	month_no,
	Total_amount_received - LAG(Total_amount_received,1) OVER(ORDER BY month_no) AS Current_month_performance_wrt_previous_month ,
	CASE
	WHEN LAG(Total_amount_received,1) OVER(ORDER BY month_no) IS NULL THEN 0
	ELSE (Total_amount_received - LAG(Total_amount_received,1) OVER(ORDER BY month_no))*100/CAST(LAG(Total_amount_received,1) OVER(ORDER BY month_no) AS FLOAT) 
	END AS Month_ON_Month_Percentage_Inc_or_Dec
FROM 
	(
	SELECT 
		SUM(total_payment) AS Total_amount_received ,
		EXTRACT( MONTH FROM issue_date) AS month_no
	FROM 
		bank_loan 
	GROUP BY 2
	ORDER BY 2
	);

-- 4.	Average Interest Rate: Calculating the average interest rate across all loans, MTD, and monitoring the Month-over-Month (MoM) variations in interest rates will provide insights into our lending portfolio's overall cost.

SELECT 
	Average_Interest_Rate,
	month_no,
	Average_Interest_Rate - LAG(Average_Interest_Rate,1) OVER(ORDER BY month_no) AS Current_month_performance_wrt_previous_month ,
	CASE
	WHEN LAG(Average_Interest_Rate,1) OVER(ORDER BY month_no) IS NULL THEN 0
	ELSE (Average_Interest_Rate - LAG(Average_Interest_Rate,1) OVER(ORDER BY month_no))*100/CAST(LAG(Average_Interest_Rate,1) OVER(ORDER BY month_no) AS FLOAT) 
	END AS Month_ON_Month_Percentage_Inc_or_Dec
FROM 
	(
	SELECT 
		AVG(int_rate) AS Average_Interest_Rate ,
		EXTRACT( MONTH FROM issue_date) AS month_no
	FROM 
		bank_loan 
	GROUP BY 2
	ORDER BY 2
	);

-- 5.	Average Debt-to-Income Ratio (DTI): Evaluating the average DTI for our borrowers helps us gauge their financial health. We need to compute the average DTI for all loans, MTD, and track Month-over-Month (MoM) fluctuations.

SELECT 
	ROUND(Average_Debt_to_Income_Ratio :: NUMERIC,4) AS Average_Debt_to_Income_Ratio, 
	month_no,
	ROUND(Average_Debt_to_Income_Ratio :: NUMERIC - LAG(Average_Debt_to_Income_Ratio :: NUMERIC,1) OVER(ORDER BY month_no),4) AS Current_month_performance_wrt_previous_month ,
	CASE
	WHEN LAG(Average_Debt_to_Income_Ratio,1) OVER(ORDER BY month_no) IS NULL THEN 0
	ELSE ((Average_Debt_to_Income_Ratio :: NUMERIC) - LAG(Average_Debt_to_Income_Ratio :: NUMERIC,1) OVER(ORDER BY month_no :: NUMERIC))*100/CAST(LAG(Average_Debt_to_Income_Ratio :: NUMERIC,1) OVER(ORDER BY month_no :: NUMERIC) AS FLOAT) 
	END AS Month_ON_Month_Percentage_Inc_or_Dec
FROM 
	(
	SELECT 
		AVG(dti) AS Average_Debt_to_Income_Ratio ,
		EXTRACT( MONTH FROM issue_date) AS month_no
	FROM 
		bank_loan 
	GROUP BY 2
	ORDER BY 2
	);


-- Good And Bad Loan KPIs:

SELECT 
	* 
FROM
	bank_loan ;

-- 1.	Good And Bad Loan Application Percentage: We need to calculate the percentage of loan applications classified as 'Good Loans.' This category includes loans with a loan status of 'Fully Paid' and 'Current.'

SELECT 
	good_bad_loan ,
	COUNT(id_no) AS Total_Loan_Applications_by_type ,
	ROUND((COUNT(id_no)*100.0 / SUM(COUNT(id_no)) OVER()),2)  AS Good_Bad_Loan_Percentage 
FROM
	bank_loan
GROUP BY 1
ORDER BY 2 DESC ;

-- 2.	Good And Bad Applications: Identifying the total number of loan applications falling under the 'Good Loan' category, which consists of loans with a loan status of 'Fully Paid' and 'Current.'

SELECT 
	COUNT(id_no) AS Total_Loan_Applications ,
	good_bad_loan 	
FROM
	bank_loan
GROUP BY 2
ORDER BY 1 DESC ;

-- 3.	Good And Bad Funded Amount: Determining the total amount of funds disbursed as 'Good Loans.' This includes the principal amounts of loans with a loan status of 'Fully Paid' and 'Current.'

SELECT 
	SUM(loan_amount) AS Total_Funded_Amount ,
	good_bad_loan 	
FROM
	bank_loan
GROUP BY 2
ORDER BY 1 DESC ;

-- 4.	Good And Bad Total Received Amount: Tracking the total amount received from borrowers for 'Good Loans,' which encompasses all payments made on loans with a loan status of 'Fully Paid' and 'Current.'

SELECT 
	SUM(total_payment) AS Total_Received_Amount ,
	good_bad_loan 	
FROM
	bank_loan
GROUP BY 2
ORDER BY 1 DESC ;

-- LOAN STATUS : 

SELECT 
	* 
FROM
	bank_loan ;

-- 1) LOAN STATUS BY LOAN COUNT , TOTAL AMOUNT RECEIVED , TOTAL FUNDED AMOUNT , INTEREST RATE , DTI.

SELECT 
	loan_status,
	COUNT(id_no) AS LOAN_COUNT,
	SUM(loan_amount) AS TOTAL_FUNDED_AMOUNT,
	SUM(total_payment) AS TOTAL_AMOUNT_RECEIVED,
	AVG(int_rate)*100 AS AVRAGE_INTEREST_RATE,
	AVG(dti)*100 AS AVERAGE_DTI
FROM 		
	bank_loan
GROUP BY 1
ORDER BY 2 DESC;

-- 2) LOAN STATUS BY MTD TOTAL AMOUNT RECEIVED , MTD TOTAL FUNDED AMOUNT.

SELECT 
	EXTRACT( MONTH FROM issue_date) AS month_no,
	loan_status,
	COUNT(id_no) AS MTD_LOAN_COUNT,
	SUM(loan_amount) AS MTD_TOTAL_FUNDED_AMOUNT,
	SUM(total_payment) AS MTD_TOTAL_AMOUNT_RECEIVED,
	AVG(int_rate)*100 AS MTD_AVRAGE_INTEREST_RATE,
	AVG(dti)*100 AS MTD_AVERAGE_DTI
FROM 		
	bank_loan
GROUP BY 1,2
ORDER BY 1
;

-- DASHBOARD 2: OVERVIEW Problem Statement : 

SELECT * FROM bank_loan ;

-- 1)  Monthly Trends by Issue Date : This line chart will showcase how 'Total Loan Applications,' 'Total Funded Amount,' and 'Total Amount Received' vary over time, allowing us to identify seasonality and long-term trends in lending activities

SELECT 
	month_no,
	Total_Loan_Applications,
	Total_Funded_Amount,
	Total_Amount_Received,
	(Total_Funded_Amount - Total_Amount_Received) AS profit_Loss_Analysis
FROM
(
	SELECT 
		EXTRACT ( MONTH FROM issue_date ) AS month_no,
		COUNT(id_no) AS Total_Loan_Applications,
		SUM(loan_amount) AS Total_Funded_Amount,
		SUM(total_payment) AS Total_Amount_Received
	FROM
		bank_loan
	GROUP BY 1
	ORDER BY 1
)
;

-- 2) Regional Analysis by State : Objective: This filled map will visually represent lending metrics categorized by state, enabling us to identify regions with significant lending activity and assess regional disparities.

SELECT 
	address_state,
	Total_Loan_Applications,
	Total_Funded_Amount,
	Total_Amount_Received,
	(Total_Funded_Amount - Total_Amount_Received) AS profit_Loss_Analysis
FROM
(
	SELECT 
		address_state,
		COUNT(id_no) AS Total_Loan_Applications,
		SUM(loan_amount) AS Total_Funded_Amount,
		SUM(total_payment) AS Total_Amount_Received
	FROM
		bank_loan
	GROUP BY 1
	ORDER BY 1
)
ORDER BY 5 DESC;

-- 3) . Loan Term Analysis  : Objective: This donut chart will depict loan statistics based on different loan terms, allowing us to understand the distribution of loans across various term lengths.

SELECT 
	term,
	Total_Loan_Applications,
	Total_Funded_Amount,
	Total_Amount_Received,
	(Total_Funded_Amount - Total_Amount_Received) AS profit_Loss_Analysis
FROM
(
	SELECT 
		term,
		COUNT(id_no) AS Total_Loan_Applications,
		SUM(loan_amount) AS Total_Funded_Amount,
		SUM(total_payment) AS Total_Amount_Received
	FROM
		bank_loan
	GROUP BY 1
	ORDER BY 1
)
ORDER BY 5 DESC;

-- 4) . Employee Length Analysis : Objective: This bar chart will illustrate how lending metrics are distributed among borrowers with different employment lengths, helping us assess the impact of employment history on loan applications.

SELECT 
	emp_length,
	Total_Loan_Applications,
	Total_Funded_Amount,
	Total_Amount_Received,
	(Total_Funded_Amount - Total_Amount_Received) AS profit_Loss_Analysis
FROM
(
	SELECT 
		emp_length,
		COUNT(id_no) AS Total_Loan_Applications,
		SUM(loan_amount) AS Total_Funded_Amount,
		SUM(total_payment) AS Total_Amount_Received
	FROM
		bank_loan
	GROUP BY 1
	ORDER BY 1
)
ORDER BY 5 DESC;

-- 5) Loan Purpose Breakdown : : This bar chart will provide a visual breakdown of loan metrics based on the stated purposes of loans, aiding in the understanding of the primary reasons borrowers seek financing.

SELECT 
	purpose,
	Total_Loan_Applications,
	Total_Funded_Amount,
	Total_Amount_Received,
	(Total_Funded_Amount - Total_Amount_Received) AS profit_Loss_Analysis
FROM
(
	SELECT 
		purpose,
		COUNT(id_no) AS Total_Loan_Applications,
		SUM(loan_amount) AS Total_Funded_Amount,
		SUM(total_payment) AS Total_Amount_Received
	FROM
		bank_loan
	GROUP BY 1
	ORDER BY 1
)
ORDER BY 2 DESC;

-- 6) Home Ownership Analysis : Objective: This tree map will display loan metrics categorized by different home ownership statuses, allowing for a hierarchical view of how home ownership impacts loan applications and disbursements

SELECT 
	home_ownership,
	Total_Loan_Applications,
	Total_Funded_Amount,
	Total_Amount_Received,
	(Total_Funded_Amount - Total_Amount_Received) AS profit_Loss_Analysis
FROM
(
	SELECT 
		home_ownership,
		COUNT(id_no) AS Total_Loan_Applications,
		SUM(loan_amount) AS Total_Funded_Amount,
		SUM(total_payment) AS Total_Amount_Received
	FROM
		bank_loan
	GROUP BY 1
	ORDER BY 1
)
ORDER BY 5 DESC;

-- DASHBOARD 3: Data Details : Objective : To see the overall dataset .

SELECT * FROM bank_loan ;