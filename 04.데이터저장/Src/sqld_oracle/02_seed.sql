-- SQLD 강의 실습용 고정 데이터 (Oracle Database 19c)
-- 예상 핵심값: 사원 8명, 급여 합계 31500, 보너스 NOT NULL 4건, 보너스 합계 800, 평균 200

INSERT INTO sqld_dept (dept_id, dept_name) VALUES (10, '개발');
INSERT INTO sqld_dept (dept_id, dept_name) VALUES (20, '분석');
INSERT INTO sqld_dept (dept_id, dept_name) VALUES (30, '영업');
INSERT INTO sqld_dept (dept_id, dept_name) VALUES (40, '지원');

INSERT INTO sqld_emp (emp_id, emp_name, dept_id, manager_id, salary, bonus, hire_date)
VALUES (101, '민준', 10, NULL, 6000, NULL, DATE '2021-01-10');
INSERT INTO sqld_emp (emp_id, emp_name, dept_id, manager_id, salary, bonus, hire_date)
VALUES (102, '서연', 10, 101, 4000, 0, DATE '2022-03-01');
INSERT INTO sqld_emp (emp_id, emp_name, dept_id, manager_id, salary, bonus, hire_date)
VALUES (103, '도윤', 10, 101, 4000, 500, DATE '2022-07-15');
INSERT INTO sqld_emp (emp_id, emp_name, dept_id, manager_id, salary, bonus, hire_date)
VALUES (104, '지우', 20, 101, 5000, NULL, DATE '2021-11-20');
INSERT INTO sqld_emp (emp_id, emp_name, dept_id, manager_id, salary, bonus, hire_date)
VALUES (105, '하준', 20, 104, 3000, 300, DATE '2023-01-05');
INSERT INTO sqld_emp (emp_id, emp_name, dept_id, manager_id, salary, bonus, hire_date)
VALUES (106, '수빈', 30, 101, 3500, NULL, DATE '2022-02-12');
INSERT INTO sqld_emp (emp_id, emp_name, dept_id, manager_id, salary, bonus, hire_date)
VALUES (107, '예준', 30, 106, 3500, 0, DATE '2023-04-18');
INSERT INTO sqld_emp (emp_id, emp_name, dept_id, manager_id, salary, bonus, hire_date)
VALUES (108, '채원', NULL, 101, 2500, NULL, DATE '2024-06-01');

INSERT INTO sqld_blocked_dept (dept_id) VALUES (30);
INSERT INTO sqld_blocked_dept (dept_id) VALUES (NULL);

-- 월별 매출 6건: 개발 27,000 / 분석 20,000 / 영업 15,000, 전체 62,000
INSERT INTO sqld_sales (sale_id, dept_id, sale_month, amount) VALUES (1, 10, '2024-01', 12000);
INSERT INTO sqld_sales (sale_id, dept_id, sale_month, amount) VALUES (2, 10, '2024-02', 15000);
INSERT INTO sqld_sales (sale_id, dept_id, sale_month, amount) VALUES (3, 20, '2024-01', 9000);
INSERT INTO sqld_sales (sale_id, dept_id, sale_month, amount) VALUES (4, 20, '2024-02', 11000);
INSERT INTO sqld_sales (sale_id, dept_id, sale_month, amount) VALUES (5, 30, '2024-01', 7000);
INSERT INTO sqld_sales (sale_id, dept_id, sale_month, amount) VALUES (6, 30, '2024-02', 8000);

COMMIT;
