USE sqld_mysql_lab;
/*
= UNION – 여러 부서의 사원 번호 통합 조회
- sqld_emp 테이블에서 개발 부서(부서 번호 10) 또는 분석 부서(부서 번호 20)에 소속된 사원의 번호를 조회
*/
SELECT emp_id
FROM sqld_emp
WHERE dept_id = 10
UNION
SELECT emp_id
FROM sqld_emp
WHERE dept_id = 20
ORDER BY emp_id;

/*
= UNION ALL – 여러 부서의 사원 정보 통합 조회
- sqld_emp 테이블에서 개발 부서(부서 번호 10) 또는 분석 부서(부서 번호 20)에 소속된 사원의 번호를 조회
- 각 사원이 어느 부서에서 조회되었는지 표시
1. 첫 번째 SELECT문에서 부서 번호가 10인 사원 번호를 조회
2. 첫 번째 SELECT문에는 출처를 나타내는 '개발'이라는 문자열을 추가
3. 두 번째 SELECT문에서 부서 번호가 20인 사원 번호를 조회
4. 두 번째 SELECT문에는 출처를 나타내는 '분석'이라는 문자열을 추가
5. 두 SELECT문의 결과를 UNION ALL로 결합
6. 중복된 데이터가 있더라도 제거하지 않음
7. 두 SELECT문을 FROM절의 파생 테이블로 구성하고 별칭을 지정
8. 출처(source_name), 사원 번호(emp_id) 순서로 오름차순 정렬
*/
SELECT x.source_name, x.emp_id
FROM (
  SELECT '개발' AS source_name, emp_id FROM sqld_emp WHERE dept_id = 10
  UNION ALL
  SELECT '분석' AS source_name, emp_id FROM sqld_emp WHERE dept_id = 20
) AS x
ORDER BY x.source_name, x.emp_id;

/*
UNION :  중복 제거, 처리 비용이 높음
UNION ALL : 중복 허용, 처리 비용이 낮음
*/

/*
=  INTERSECT – 두 조건을 모두 만족하는 사원 조회(교집합)
- sqld_emp 테이블에서 급여가 4,000 이상이면서 보너스가 NULL이 아닌 사원의 번호를 조회
*/
SELECT e.emp_id FROM sqld_emp AS e
WHERE e.salary >= 4000 
AND EXISTS (SELECT 1 FROM sqld_emp AS b WHERE b.emp_id = e.emp_id AND b.bonus IS NOT NULL);

-- INTERSECT : Ver 8.0.30 이하에서는 사용 불가  
SELECT emp_id
FROM sqld_emp
WHERE salary >= 4000
INTERSECT   
SELECT emp_id
FROM sqld_emp
WHERE bonus IS NOT NULL
ORDER BY emp_id;

SELECT VERSION();   -- MySQL 버전확인 : 

/*
= EXCEPT – 차집합을 이용한 사원 조회
- sqld_emp 테이블에서 급여가 4,000 이상인 사원 중 보너스가 NULL인 사원의 번호를 조회
1. 첫 번째 SELECT문에서 급여(salary)가 4,000 이상인 사원의 번호를 조회
2. 두 번째 SELECT문에서 보너스(bonus)가 NULL이 아닌 사원의 번호를 조회
3. 두 SELECT문의 결과를 EXCEPT 연산자로 결합
4. 첫 번째 SELECT 결과에서 두 번째 SELECT 결과에 포함된 사원을 제외
5. 사원 번호(emp_id)를 기준으로 오름차순 정렬
*/
SELECT e.emp_id FROM sqld_emp AS e
WHERE e.salary >= 4000 
AND NOT EXISTS (SELECT 1 FROM sqld_emp AS b WHERE b.emp_id = e.emp_id AND b.bonus IS NOT NULL);

SELECT emp_id
FROM sqld_emp
WHERE salary >= 4000
EXCEPT   
SELECT emp_id
FROM sqld_emp
WHERE bonus IS NOT NULL
ORDER BY emp_id;

