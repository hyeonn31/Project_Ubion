-- 04. NULL, 3값 논리, 집계 함수 (Oracle Database 19c)

-- 1) NULL 보너스 사원: 민준, 지우, 수빈, 채원 (4명)
SELECT emp_id, emp_name, bonus
FROM sqld_emp
WHERE bonus IS NULL
ORDER BY emp_id;

-- 2) COUNT(*)는 행 수, COUNT(bonus)는 NULL이 아닌 보너스 수
-- 예상: 8, 4, 800, 200
SELECT COUNT(*) AS all_rows,
       COUNT(bonus) AS bonus_not_null_rows,
       SUM(bonus) AS bonus_sum,
       AVG(bonus) AS bonus_avg
FROM sqld_emp;

-- 3) NULL 보너스를 0으로 대체하면 8명 기준 평균이 된다. 예상 avg_bonus_zero = 100
SELECT SUM(NVL(bonus, 0)) AS bonus_zero_sum,
       AVG(NVL(bonus, 0)) AS avg_bonus_zero
FROM sqld_emp;

-- 4) NULL 전파와 NVL의 차이. 예상 raw_sum=15300, safe_sum=32300
SELECT SUM(salary + bonus) AS raw_sum,
       SUM(salary + NVL(bonus, 0)) AS safe_sum
FROM sqld_emp;

-- 5) 부서별 집계: 지원 부서는 사원이 없어 COUNT(e.emp_id)=0, SUM(e.salary)=NULL이다.
SELECT d.dept_id,
       d.dept_name,
       COUNT(e.emp_id) AS emp_count,
       SUM(e.salary) AS salary_sum,
       NVL(SUM(e.salary), 0) AS salary_sum_zero
FROM sqld_dept d
LEFT JOIN sqld_emp e ON e.dept_id = d.dept_id
GROUP BY d.dept_id, d.dept_name
ORDER BY d.dept_id;

-- 6) WHERE에서 NULL 비교의 오답 예시: 이 조회는 0행이다.
SELECT emp_id, emp_name
FROM sqld_emp
WHERE bonus = NULL
ORDER BY emp_id;
