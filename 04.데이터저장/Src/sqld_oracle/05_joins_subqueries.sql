-- 05. 조인과 서브쿼리 (Oracle Database 19c)

-- 1) INNER JOIN: 부서가 NULL인 채원은 제외된다. 예상 7행
SELECT e.emp_id, e.emp_name, d.dept_name, e.salary
FROM sqld_emp e
JOIN sqld_dept d ON d.dept_id = e.dept_id
ORDER BY e.emp_id;

-- 2) LEFT OUTER JOIN: 모든 사원을 보존하고 미배정 부서는 '미배정'으로 표시한다.
SELECT e.emp_id, e.emp_name, NVL(d.dept_name, '미배정') AS dept_name
FROM sqld_emp e
LEFT JOIN sqld_dept d ON d.dept_id = e.dept_id
ORDER BY e.emp_id;

-- 3) SELF JOIN: 사원과 관리자 이름
SELECT e.emp_id,
       e.emp_name,
       NVL(m.emp_name, '관리자 없음') AS manager_name
FROM sqld_emp e
LEFT JOIN sqld_emp m ON m.emp_id = e.manager_id
ORDER BY e.emp_id;

-- 4) 단일행 서브쿼리: 전체 평균 급여(3937.5)보다 높은 사원 4명
SELECT emp_id, emp_name, salary
FROM sqld_emp
WHERE salary > (SELECT AVG(salary) FROM sqld_emp)
ORDER BY salary DESC, emp_id;

-- 5) 상관 서브쿼리: 각 사원의 부서 평균보다 높은 사원
SELECT e.emp_id, e.emp_name, e.dept_id, e.salary
FROM sqld_emp e
WHERE e.dept_id IS NOT NULL
  AND e.salary > (
    SELECT AVG(x.salary)
    FROM sqld_emp x
    WHERE x.dept_id = e.dept_id
  )
ORDER BY e.dept_id, e.emp_id;

-- 6) 의도된 NOT IN 함정: sqld_blocked_dept에 NULL이 있으므로 결과는 0행이다.
SELECT e.emp_id, e.emp_name, e.dept_id
FROM sqld_emp e
WHERE e.dept_id NOT IN (SELECT b.dept_id FROM sqld_blocked_dept b)
ORDER BY e.emp_id;

-- 7) NULL에 안전한 대안 NOT EXISTS: 차단되지 않은 비NULL 부서 사원 5명
SELECT e.emp_id, e.emp_name, e.dept_id
FROM sqld_emp e
WHERE e.dept_id IS NOT NULL
  AND NOT EXISTS (
    SELECT 1
    FROM sqld_blocked_dept b
    WHERE b.dept_id = e.dept_id
  )
ORDER BY e.emp_id;
