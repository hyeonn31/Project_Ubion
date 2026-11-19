 # employees 데이터베이스는 금융 기관의 인사·급여 관리 시스템과 구조적으로 매우 유사
 /*
= employees : 직원 기본 정보
= departments : 부서 정보
= dept_emp : 직원-부서 소속 이력
= dept_manager : 부서 관리자 이력
= titles : 직함 이력(직원이 보유한 직함에 대한 변경 이력 저장 테이블)
= salaries : 급여 이력, 약 280만 건 데이터
*/

/*
= 테이블 간의 관계
employees → dept_emp : 1:N (직원은 여러 부서 소속 이력을 가짐)
departments → dept_emp : 1:N (부서는 여러 부서 소속 이력을 가짐)
employees → dept_manager : 1:N (직원은 여러 부서의 관리자 이력을 가짐)
departments → dept_manager : 1:N (부서는 여러 관리자 이력을 가짐) 
employees → titles : 1:N (직원은 여러 직함 이력을 가짐)
employees → salaries : 1:N (직원은 여러 급여 이력을 가짐)
*/

###########################
# 산술 연산 및 계산 컬럼
###########################
use employees;
# 연봉을 월급, 일급 으로 환산
SELECT 
    emp_no,
    salary   AS '연봉', 
    ROUND(salary / 12, 0)           AS '월급',
    ROUND(salary / 12 / 30, 0)      AS '일급'
FROM salaries
LIMIT 15;

-- 세금 공제 후 실수령액 계산 (소득세 22% 가정)
-- 고객아이디, 세전연봉, 세후연봉, 세금액, 세후월급
SELECT 
    emp_no,
    salary                              AS '세전연봉',
    ROUND(salary * 0.78, 0)             AS '세후연봉',
    ROUND(salary * 0.22, 0)             AS '세금액',
    ROUND(salary * 0.78 / 12, 0)         AS '세후월급'
FROM salaries
LIMIT 15;

-- 특정 직원의 급여 이력을 시간순으로 보기  
-- emp_no가 10001인 사람의 급여 이력, 이력이 시작된 날짜, 이력이 종료된 날짜 추출
desc salaries;
SELECT 
    emp_no,    -- 직원 번호 (식별자)
    salary,    -- 해당 기간의 급여액
    from_date, -- 급여 적용 시작일
    to_date    -- 급여 적용 종료일
FROM salaries
WHERE emp_no = '10001'
ORDER BY from_date;

-- 퇴직금 추정: 마지막 3개월 평균 급여 × 근속연수
-- CTE(Common Table Expression) : SQL에서 임시 결과 집합을 만들어 이름을 붙임, 이후 select문에서 사용
	# 서브쿼리보다 가독성이 좋음
/*
WITH 임시테이블명 AS (
    SELECT 컬럼명
    FROM 테이블명
    WHERE 조건
)
SELECT *
FROM 임시테이블명;
*/
# 직원 중 1990년 이후 입사자 조회
WITH new_employees AS (
    SELECT
        emp_no,
        first_name,
        last_name,
        hire_date
    FROM employees
    WHERE hire_date >= '1990-01-01'
)
SELECT *
FROM new_employees;

# CTE 여러 개 사용 : 부서별 직원 수와 평균 급여 조회
WITH dept_count AS (
    SELECT
        dept_no,
        COUNT(*) AS emp_count
    FROM dept_emp
    WHERE to_date = '9999-01-01'
    GROUP BY dept_no
),
dept_salary AS (
    SELECT
        de.dept_no,
        AVG(s.salary) AS avg_salary
    FROM dept_emp de
    JOIN salaries s
        ON de.emp_no = s.emp_no
    WHERE de.to_date = '9999-01-01'
      AND s.to_date = '9999-01-01'
    GROUP BY de.dept_no
)

-- #######################################
-- 직원별 최근 3개월 급여 평균 및 퇴직금 추정
	# 직원별 최근 3개월 동안의 평균 급여

WITH recent_salary AS (
	SELECT
		emp_no,
		AVG(salary) AS avg_salary
	FROM salaries
	WHERE to_date > DATE_SUB(CURDATE(), INTERVAL 3 MONTH)  -- 현재 날짜에서 3개월 전 날짜를 뺀 이후의 날짜
	GROUP BY emp_no
)

SELECT
    e.emp_no AS '직원번호',
    e.hire_date AS '입사일',
    TIMESTAMPDIFF(   -- e.hire_date:입사일 과 CURDATE():현재날짜에 대해 YEAR 단위로 차이를 계산하는 함수
        YEAR,
        e.hire_date,
        CURDATE()
    ) AS '근속연수',
    ROUND(
        (rs.avg_salary / 12)
        * TIMESTAMPDIFF(YEAR, e.hire_date, CURDATE()),
        0
    ) AS '퇴직금추정'

FROM employees e
INNER JOIN recent_salary rs
    ON e.emp_no = rs.emp_no
ORDER BY `퇴직금추정` DESC;