/*
= GROUP BY / HAVING – 급여 합계가 10,000 이상인 부서 조회
- sqld_dept 테이블과 sqld_emp 테이블을 JOIN하여 부서별 사원 수와 급여 합계를 조회
1. sqld_dept와 sqld_emp 테이블을 INNER JOIN
2. 부서 번호(dept_id)를 기준으로 두 테이블을 연결
3. 부서 번호와 부서 이름을 기준으로 그룹화
4. 부서별 사원 수를 계산
5. 부서별 급여 합계를 계산
6. 급여 합계가 10,000 이상인 부서만 조회
7. 부서 번호(dept_id)를 기준으로 오름차순 정렬
*/
SELECT d.dept_id, d.dept_name, COUNT(e.emp_id) AS emp_count, SUM(e.salary) AS salary_sum
FROM sqld_dept AS d
JOIN sqld_emp AS e ON e.dept_id = d.dept_id
GROUP BY d.dept_id, d.dept_name
HAVING SUM(e.salary) >= 10000
ORDER BY d.dept_id;

/*
= ROLLUP – 부서별 매출 합계와 전체 합계 조회
- sqld_sales 테이블에서 부서별 매출 합계와 전체 매출 합계를 함께 조회
1. sqld_sales 테이블을 사용
2. 부서 번호(dept_id)를 기준으로 매출 합계(amount)를 계산
3. GROUP BY ... WITH ROLLUP을 사용하여 전체 합계 행을 추가
4. GROUPING(dept_id) 함수를 사용하여 일반 그룹 행과 전체 합계 행을 구분
5. 전체 합계 행의 부서 번호는 NULL로 표시
6. 파생 테이블(Derived Table)을 사용하고 별칭을 지정
7. 일반 부서별 합계가 먼저 나오고 전체 합계가 마지막에 나오도록 정렬
*/
-- Group By만 실행
SELECT
    dept_id,
    SUM(amount) AS amount_sum
FROM sqld_sales
GROUP BY dept_id;

-- WITH ROLLUP 추가
SELECT
    dept_id,
    SUM(amount) AS amount_sum
FROM sqld_sales
GROUP BY dept_id WITH ROLLUP;

-- GROUPING() 사용, 결과 1은 ROLLUP에 의한 전체 집계, 0은 Data에 의한 집계
SELECT
    dept_id,
    SUM(amount) AS amount_sum,
    GROUPING(dept_id) AS grouping_flag
FROM sqld_sales
GROUP BY dept_id WITH ROLLUP;

-- CASE WHEN 
CASE
    WHEN GROUPING(dept_id) = 1 THEN '전체 합계'
    WHEN dept_id IS NULL THEN '부서 미지정'
    ELSE CAST(dept_id AS CHAR)
END AS dept_name

-- 전체 코드
SELECT x.dept_id, x.amount_sum, x.is_grand_total
FROM (
	SELECT CASE WHEN GROUPING(s.dept_id) = 1 THEN '전체 합계' ELSE s.dept_id END AS dept_id,
		   SUM(s.amount) AS amount_sum,
		   GROUPING(s.dept_id) AS is_grand_total
	FROM sqld_sales AS s
	GROUP BY s.dept_id WITH ROLLUP
) AS x
ORDER BY x.is_grand_total, x.dept_id;

/*
= 윈도우 함수 종류 : 크게 5가지 
- Group By는 부서별 평균 급여를 계산하면 부서당 한 행만 반환하지만 윈도우 함수는 원래 행을 하나로 합치지 않고 각 행에 계산 결과를 추가하는 함수 
1.순위 함수 : ROW_NUMBER(), RANK(), DENSE_RANK() - 순위 계산 
2.분포 함수 : PERCENT_RANK(), CUME_DIST(), NTILE() - 백분률 및 그룹 분할 
3.행 탐색 함수 : LAG(), LEAD() - 이전 행, 다음 행 조회
4.값 선택 함수 : FIRST_VALUE(), LAST_VALUE(), NTH_VALUE() : 특정 위치값 조회
5.집계 함수 : SUM(), AVG(), COUNT(), MAX(), MIN()
*/ 

-- 1.순위함수
 -- 예제 1. 전체 사원의 급여 순번 조회 : ROW_NUMBER()
 /*
 ROW_NUMBER() : 조회된 결과에 1부터 시작하는 순번을 부여하는 윈도우 함수
 OVER : ()를 기준으로 윈도우 함수를 실행함
 
 급여가 높은 사원부터 1번을 부여
 급여가 같아도 서로 다른 번호를 부여
 */
