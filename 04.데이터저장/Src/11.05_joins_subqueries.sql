-- sqld_my_lab
-- sqld_emp, sqld_dept 를 inner join 하여 e.emp_id, e.emp_name,d.dept_name, e.salary를 조회

/*
테이블 별칭 : 사원테이블은 e, 부서테이블은 d로 지정
부서가 배정되지 않은 사원은 제외
결과는 사원번호로 오름차순
*/  

SELECT e.emp_id, e.emp_name, d.dept_name, e.salary
FROM sqld_emp e
INNER JOIN sqld_dept d ON e.dept_id = d.dept_id;
ORDER BY e.emp_id;

/* 
= LEFT JOIN : 부서가 배정되지 않은 사원도 조회
- sqld_emp(사원)와 sqld_dept(부서) 테이블을 dept_id로 연결하여 사원번호, 사원명, 부서명을 조회하는 SQL을 작성
- 조건
 1. 테이블 별칭 : 사원테이블은 e, 부서테이블은 d로 지정 as를 사용
 2. 부서가 배정되지 않은 사원도 조회
 3. 결과는 사원번호로 오름차순 
*/

SELECT e.emp_id, e.emp_name, d.dept_name
FROM sqld_emp AS e
LEFT JOIN sqld_dept AS d ON e.dept_id = d.dept_id
ORDER BY e.emp_id;


/* 
SELF JOIN : 자기 자신과 조인
1. sqld_emp 테이블을 사원 테이블과 관리자 테이블로 각각 별칭을 지정하여 사용
2. JOIN ON : ???
3. 관리자가 없는 사원은 '관리자 없음'으로 표시
*/

SELECT e.emp_id, e.emp_name, e.manager_id,
       COALESCE(m.emp_name, '관리자 없음') AS mgr_name
FROM sqld_emp AS e
LEFT JOIN sqld_emp AS m ON e.manager_id = m.emp_id
ORDER BY e.emp_id;


/* 
= 서브쿼리
1. 단일쿼리(Single Query) : 하나의 SQL문장 안에서 다른 SQL을 포함하지 않는 독립적인 쿼리
2. 단일 서브쿼리(Subquery) : 하나의 SQL문장 안에 다른 SELECT 문을 포함 내부 결과를 외부에서 사용
3. 상관 서브쿼리(Correlated Subquery) : 내부 쿼리가 외부 쿼리의 컬럼을 참조하는 서브쿼리

시험문제
- 상관 서브쿼리는 외부 쿼리의 컬럼을 참조
- 일반 서브쿼리는 외부 쿼리와 독립적으로 작성
- 상관 서브쿼리는 외부 쿼리의 각 행과 연관된 결과를 계산하는 형태로 동작
*/  

/*
= 단일행 서브쿼리 - 전체 평균 급여보다 높은 사원 조회
- sqld_emp 테이블에서 전체 사원의 평균 급여보다 높은 급여를 받는 사원의 정보를 조회
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
select * from sqld_emp;
select * from sqld_dept;
*/

select * from sqld_emp;
select * from sqld_dept;

-- 상관 쿼리 분석
-- 1. 서브 쿼리만 따로 실행 : 값 하나를 돌려주는 서브쿼리임
SELECT avg(salary) from sqld_emp WHERE dept_id = 10;

--2. 1번 결과값을 바깥 쿼리에 끼워넣기
SELECT emp_name, salary
FROM sqld_emp
WHERE dept_id = 10 
  AND salary > (SELECT AVG(salary) from sqld_emp WHERE dept_id = 10);

-- 3. 문제점 : 부서마다 따로 쿼리를 써야함
-- 4. 숫자를 바깥 행의 값으로 바꾸기
SELECT e1.emp_name, e1.salary
FROM sqld_emp e1
WHERE e1.salary > (SELECT AVG(e2.salary) from sqld_emp e2 WHERE e1.dept_id = e2.dept_id);
