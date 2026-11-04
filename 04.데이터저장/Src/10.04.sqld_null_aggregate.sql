USE sqld_mysql_lab;
/*
=  보너스 미지급 직원 조회

sqld_emp 테이블에서 보너스(bonus)가 지급되지 않은 직원의 사번(emp_id), 이름(emp_name), 보너스(bonus)를 조회

단, 다음 조건을 만족하도록 SQL문을 작성
- 보너스(bonus)가 NULL인 직원만 조회
- 조회할 컬럼은 사번, 이름, 보너스로 제한
- 사번(emp_id)을 기준으로 오름차순 정렬
*/
SELECT emp_id, emp_name, bonus
FROM sqld_emp
WHERE bonus IS NULL
ORDER BY emp_id;

/*
= 집계 함수와 NULL 처리 : 직원 보너스 통계 조회
sqld_emp 테이블에서 전체 직원 수와 보너스 지급 현황을 집계하여 조회

단, 다음 조건을 만족하도록 SQL문을 작성
- 전체 직원 수를 COUNT(*) 함수로 계산하고 별칭을 all_rows로 지정
- 보너스가 NULL이 아닌 직원 수를 COUNT(bonus) 함수로 계산하고 별칭을 bonus_not_null_rows로 지정
- 전체 보너스 지급액의 합계를 SUM() 함수로 계산하고 별칭을 bonus_sum으로 지정
- 보너스 평균 지급액을 AVG() 함수로 계산하고 별칭을 bonus_avg로 지정
*/
SELECT COUNT(*) AS all_rows,
       COUNT(bonus) AS bonus_not_null_rows,
       SUM(bonus) AS bonus_sum,
       AVG(bonus) AS bonus_avg
FROM sqld_emp;

/*
= NULL 보너스를 0으로 처리한 보너스 통계 조회 : COALESCE와 IFNULL을 이용한 NULL 처리
* sqld_emp 테이블에서 직원들의 보너스(bonus)를 집계

단, 다음 조건을 만족하도록 SQL문을 작성하시오.
- COALESCE() 함수를 사용하여 보너스가 NULL인 경우 0으로 변환한 후 전체 보너스 합계를 계산하고, 별칭은 bonus_zero_sum으로 지정
- IFNULL() 함수를 사용하여 보너스가 NULL인 경우 0으로 변환한 후 보너스 평균을 계산하고, 별칭은 avg_bonus_zero로 지정
*/
SELECT SUM(COALESCE(bonus, 0)) AS bonus_zero_sum,
       AVG(IFNULL(bonus, 0)) AS avg_bonus_zero
FROM sqld_emp;

/*
= 월별 급여와 보너스를 합산한 총 지급액 조회 :  NULL 연산과 COALESCE 함수 활용
* sqld_emp 테이블에서 직원들의 급여(salary)와 보너스(bonus)를 합산하여 전체 지급액을 계산

단, 다음 조건을 만족하도록 SQL문을 작성
- 급여와 보너스를 직접 더한 후 SUM() 함수를 사용하여 전체 합계를 계산하고, 별칭은 raw_sum으로 지정
- 보너스가 NULL인 경우 COALESCE() 함수를 사용하여 0으로 변환한 후 급여와 합산
 NULL을 0으로 처리한 급여와 보너스의 전체 합계를 SUM() 함수로 계산하고, 별칭은 safe_sum으로 지정
 */
SELECT SUM(salary + bonus) AS raw_sum,
       SUM(salary + COALESCE(bonus, 0)) AS safe_sum
FROM sqld_emp;

/*
= 부서별 직원 수 및 급여 합계 조회 : LEFT JOIN과 GROUP BY를 이용한 부서별 통계 조회
* sqld_dept 테이블과 sqld_emp 테이블을 조인하여 부서별 직원 수와 급여 합계를 조회

단, 다음 조건을 만족하도록 SQL문을 작성
- 부서 정보는 sqld_dept 테이블을 기준으로 조회
- 직원이 없는 부서도 조회될 수 있도록 LEFT JOIN을 사용
- 부서 번호(dept_id)를 기준으로 두 테이블을 조인
- 부서별 직원 수를 COUNT() 함수로 계산하고 별칭은 emp_count로 지정
- 부서별 급여 합계를 SUM() 함수로 계산하고 별칭은 salary_sum으로 지정
- 급여 합계가 NULL인 경우 COALESCE() 함수를 사용하여 0으로 변환하고 별칭은 salary_sum_zero로 지정
- 부서 번호와 부서명을 기준으로 그룹화
- 부서 번호를 기준으로 오름차순 정렬
*/
SELECT d.dept_id,
	   d.dept_name,
	   COUNT(e.emp_id) AS emp_count,
       SUM(e.salary) AS salary_sum,
       COALESCE(SUM(e.salary), 0) AS salary_sum_zero
FROM sqld_dept AS d
LEFT JOIN sqld_emp AS e ON e.dept_id = d.dept_id
GROUP BY d.dept_id, d.dept_name
ORDER BY d.dept_id;



