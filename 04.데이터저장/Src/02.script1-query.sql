-- usertbl 전체 조회 
-- userID가 primary key로 지정되어 있어 자동으로 클러스터 인덱스가 생성되어 정렬됨 
use sqldb;
select * from usertbl;

-- buytbl 전체 조회 
SELECT * FROM buytbl;

 -- 김경호 정보 찾기
SELECT * FROM usertbl WHERE name = '김경호';

/*
= 조건연산자 : =, <, >, <=,  >=, != 등
= 관계연산자 : NOT, AND, OR등
*/

-- Mission : 1970년 이후에 출생하고 신장이 182이상 사람의 아이디와 이름을 조회
SELECT * FROM usertbl WHERE birthYear >=1970  AND height >= 182;

 -- 1970년 이후에 출생했거나, 신장이 182이상인 사람의 아이디와 이름을 조회
 SELECT * FROM usertbl WHERE birthYear >=1970  OR height >= 182;
 
 -- ##############################################
 -- where 뒤에 오는 것들 
	-- BETWEEN … AND, IN(), LIKE
	-- ANY/ALL/SOME/서브 쿼리
    -- ORDER BY
    -- DISTINCT
	-- LIMIT
 -- ##############################################
 
-- #### BETWEEN … AND, IN(), LIKE ###
-- between and
-- 신장이 180보다 크거가 같과 183보다 작거나 같은 사람의 이름과 키를 추출
SELECT name, height FROM usertbl WHERE height >=180  and  height <= 183;
SELECT name, height FROM usertbl WHERE height between 180 and 183;

-- IN 지역이 경남, 전남, 경북인 사람의 정보를 보여주기(이산적인 값)
SELECT name, addr FROM usertbl WHERE addr = '경남' OR addr = '전남' OR addr = '경북' ;
SELECT name, addr FROM usertbl WHERE addr IN('경남', '전남', '경북');

-- 문자열 검색(LIKE) : 대량의 데이터의 경우 나쁜 성능을 미칠 수 있음 
-- % : 여러 글자 매핑 
SELECT name, height FROM usertbl WHERE name LIKE '김%';

-- _ : 한글자 매핑 
SELECT name, height FROM usertbl WHERE name LIKE '_종신';

-- #### ANY/ALL/SOME/서브 쿼리 ### 서브쿼리란 쿼리문 안에 다른 쿼리문이 있는 것을 말함 
-- 키가 김경호보다 큰사람 추출
SELECT height FROM usertbl WHERE Name = '김경호';   -- 177 
SELECT name, height FROM usertbl WHERE height > 177;

SELECT name, height FROM usertbl
  WHERE height > (SELECT height FROM usertbl WHERE Name = '김경호');    
  
-- 지역이 ‘경남’사람의 키보다 크거나 같은 사람을 추출 
-- Error : 하위쿼리가 둘 이상의 값을 반환하면 안됨(결과 170, 173 두개임)
SELECT name, height FROM usertbl
 WHERE height >= (SELECT height FROM usertbl WHERE addr = '경남');
-- ANY : 173보다 크거나 같은사람 또는 170보다 크거나 같은사람 모두(합집합) 출력, 즉 170보다 크거나 같은 사람
SELECT name, height FROM usertbl
 WHERE height >= ANY(SELECT height FROM usertbl WHERE addr = '경남');
-- ALL(SOME와 동일) : 키가 173보다 크거나(교집합) 같은 사람
 SELECT name, height FROM usertbl
  WHERE height >= ALL(SELECT height FROM usertbl WHERE addr = '경남');
-- =ANY(IN) : 지역이 ‘경남’사람의 키와 같은 사람만 추출해 보시오.
SELECT name, height FROM usertbl
 WHERE height = ANY(SELECT height FROM usertbl WHERE addr = '경남');
SELECT name, height FROM usertbl
 WHERE height IN(SELECT height FROM usertbl WHERE addr = '경남');
 
 -- #### ORDER BY ###
 SELECT name, mDate FROM usertbl ORDER BY mDate DESC; -- DESC : 내림차순
 SELECT name, height FROM usertbl ORDER BY height DESC, name ASC;
 
