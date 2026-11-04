-- sqld_mysql_lab
-- sqld_emp, sqld_dept 를 Inner join(=JOIN:교집합) 해서 e.emp_id, e.emp_name, d.dept_name, e.salary를 조회
/*
테이블 별칭 : 사원테이블은 e, 부서테이블은 d 
부서가 배정되지 않은 사원은 결과에서 제외 
결과는 사원번호로 오름차순
*/
use sqld_mysql_lab;

SELECT e.emp_id, e.emp_name, d.dept_name, e.salary
FROM sqld_emp AS e
JOIN sqld_dept AS d ON e.dept_id = d.dept_id
ORDER BY e.emp_id;

/*
= LEFT OUTER JOIN(= LEFT JOIN) 작성
- sqld_emp(사원)와 sqld_dept(부서) 테이블을 dept_id로 연결하여 사원번호, 사원명, 부서명을 조회하는 SQL을 작성
- 조건 
  1. 테이블 별칭은 사원 테이블은 e, 부서 테이블은 d로 하고 AS를 사용
  2. 부서가 배정되지 않은 사원도 결과에 모두 포함
  3. 부서가 없는 사원의 부서명은 NULL 대신 '미배정'으로 표시 : COALESCE
	 부서명 열의 별칭은 dept_name
  4. 결과는 사원번호 오름차순으로 정렬
  */
  SELECT e.emp_id, e.emp_name, COALESCE(d.dept_name, '미배정') AS dept_name
  FROM sqld_emp AS e
  LEFT JOIN sqld_dept  AS d ON d.dept_id = e.dept_id
  ORDER BY e.emp_id;
  
  /*
  = SELF JOIN – 사원과 관리자 이름 조회
  1. sqld_emp 테이블을 사원 테이블과 관리자 테이블로 각각 별칭을 지정하여 사용
  2 JOIN ON : ???  
  3. 관리자가 없는 사원은 '관리자 없음'으로 표시
  4. 사원 번호(emp_id)를 기준으로 오름차순
  */
  SELECT e.emp_id, e.emp_name, COALESCE(m.emp_name, '관리자 없음') AS manager_name
  FROM sqld_emp AS e
  LEFT JOIN sqld_emp AS m ON m.emp_id = e.manager_id
  ORDER BY e.emp_id;
  
  /*
  = 서브쿼리
  1. 단일 쿼리(Single Query) : 하나의 SQL문장 안에서 다른 SQL을 포함하지 않는 독립적인 쿼리
  2. 단일 서브쿼리(Subquery) : 하나의 SQL문장 안에 다른 SELECT문을 포함
     내부 결과를 외부에서 사용
  3. 상관 서브쿼리(Correlated Subquery) : 내부 쿼리가 외부 쿼리의 컬럼을 참조하는 서브쿼리
  
  시험문제 
  - 상관 서브쿼리는 외부 쿼리의 컬럼을 참조
  - 일반 서브쿼리는 외부 쿼리와 독립적으로 작성
  - 상관 서브쿼리는 외부 쿼리의 각 행과 연관된 결과를 계산하는 형태로 동작
  */

/*
= 단일행 서브쿼리 – 전체 평균 급여보다 높은 사원 조회
-  sqld_emp 테이블에서 전체 사원의 평균 급여보다 높은 급여를 받는 사원의 정보를 조회
   1. sqld_emp 테이블을 사용
   2. 서브쿼리를 이용하여 전체 사원의 평균 급여를 구함
   3. 전체 평균 급여보다 높은 급여를 받는 사원만 조회
   4. 급여(salary)를 기준으로 내림차순 정렬
   5. 급여가 동일한 경우 사원 번호(emp_id)를 기준으로 오름차순 정렬
*/
SELECT emp_id, emp_name, salary
FROM sqld_emp
WHERE salary > (SELECT AVG(salary) FROM sqld_emp)
ORDER BY salary DESC, emp_id;

/*
= 상관 서브쿼리
*/
select * from sqld_emp;
select * from sqld_dept;

-- 상관 서브쿼리 분석
-- 1. 서브쿼리만 따로 실행 : 값 하나를 돌려주는 서브쿼리임
SELECT AVG(salary) FROM sqld_emp WHERE dept_id = 10;

-- 2. 1번 결과값을 바깥 쿼리에 끼어 넣기
SELECT emp_name, salary
FROM sqld_emp
WHERE dept_id = 10
  AND salary > (SELECT AVG(salary) FROM sqld_emp WHERE dept_id = 10);

-- 3. 문제점 : 부서마다 따로 쿼리를 써야함  
-- 4. 숫자를 바깥 행의 값으로 바꾸기 
SELECT e.emp_name, e.salary
FROM sqld_emp AS e
WHERE e.dept_id IS NOT NULL 
  AND e.salary > (SELECT AVG(salary) 
			      FROM sqld_emp AS x
				  WHERE x.dept_id = e.dept_id
                  )
ORDER BY e.dept_id, e.emp_id;

-- 예제 1. 자기 부서에서 급여가 가장 높은 사원 
SELECT e.emp_id, e.emp_name, e.dept_id, e.salary
FROM sqld_emp AS e
WHERE e.salary = (
    SELECT MAX(x.salary)
    FROM sqld_emp AS x
    WHERE x.dept_id = e.dept_id
)
ORDER BY e.emp_id;

