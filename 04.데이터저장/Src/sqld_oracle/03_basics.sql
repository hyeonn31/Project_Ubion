-- 03. SELECT 기초 (Oracle Database 19c)

-- 1) 전체 열과 정렬
SELECT emp_id, emp_name, dept_id, salary, bonus, hire_date
FROM sqld_emp
ORDER BY emp_id;

-- 2) 산술식: bonus가 NULL이면 salary + bonus도 NULL이다.
SELECT emp_id, emp_name, salary, bonus, salary + bonus AS pay_with_bonus
FROM sqld_emp
ORDER BY emp_id;

-- 3) 별칭과 NVL: NULL 보너스를 0으로 바꾼 보상액
SELECT emp_id, emp_name, salary + NVL(bonus, 0) AS total_compensation
FROM sqld_emp
ORDER BY total_compensation DESC, emp_id;

-- 4) 비교, BETWEEN(양 끝 포함), AND
SELECT emp_id, emp_name, salary, hire_date
FROM sqld_emp
WHERE salary BETWEEN 3500 AND 5000
  AND hire_date >= DATE '2022-01-01'
ORDER BY hire_date, emp_id;

-- 5) IN과 LIKE
SELECT emp_id, emp_name, dept_id
FROM sqld_emp
WHERE dept_id IN (10, 30)
  AND emp_name LIKE '_%'
ORDER BY dept_id, emp_id;

-- 6) DISTINCT: 실제 배정된 부서만 반환하며 NULL도 하나의 값으로 취급된다.
SELECT DISTINCT dept_id
FROM sqld_emp
ORDER BY dept_id NULLS LAST;

-- 7) CASE 표현식
SELECT emp_id,
       emp_name,
       salary,
       CASE
         WHEN salary >= 5000 THEN '상'
         WHEN salary >= 3500 THEN '중'
         ELSE '하'
       END AS salary_band
FROM sqld_emp
ORDER BY emp_id;