-- #### DISTINCT : 중복 제거 ###
-- 회원 테이블에서 회원들의 거주지역이 몇 군데인지 확인 
select addr from usertbl;  -- 정렬이 안되어 있어서 중복되지 않은값 확인이 안됨
select addr from usertbl order by addr; -- 값들이 중복되어 있음
select distinct addr from usertbl;  -- 중복된 것들 제거 

-- #### LIMIT ###
-- 입사일이 오래된 직원 5명의 emp_no(사원번호)를 조회
 USE employees;
 SELECT emp_no, hire_date FROM employees ORDER BY hire_date ASC LIMIT 5;  -- 원하는 개수 5개 출력
 SELECT emp_no, hire_date FROM employees ORDER BY hire_date ASC LIMIT 10, 5; -- 앞의 10개 행을 건너뛰고 다음 5개 행 조회
  
-- ###############################################
-- CREATE TABLE … SELECT 구문
-- buytbl을 buytbl2로 복사
USE sqldb;
CREATE TABLE buytbl2 (SELECT * FROM buytbl);
SELECT * FROM buytbl2;
-- 원하는 변수들만 조회한 후 테이블 생성
CREATE TABLE buytbl3 (SELECT userID, prodName FROM buytbl);
SELECT * FROM buytbl3;

-- ###############################################
-- GROUP BY및 HAVING 그리고 집계 함수
-- ###############################################
USE sqldb;
SELECT userID, amount FROM buytbl ORDER BY userID;  #  default정렬 : ASC
-- 사용자별 집계 
SELECT userID, SUM(amount) FROM buytbl GROUP BY userID;
-- 별칭
SELECT userID AS '사용자 아이디', SUM(amount) AS '총 구매 개수'
FROM buytbl GROUP BY userID;
-- 구매액의 총합을 출력
SELECT userID AS '사용자 아이디', SUM(amount*price) AS '총 구매액'
FROM buytbl GROUP BY userID;
-- 전체 구매자가 구매한 물품의 개수의 평균
USE sqldb;
SELECT AVG(amount) AS '평균 구매 개수' FROM buytbl;
-- 각 사용자 별로 물건을 평균 몇 개 구매했는지 평균을 내보시오. (GROUP BY 사용)
SELECT userID, AVG(amount) AS '평균 구매 개수'
FROM buytbl GROUP BY userID;
-- 가장 큰 키와 가장 작은 키의 회원 이름과 키를 출력
SELECT name, MAX(height), MIN(height) FROM usertbl;  -- error
SELECT name, MAX(height), MIN(height) FROM usertbl GROUP BY name;  -- error
SELECT name, height
  FROM usertbl
  WHERE height = (SELECT MAX(height) FROM usertbl)
     OR height = (SELECT MIN(height) FROM usertbl);
-- 휴대폰이 있는 사용자의 수를 카운트 하기
SELECT COUNT(*) FROM usertbl;
SELECT COUNT(mobile2) as '휴대폰이 있는 사용자' FROM usertbl;
-- Having절
-- sum()을 사용해서 사용자별 총 구매액을 구해보자
-- 이 중에서 총 구매액이 1000 이상이 사용자에게만 사은품을 증정하고자 한다면?
-- error : where절에 집계 함수가 올 수 없음, 그래서 having절이 필요함 
SELECT userID AS '사용자', SUM(price*amount) AS '총구매액'
  FROM buytbl
  WHERE SUM(price*amount) > 1000 
  GROUP BY userID;
-- having 적용
SELECT userID AS '사용자', SUM(price*amount) AS '총구매액'
  FROM buytbl
  GROUP BY userID
  HAVING SUM(price*amount) > 1000;
-- 추가로 총 구매액이 적은 사용자부터 나타내게 하려면?
SELECT userID AS '사용자', SUM(price*amount) AS '총구매액'
  FROM buytbl
  GROUP BY userID
  HAVING SUM(price*amount) > 1000
  ORDER BY SUM(price*amount); 
