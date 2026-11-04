-- 06. 집합 연산자, GROUP BY, 분석 함수 (Oracle Database 19c)

-- 1) UNION은 중복을 제거한다. 개발 또는 분석 소속 사원 ID
SELECT emp_id
FROM sqld_emp
WHERE dept_id = 10
UNION
SELECT emp_id
FROM sqld_emp
WHERE dept_id = 20
ORDER BY emp_id;

-- 2) UNION ALL은 중복을 유지한다.
SELECT source_name, emp_id
FROM (
  SELECT '개발' AS source_name, emp_id FROM sqld_emp WHERE dept_id = 10
  UNION ALL
  SELECT '분석' AS source_name, emp_id FROM sqld_emp WHERE dept_id = 20
)
ORDER BY source_name, emp_id;

-- 3) INTERSECT: 급여 4000 이상이면서 보너스가 NULL이 아닌 사원
SELECT emp_id
FROM sqld_emp
WHERE salary >= 4000
INTERSECT
SELECT emp_id
FROM sqld_emp
WHERE bonus IS NOT NULL
ORDER BY emp_id;

-- 4) MINUS: 급여 4000 이상 사원 중 보너스가 NULL인 사원
SELECT emp_id
FROM sqld_emp
WHERE salary >= 4000
MINUS
SELECT emp_id
FROM sqld_emp
WHERE bonus IS NOT NULL
ORDER BY emp_id;

-- 5) GROUP BY/HAVING: 급여 합계가 10,000 이상인 부서
SELECT d.dept_id, d.dept_name, COUNT(e.emp_id) AS emp_count, SUM(e.salary) AS salary_sum
FROM sqld_dept d
JOIN sqld_emp e ON e.dept_id = d.dept_id
GROUP BY d.dept_id, d.dept_name
HAVING SUM(e.salary) >= 10000
ORDER BY d.dept_id;

-- 6) ROW_NUMBER, RANK, DENSE_RANK: 부서 안 급여 순위
SELECT dept_id,
       emp_id,
       emp_name,
       salary,
       ROW_NUMBER() OVER (PARTITION BY dept_id ORDER BY salary DESC, emp_id) AS row_no,
       RANK()       OVER (PARTITION BY dept_id ORDER BY salary DESC) AS salary_rank,
       DENSE_RANK() OVER (PARTITION BY dept_id ORDER BY salary DESC) AS dense_salary_rank
FROM sqld_emp
WHERE dept_id IS NOT NULL
ORDER BY dept_id, row_no;

-- 7) 누적 급여: ROWS를 명시해 동률이어도 행 단위 누적이 되도록 한다.
SELECT dept_id,
       emp_id,
       emp_name,
       salary,
       SUM(salary) OVER (
         PARTITION BY dept_id
         ORDER BY emp_id
         ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
       ) AS running_salary
FROM sqld_emp
WHERE dept_id IS NOT NULL
ORDER BY dept_id, emp_id;

-- 8) LAG: 같은 부서에서 이전 입사자의 급여와 비교
SELECT dept_id,
       emp_id,
       emp_name,
       salary,
       LAG(salary) OVER (PARTITION BY dept_id ORDER BY hire_date, emp_id) AS previous_salary
FROM sqld_emp
WHERE dept_id IS NOT NULL
ORDER BY dept_id, hire_date, emp_id;
