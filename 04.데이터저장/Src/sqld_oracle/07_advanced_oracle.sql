-- 07. Oracle 19c 전용/심화 문법 예제


-- 1) ROLLUP: 부서별 매출과 전체 합계. GROUPING=1인 행이 소계/총계 행이다.
SELECT CASE WHEN GROUPING(d.dept_name) = 1 THEN '전체' ELSE d.dept_name END AS dept_name,
       SUM(s.amount) AS amount_sum,
       GROUPING(d.dept_name) AS is_grand_total
FROM sqld_sales s
JOIN sqld_dept d ON d.dept_id = s.dept_id
GROUP BY ROLLUP(d.dept_name)
ORDER BY GROUPING(d.dept_name), d.dept_name;

-- 2) CUBE: 부서 × 월 세부값, 부서별 소계, 월별 소계, 전체 합계.
-- GROUPING_ID(dept_id, sale_month): 0=세부, 1=부서 소계, 2=월 소계, 3=전체 합계
SELECT dept_id,
       sale_month,
       SUM(amount) AS amount_sum,
       GROUPING_ID(dept_id, sale_month) AS grouping_id
FROM sqld_sales
GROUP BY CUBE(dept_id, sale_month)
ORDER BY GROUPING_ID(dept_id, sale_month), dept_id, sale_month;

-- 3) GROUPING SETS: 원하는 집계 수준만 명시적으로 선택한다.
SELECT dept_id,
       sale_month,
       SUM(amount) AS amount_sum,
       GROUPING_ID(dept_id, sale_month) AS grouping_id
FROM sqld_sales
GROUP BY GROUPING SETS (
  (dept_id, sale_month),
  (dept_id),
  (sale_month),
  ()
)
ORDER BY GROUPING_ID(dept_id, sale_month), dept_id, sale_month;

-- 4) CONNECT BY / LEVEL / PRIOR: 관리자-사원 계층. ORDER SIBLINGS BY로 형제 순서를 고정한다.
SELECT LPAD(' ', 2 * (LEVEL - 1)) || emp_name AS org_name,
       emp_id,
       manager_id,
       LEVEL AS org_level,
       SYS_CONNECT_BY_PATH(emp_name, ' > ') AS org_path
FROM sqld_emp
START WITH manager_id IS NULL
CONNECT BY PRIOR emp_id = manager_id
ORDER SIBLINGS BY emp_id;

-- 5) SELF JOIN: 계층을 일반 조인으로도 확인한다.
SELECT e.emp_id, e.emp_name, m.emp_id AS manager_id, m.emp_name AS manager_name
FROM sqld_emp e
LEFT JOIN sqld_emp m ON m.emp_id = e.manager_id
ORDER BY e.emp_id;

-- 6) PIVOT: 행인 월을 열로 회전한다. 지원 부서는 매출 원본이 없어 결과에 없다.
SELECT dept_name, jan_2024, feb_2024
FROM (
  SELECT d.dept_name, s.sale_month, s.amount
  FROM sqld_sales s
  JOIN sqld_dept d ON d.dept_id = s.dept_id
)
PIVOT (
  SUM(amount) FOR sale_month IN (
    '2024-01' AS jan_2024,
    '2024-02' AS feb_2024
  )
)
ORDER BY dept_name;

-- 7) UNPIVOT: 열인 월 예산을 행으로 되돌린다. INCLUDE NULLS는 NULL 값도 행으로 보존한다.
WITH dept_budget AS (
  SELECT 10 AS dept_id, 15000 AS jan_budget, 16000 AS feb_budget FROM dual
  UNION ALL
  SELECT 20, 10000, 12000 FROM dual
  UNION ALL
  SELECT 30, 8000, 9000 FROM dual
)
SELECT dept_id, budget_month, budget_amount
FROM dept_budget
UNPIVOT INCLUDE NULLS (
  budget_amount FOR budget_month IN (
    jan_budget AS '2024-01',
    feb_budget AS '2024-02'
  )
)
ORDER BY dept_id, budget_month;

-- 8) REGEXP_LIKE / REGEXP_REPLACE: 한글 이름 2~3자와 표시 마스킹.
SELECT emp_id,
       emp_name,
       REGEXP_REPLACE(emp_name, '(.).', '\1*') AS masked_name
FROM sqld_emp
WHERE REGEXP_LIKE(emp_name, '^[가-힣]{2,3}$')
ORDER BY emp_id;