-- WITH ROLLUP :  총합 또는 중간 합계 시 사용
SELECT num, groupName, SUM(price * amount) AS '비용'
  FROM buytbl
  GROUP BY groupName, num;
  
SELECT num, groupName, SUM(price * amount) AS '비용'
  FROM buytbl
  GROUP BY groupName, num
  WITH ROLLUP;
  
SELECT groupName, SUM(price * amount) AS '비용'
  FROM buytbl
  GROUP BY groupName
  WITH ROLLUP;

############################
# INSERT문(데이터의 삽입)
############################
# 테이블 생성 & 데이터 삽입 
USE sqldb;
CREATE TABLE testTbl1 (id int, userName char(3), age int);
INSERT INTO testTbl1 VALUES (1, '홍길동', 25);
INSERT INTO testTbl1(id, userName) VALUES (2, '설현');
# 열의 순서를 바꾸는 경우 
INSERT INTO testTbl1(userName, age, id) VALUES ('하니', 26, 3);

-- 테이블 없으면 오류
DROP TABLE testTbl2;

-- 테이블 없어도 오류 없음
DROP TABLE IF EXISTS testTbl2;

# ID 자동화 : auto_increment
CREATE TABLE testTbl2 ( id int AUTO_INCREMENT PRIMARY KEY, 
   userName char(3), age int ); 
INSERT INTO testTbl2 VALUES (NULL, '지민', 25); 
SELECT * FROM testTbl2;

# auto_increment의 시작점 변경
ALTER TABLE testTbl2 AUTO_INCREMENT=100; 
INSERT INTO testTbl2 VALUES (NULL, '찬미', 23); 
SELECT * FROM testTbl2;

-- 1. 테이블 생성
CREATE TABLE testTbl3 (
    id       int AUTO_INCREMENT PRIMARY KEY,
    userName char(3),
    age      int
);

-- 2. AUTO_INCREMENT 시작값을 1000으로 설정(ALTER)
ALTER TABLE testTbl3 AUTO_INCREMENT = 1000;

-- 3. AUTO_INCREMENT 증가 간격을 3으로 설정 (전역 시스템 변수)
SET @@auto_increment_increment = 3;

-- 4. 데이터 삽입 (id에 NULL → 자동 증가값 적용) : 3개 넣기
INSERT INTO testTbl3 VALUES (NULL, '나연', 20);
INSERT INTO testTbl3 VALUES (NULL, '정연', 18);
INSERT INTO testTbl3 VALUES (NULL, '모모', 19);

-- 5. 조회
SELECT * FROM testTbl3;

# INSERT INTO … SELECT : 대량의 데이터 처리에 효과적 
-- 1. 빈 테이블 생성
CREATE TABLE testTbl4 (
    id    int,
    Fname varchar(50),
    Lname varchar(50)
);

-- 2. 다른 테이블의 데이터를 조회해서 한 번에 삽입
INSERT INTO testTbl4
    SELECT emp_no, first_name, last_name
        FROM employees.employees;

select * from testTbl4;

use sqldb;

# CREATE TABLE ... SELECT : 테이블 정의까지 반영
CREATE TABLE testTbl5
    (SELECT emp_no, first_name, last_name FROM employees.employees);

############################
# UPDATE문(데이터의 수정)
############################
-- 특정 조건의 행 데이터를 수정
UPDATE testTbl4
    SET   Lname = '없음'
    WHERE Fname = 'Kyoichi';
    
SELECT * from testTbl4;

-- 전체 테이블의 내용을 변경 
-- 구매 테이블에서 현재의 단가를 모두 1.5배 인상
UPDATE buytbl SET price = price * 1.5;
commit;

select * from buytbl;

############################
# DELETE문(데이터의 삭제)
############################
-- 특정 조건의 행을 삭제
DELETE FROM testTbl4 WHERE Fname = 'Aamer';
select * from testTbl4;
-- Aamer중에서 상위 5건만 삭제
DELETE FROM testTbl4 WHERE Fname = 'Aamer' LIMIT 5;


 