SELECT emp_id,
       emp_name,
       salary,
       ROW_NUMBER() OVER (
           ORDER BY salary DESC
       ) AS row_no
FROM sqld_emp;

-- 예제 2. 부서별 급여 순위 조회
SELECT dept_id,
       emp_id,
       emp_name,
       salary,
       RANK() OVER (
           PARTITION BY dept_id
           ORDER BY salary DESC
       ) AS salary_rank
FROM sqld_emp
WHERE dept_id IS NOT NULL
ORDER BY dept_id, salary_rank;

-- 예제 3. 부서별 급여 순위 3종 비교
/*
ROW_NUMBER() : 고유한 일련번호, 서로 다른 번호 부여, 연속적으로 증가, 중복 일련번호 없음
RANK() : 순위, 값이 같으면 같은 번호 부여, 공동 순위만큼 증가, 중복 순위 있음
DENSE_RANK() : RANK()동일, 연속적으로 증가
*/
SELECT emp_id,
       emp_name,
       salary,
       ROW_NUMBER() OVER (
           ORDER BY salary DESC
       ) AS row_no,       
       RANK() OVER (
--            PARTITION BY dept_id
           ORDER BY salary DESC
       ) AS salary_rank,
       DENSE_RANK() OVER (
           -- PARTITION BY dept_id
           ORDER BY salary DESC
       ) AS dense_rank1       
FROM sqld_emp;
-- WHERE dept_id I-- S NOT NULL
-- ORDER BY dept_id, row_no;

/*
= 윈도우 함수 – 부서별 급여 순위 조회
-  sqld_emp 테이블에서 부서별 사원의 급여 순위를 계산
1. sqld_emp 테이블을 사용
2. 부서 번호(dept_id)가 NULL인 사원은 제외
3. PARTITION BY를 사용하여 부서별로 순위를 계산
4. 급여(salary)가 높은 순서대로 정렬
5. ROW_NUMBER()를 사용하여 부서별 고유 순번을 부여
6. RANK()를 사용하여 동일 급여에 같은 순위를 부여
7. DENSE_RANK()를 사용하여 동일 급여에 같은 순위를 부여하되 다음 순위는 연속됨
8. 최종 결과는 부서 번호와 행 번호(row_no) 순서로 오름차순 정렬
*/
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


-- 2. 분포함수 
  -- PERCENT_RANK(), CUME_DIST(), NTILE() 
  -- 데이터의 상대적인 위치를 계산하거나 여러 그룹으로 나눔 
  
-- 예제 1. 급여의 상대적 순위 비율 : PERCENT_RANK()
/*
PERCENT_RANK() : 단순히 전체 인원 중 몇 번째인지 계산하는 것이 아니라, 최솟값 0 ~ 최댓값 1을 기준으로 상대적인 순위 위치를 정규화하는 함수 
  - 결과는 0부터 1 사이의 값
  - 0에 가까울수록 낮은 순위, 1에 가까울수록 높은 순위
  - 계산식은 (RANK() - 1) / (전체 행 수 - 1)
    : 분자에서 1을 빼는 이유 : 시작 순위를 0으로 만들기 위해
    : 분모에서 1을 빼는 이유 : 첫 번째 순위와 마지막 순위 사이의 간격을 계산하기 위해 
*/
SELECT emp_id,
       emp_name,
       salary,
       PERCENT_RANK() OVER (
           ORDER BY salary
       ) AS percent_rank1
FROM sqld_emp;

-- 예제 2. 급여 누적 분포 비율 : CUME_DIST()
/*
CUME_DIST() : 현재 값 이하인 값들이 전체에서 차지하는 비율을 계산 
- ex) : 현재 급여 이하인 사원들이 전체비중에서 차지하는 비율을 계산 / 연봉 4천이하인 직원들의 % 
*/
SELECT emp_id,
       emp_name,
       salary,
       CUME_DIST() OVER (
           ORDER BY salary
       ) AS cumulative_dist
FROM sqld_emp;

-- 예제 3. 급여 기준 4개 그룹으로 분할 : NTILE()
/*
NTILE() : 기준값에 따라 그룹핑 하는 함수
*/
SELECT emp_id,
       emp_name,
       salary,
       NTILE(4) OVER (
           ORDER BY salary DESC
       ) AS salary_group