-- 예제 2. 부하 직원이 있는 사원, 즉 본인이 매니저인 사람 (EXISTS) 
-- 조건에 만족하면 1로 세팅, 최종은 1들을 합한 결과
SELECT * from sqld_emp;

SELECT 1
FROM sqld_emp
WHERE manager_id = 100;

SELECT EXISTS(
	SELECT 1
	FROM sqld_emp
	WHERE manager_id = 100
);

SELECT e.emp_id, e.emp_name
FROM sqld_emp AS e
WHERE EXISTS (
    SELECT 1
    FROM sqld_emp AS x
    WHERE x.manager_id = e.emp_id
)
ORDER BY e.emp_id;

-- 예제 3. 사원이 한 명도 없는 부서 (NOT EXISTS) 
SELECT d.dept_id, d.dept_name
FROM sqld_dept AS d
WHERE NOT EXISTS (
    SELECT 1
    FROM sqld_emp AS e
    WHERE e.dept_id = d.dept_id
);

-- 예제 4. 부서별 사원 수를 SELECT 절에서 구하기
	-- 상관 스칼라 서브쿼리 : 서브쿼리가 하나의 값을 반환 
SELECT d.dept_name,
       (SELECT COUNT(*)
        FROM sqld_emp AS e
        WHERE e.dept_id = d.dept_id) AS emp_count
FROM sqld_dept AS d
ORDER BY d.dept_id;

-- 예제 5. 나보다 급여가 높은 사람이 몇 명인가
SELECT e.emp_name, e.salary,
       (SELECT COUNT(*)
        FROM sqld_emp AS x
        WHERE x.salary > e.salary) AS higher_count
FROM sqld_emp AS e
ORDER BY e.salary DESC, e.emp_id;

/*
= NOT IN 함정 – NULL이 포함된 서브쿼리
- sqld_emp 테이블에서 차단된 부서에 소속되지 않은 사원 정보를 조회
1. sqld_emp 테이블에서 사원 정보를 조회
2. sqld_blocked_dept 테이블을 서브쿼리로 사용
3. 차단 목록에 포함된 부서 번호는 조회 대상에서 제외
4. NOT IN 연산자를 사용
5. 사원 번호(emp_id)를 기준으로 오름차순 정렬
*/
-- NULL이 없는 경우 
SELECT 30 NOT IN (10, 20);

-- NULL이 있는 경우  
SELECT 30 NOT IN (10, 20, NULL);

-- 비정상 / 결과 NULL
SELECT e.emp_id, e.emp_name, e.dept_id
FROM sqld_emp AS e
WHERE e.dept_id NOT IN (SELECT b.dept_id FROM sqld_blocked_dept AS b)
ORDER BY e.emp_id;

-- 정상 처리 
SELECT e.emp_id, e.emp_name, e.dept_id
FROM sqld_emp AS e
WHERE e.dept_id NOT IN (SELECT b.dept_id FROM sqld_blocked_dept AS b WHERE b.dept_id IS NOT NULL)
ORDER BY e.emp_id;

-- 문제 1. NOT IN과 NULL 
	-- 다음 SQL의 실행 결과로 올바른 것은?
SELECT *
FROM sqld_emp
WHERE dept_id NOT IN (10, 20, NULL);
-- 정답 : 조회 결과가 없다. 

/*
= NOT EXISTS – 차단되지 않은 부서의 사원 조회
- sqld_emp 테이블에서 차단 목록에 포함되지 않은 부서에 소속된 사원의 정보를 조회
1. sqld_emp 테이블에서 사원 정보를 조회
2. sqld_blocked_dept 테이블을 서브쿼리로 사용
3. NOT EXISTS를 사용하여 차단된 부서에 소속되지 않은 사원만 조회
4. 부서 번호(dept_id)가 NULL인 사원은 제외
5. 차단 목록에 NULL 값이 포함되어 있어도 정상적으로 조회
6. 사원 번호(emp_id)를 기준으로 오름차순 정렬
*/
SELECT e.emp_id, e.emp_name, e.dept_id
FROM sqld_emp AS e
WHERE e.dept_id IS NOT NULL
AND NOT EXISTS ( 
    SELECT 1
    FROM sqld_blocked_dept AS b
    WHERE b.dept_id = e.dept_id
  )
ORDER BY e.emp_id;

/*
= FROM절 서브쿼리 – 부서별 사원 수와 평균 급여 조회
- sqld_emp 테이블에서 부서별 사원 수와 평균 급여를 계산한 후, 사원 수가 2명 이상인 부서만 조회
1. sqld_emp 테이블을 사용
2. FROM절에 서브쿼리(파생 테이블)를 작성
3. 부서 번호(dept_id)가 NULL인 데이터는 제외
4. 부서 번호(dept_id)를 기준으로 그룹화
5. 각 부서의 사원 수와 평균 급여를 계산
6. 서브쿼리 결과 중 사원 수가 2명 이상인 부서만 조회
7. 부서 번호(dept_id)를 기준으로 오름차순 정렬
8. 파생 테이블에 반드시 별칭을 지정
*/
SELECT x.dept_id, x.emp_count, x.avg_salary
FROM(
	SELECT
		dept_id,
		COUNT(*) AS emp_count,
		AVG(salary) AS avg_salary
	FROM sqld_emp
	WHERE dept_id IS NOT NULL
	GROUP BY dept_id
) AS x
WHERE x.emp_count = 2
ORDER BY x.dept_id;






