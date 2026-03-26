create database sql_murder_mystery;


-- Employees Table
CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    name VARCHAR(50),
    department VARCHAR(50),
    role VARCHAR(50)
);

INSERT INTO employees VALUES
(1, 'Alice Johnson', 'Engineering', 'Software Engineer'),
(2, 'Bob Smith', 'HR', 'HR Manager'),
(3, 'Clara Lee', 'Finance', 'Accountant'),
(4, 'David Kumar', 'Engineering', 'DevOps Engineer'),
(5, 'Eva Brown', 'Marketing', 'Marketing Lead'),
(6, 'Frank Li', 'Engineering', 'QA Engineer'),
(7, 'Grace Tan', 'Finance', 'CFO'),
(8, 'Henry Wu', 'Engineering', 'CTO'),
(9, 'Isla Patel', 'Support', 'Customer Support'),
(10, 'Jack Chen', 'HR', 'Recruiter');

-- Keycard Logs Table
CREATE TABLE keycard_logs (
    log_id INT PRIMARY KEY,
    employee_id INT,
    room VARCHAR(50),
    entry_time TIMESTAMP,
    exit_time TIMESTAMP
);

INSERT INTO keycard_logs VALUES
(1, 1, 'Office', '2025-10-15 08:00', '2025-10-15 12:00'),
(2, 2, 'HR Office', '2025-10-15 08:30', '2025-10-15 17:00'),
(3, 3, 'Finance Office', '2025-10-15 08:45', '2025-10-15 12:30'),
(4, 4, 'Server Room', '2025-10-15 08:50', '2025-10-15 09:10'),
(5, 5, 'Marketing Office', '2025-10-15 09:00', '2025-10-15 17:30'),
(6, 6, 'Office', '2025-10-15 08:30', '2025-10-15 12:30'),
(7, 7, 'Finance Office', '2025-10-15 08:00', '2025-10-15 18:00'),
(8, 8, 'Server Room', '2025-10-15 08:40', '2025-10-15 09:05'),
(9, 9, 'Support Office', '2025-10-15 08:30', '2025-10-15 16:30'),
(10, 10, 'HR Office', '2025-10-15 09:00', '2025-10-15 17:00'),
(11, 4, 'CEO Office', '2025-10-15 20:50', '2025-10-15 21:00'); -- killer


-- Calls Table
CREATE TABLE calls (
    call_id INT PRIMARY KEY,
    caller_id INT,
    receiver_id INT,
    call_time TIMESTAMP,
    duration_sec INT
);

INSERT INTO calls VALUES
(1, 4, 1, '2025-10-15 20:55', 45),
(2, 5, 1, '2025-10-15 19:30', 120),
(3, 3, 7, '2025-10-15 14:00', 60),
(4, 2, 10, '2025-10-15 16:30', 30),
(5, 4, 7, '2025-10-15 20:40', 90);

-- Alibis Table
CREATE TABLE alibis (
    alibi_id INT PRIMARY KEY,
    employee_id INT,
    claimed_location VARCHAR(50),
    claim_time TIMESTAMP
);

INSERT INTO alibis VALUES
(1, 1, 'Office', '2025-10-15 20:50'),
(2, 4, 'Server Room', '2025-10-15 20:50'), -- false alibi
(3, 5, 'Marketing Office', '2025-10-15 20:50'),
(4, 6, 'Office', '2025-10-15 20:50');

-- Evidence Table
CREATE TABLE evidence (
    evidence_id INT PRIMARY KEY,
    room VARCHAR(50),
    description VARCHAR(255),
    found_time TIMESTAMP
);

INSERT INTO evidence VALUES
(1, 'CEO Office', 'Fingerprint on desk', '2025-10-15 21:05'),
(2, 'CEO Office', 'Keycard swipe logs mismatch', '2025-10-15 21:10'),
(3, 'Server Room', 'Unusual access pattern', '2025-10-15 21:15');


-- Step 1 - Identify where and when the crime happened. MENTIONED IN THE PROBLEM STATEMENT
# CRIME HAPPENED IN THE CEO'S OFFICE AT 9:00PM 

-- STEP 2- Analyze who accessed critical areas at the time
 SELECT kl.*, e.name 
 FROM keycard_logs kl 
 join employees e
	on kl.employee_id= e.employee_id
 WHERE room = "CEO Office";

-- STEP 3- Cross-check alibis with actual logs
select kl.*, a.claimed_location, a.claim_time 
FROM keycard_logs kl
JOIN Alibis a
	on kl.employee_id= a.employee_id;
# employee 4 - david kumar claims to be in server room but was in ceo office. 

-- STEP 4 Investigate suspicious calls made around the time
with caller_info as (
	select c.call_id, c.caller_id, e.name as caller ,c.call_time, c.duration_sec 
	from  calls c
    join employees e
		on c.caller_id = e.employee_id),
receiver_info as (
	select c.call_id, c.receiver_id, e.name as receiver ,c.call_time, c.duration_sec 
    from calls c
    join employees e
		on c.receiver_id = e.employee_id)
select ci.*  , ri.receiver_id, ri.receiver
from caller_info ci
join receiver_info ri
	on ci.call_id= ri.call_id
where caller_id =4 or receiver_id =4 ;    
# RESULT- EMPLOYEE ID 4 - DAVID KUMAR HAS CALLED EMPLOYEE 1,7 5 AND 20 MIN BEFORE THE CRIME RESPECTIVELY.  

-- STEP 5 Match evidence with movements and claims
SELECT * 
FROM alibis a
join keycard_logs kl
	on a.employee_id= kl.employee_id;
# employee 4 DAVID KUMAR'S alibi and keycard logs do not match and his logs show that he went to the ceo office 10 min before 
# the murder was discovered.  

-- case solved query 
   SELECT e.name as killer  
	FROM alibis a
	join keycard_logs kl
		on a.employee_id= kl.employee_id
    join employees e    
		on a.employee_id= e.employee_id
    where a.claimed_location != kl.room;





