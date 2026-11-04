USE sqld_mysql_lab;

-- sqld_emp 단순조회, emp_id를 기준으로 정렬(ASC)
SELECT emp_id, emp_name, dept_id, salary, bonus, hire_date
FROM sqld_emp
ORDER BY emp_id;

-- 산술식: bonus가 NULL이면 salary + bonus도 NULL이다 
SELECT emp_id, emp_name, salary, bonus, salary + bonus AS pay_with_bonus
FROM sqld_emp
ORDER BY emp_id;

-- COALESCE() : 처음 만나는 NULL이 아닌값을 반환  
SELECT emp_id, emp_name,
	   -- 총급여 계산, bonus가 NULL아니면 bonus값을 사용, bonus가 NULL이면 0을 사용 
       salary + COALESCE(bonus, 0) AS total_by_coalesce,
	   -- COALESCE와 동일  
       salary + IFNULL(bonus, 0) AS total_by_ifnull
FROM sqld_emp
ORDER BY total_by_coalesce DESC, emp_id;

-- 직원 정보 조회
-- 급여가 3,500 이상 5,000 이하이면서, 입사일이 2022년 1월 1일 이후인 직원의 사원번호, 이름, 급여, 입사일을 조회  
-- BETWEEN(양 끝 포함), AND. hire_date 열은 DATE 형식
SELECT emp_id, emp_name, salary, hire_date
FROM sqld_emp
WHERE salary BETWEEN 3500 AND 5000
  AND hire_date >= '2022-01-01'
ORDER BY hire_date, emp_id;

/*
문제. 다음 조건을 만족하는 직원 정보를 조회하는 SQL문을 작성
- 조회 테이블: sqld_emp
- 부서번호가 10번 또는 30번인 직원  : in 
- 직원 이름이 한 글자 이상의 문자열로 구성된 직원 : _%
- 조회 컬럼: 사원번호(emp_id), 직원 이름(emp_name), 부서번호(dept_id)
- 정렬 조건: 부서번호 오름차순, 사원번호 오름차순
*/
SELECT emp_id, emp_name, dept_id
FROM sqld_emp
WHERE dept_id IN (10, 30)
	AND emp_name LIKE '_%'
ORDER BY dept_id, emp_id;

/*
= 부서 목록 조회 및 정렬
sqld_emp 테이블에서 직원들이 소속된 부서 번호(dept_id)를 조회
단, 다음 조건을 만족하도록 SQL문을 작성
- 부서 번호는 중복 없이 한 번씩만 조회
- 부서 번호는 오름차순으로 정렬
- 부서 번호가 NULL인 데이터는 가장 마지막에 표시 ??
*/
SELECT DISTINCT dept_id
FROM sqld_emp
ORDER BY  dept_id IS NULL, dept_id;

/*
= 직원별 급여 등급 조회
sqld_emp 테이블에서 직원의 사번(emp_id), 이름(emp_name), 급여(salary)를 조회하고, 급여 수준에 따라 등급을 분류

단, 다음 조건을 만족하도록 SQL문을 작성
- 급여가 5,000 이상이면 '상'으로 분류
-  급여가 3,500 이상 5,000 미만이면 '중'으로 분류
-  급여가 3,500 미만이면 '하'로 분류
-  등급 컬럼의 별칭은 salary_band로 지정
*/
-- CASE문  
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

/*
= 직원 정보의 문자열 및 입사일 가공

sqld_emp 테이블에서 직원의 사번(emp_id), 이름(emp_name), 부서 번호(dept_id), 입사일(hire_date)을 조회하고, 다음 조건에 따라 데이터를 가공하여 출력

단, 다음 조건을 만족하도록 SQL문을 작성
- 직원 이름의 글자 수를 CHAR_LENGTH() 함수로 계산하고 별칭을 char_count로 지정
- 직원 이름의 바이트 수를 LENGTH() 함수로 계산하고 별칭을 byte_count로 지정
- 직원 이름의 첫 번째 글자를 SUBSTRING() 함수로 추출하고 별칭을 first_char로 지정
- 직원 이름과 부서 번호를 괄호로 연결하여 출력하고 별칭을 concat_null_propagates로 지정
- 입사일을 연도와 월(YYYY-MM) 형식으로 변환하고 별칭을 hire_yyyymm으로 지정
- 사번(emp_id)을 기준으로 오름차순 정렬한다.
*/
--  문자열 함수와 날짜 함수 5가지를 실습
SELECT emp_id,
       emp_name,
       CHAR_LENGTH(emp_name) AS char_count,
       LENGTH(emp_name) AS byte_count,   -- utf-8에서 한글 한글자는 3Byte임 
       SUBSTRING(emp_name, 1, 1) AS first_char,  -- 시작위치 1번째 부터 추출할 문자 수 1글자  
       CONCAT(emp_name, '(', dept_id, ')') AS concat_null_propagates,
	   DATE_FORMAT(hire_date, '%Y-%m') AS hire_yyyymm
FROM sqld_emp
ORDER BY emp_id;

/*
sqld_emp 테이블에서 급여가 가장 높은 직원 3명의 사번(emp_id), 이름(emp_name), 급여(salary)를 조회

단, 다음 조건을 만족하도록 SQL문을 작성
- 급여(salary)를 기준으로 내림차순 정렬
- 급여가 동일한 경우 사번(emp_id)을 기준으로 오름차순 정렬
- 조회 결과는 최대 3명으로 제한한다.
*/
SELECT emp_id, emp_name, salary
FROM sqld_emp
ORDER BY salary DESC, emp_id
LIMIT 3;
       

       