FROM sqld_emp;

-- 3. 행 탐색 함수
  -- LAG(), LEAD() : 현재 행을 기준으로 이전 행이나 다음 행의 값
  -- LAG(컬럼명, 이동할 행 수, 기본값) : 기본값 / 내가 찾고자 하는 값이 없으면 0으로 반환 

-- 예제 1. 이전 사원의 급여 조회
SELECT emp_id,
       emp_name,
       salary,
       LAG(salary) OVER (
           ORDER BY emp_id
       ) AS previous_salary
FROM sqld_emp;

-- 예제 2. 다음 사원의 급여 조회
SELECT emp_id,
       emp_name,
       salary,
       LEAD(salary) OVER (
           ORDER BY emp_id
       ) AS next_salary
FROM sqld_emp;

-- 4. 값 선택 함수  
  -- FIRST_VALUE(), LAST_VALUE(), NTH_VALUE()
  
-- 예제 1. 전체 사원 중 가장 높은 급여 조회
SELECT emp_id,
       emp_name,
       salary,
       FIRST_VALUE(salary) OVER (
           ORDER BY salary DESC
       ) AS highest_salary
FROM sqld_emp;

-- 예제 2. 부서별 가장 낮은 급여 조회
   -- 우리 부서의 최저 급여  
   /*
   UNBOUNDED PRECEDING = 그룹의 맨 처음부터
   UNBOUNDED FOLLOWING = 그룹의 맨 끝까지
   */
SELECT dept_id,
       emp_id,
       emp_name,
       salary,
       LAST_VALUE(salary) OVER (
           PARTITION BY dept_id
           ORDER BY salary DESC
           ROWS BETWEEN UNBOUNDED PRECEDING
                    AND UNBOUNDED FOLLOWING
       ) AS lowest_salary
FROM sqld_emp
WHERE dept_id IS NOT NULL;

-- 예제 3. 부서별 급여가 두 번째로 높은 행의 급여 조회
SELECT dept_id,
       emp_id,
       emp_name,
       salary,
       NTH_VALUE(salary, 2) OVER (
           PARTITION BY dept_id
           ORDER BY salary DESC, emp_id
           ROWS BETWEEN UNBOUNDED PRECEDING
                    AND UNBOUNDED FOLLOWING
       ) AS second_salary
FROM sqld_emp
WHERE dept_id IS NOT NULL;

 -- 5.집계 함수 
    -- SUM(), AVG(), COUNT(), MAX(), MIN()
-- 예제 1. 부서별 급여 합계 조회 

-- 일반 집계 함수 SUM()
SELECT dept_id,
       SUM(salary) AS dept_salary_sum
FROM sqld_emp
WHERE dept_id IS NOT NULL
GROUP BY dept_id;

-- 윈도우 집계 함수 SUM() OVER()
SELECT emp_id,
       emp_name,
       dept_id,
       salary,
       SUM(salary) OVER (
           PARTITION BY dept_id
       ) AS dept_salary_sum
FROM sqld_emp
WHERE dept_id IS NOT NULL;

-- 예제 2. 부서별 평균 급여와 사원 급여 비교
/*
avg_salary: 해당 부서의 평균 급여
salary_diff: 사원 급여와 부서 평균 급여의 차이
양수라면 평균보다 급여가 높고, 음수라면 낮음 
*/
SELECT emp_id,
       emp_name,
       dept_id,
       salary,

       AVG(salary) OVER (
           PARTITION BY dept_id
       ) AS avg_salary,
       salary - AVG(salary) OVER (
           PARTITION BY dept_id
       ) AS salary_diff
FROM sqld_emp
WHERE dept_id IS NOT NULL;

-- 예제 3. 부서별 급여 누적 합계 계산
  -- CURRENT ROW : 현재 위치한 행을 가리킴
SELECT emp_id,
       emp_name,
       dept_id,
       salary,
       SUM(salary) OVER (
           PARTITION BY dept_id
           ORDER BY emp_id
           ROWS BETWEEN UNBOUNDED PRECEDING
                    AND CURRENT ROW
       ) AS cumulative_salary

FROM sqld_emp
WHERE dept_id IS NOT NULL
ORDER BY dept_id, emp_id;















