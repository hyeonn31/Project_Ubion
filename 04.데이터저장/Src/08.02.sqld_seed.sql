-- 핵심값: 사원 8명, 급여 합계 31500, 보너스 NOT NULL 4건, 보너스 합계 800, 평균 200
USE sqld_mysql_lab;

-- 자동 커밋이 되지 않아서 commit을 내가 직접 확정 할 수 있음, update 임시 변경 가능, Rollback으로 취소 가능 
START TRANSACTION;

INSERT INTO sqld_dept (dept_id, dept_name) VALUES
  (10, '개발'),
  (20, '분석'),
  (30, '영업'),
  (40, '지원');

INSERT INTO sqld_emp (emp_id, emp_name, dept_id, manager_id, salary, bonus, hire_date) VALUES
  (101, '민준', 10, NULL, 6000, NULL, '2021-01-10'),
  (102, '서연', 10, 101, 4000, 0,    '2022-03-01'),
  (103, '도윤', 10, 101, 4000, 500,  '2022-07-15'),
  (104, '지우', 20, 101, 5000, NULL, '2021-11-20'),
  (105, '하준', 20, 104, 3000, 300,  '2023-01-05'),
  (106, '수빈', 30, 101, 3500, NULL, '2022-02-12'),
  (107, '예준', 30, 106, 3500, 0,    '2023-04-18'),
  (108, '채원', NULL, 101, 2500, NULL, '2024-06-01');

INSERT INTO sqld_blocked_dept (dept_id) VALUES
  (30),
  (NULL);

-- 월별 매출 6건: 개발 27000 / 분석 20000 / 영업 15000 / 전체 62000
INSERT INTO sqld_sales (sale_id, dept_id, sale_month, amount) VALUES
  (1, 10, '2024-01', 12000),
  (2, 10, '2024-02', 15000),
  (3, 20, '2024-01', 9000),
  (4, 20, '2024-02', 11000),
  (5, 30, '2024-01', 7000),
  (6, 30, '2024-02', 8000);

COMMIT;
