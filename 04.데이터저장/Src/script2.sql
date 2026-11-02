##################################################
# JOIN : 두 개 이상의 테이블을 공통 컬럼을 기준으로 연결하는 것
# 데이터를 옆으로 합치기(컬럼 증가)
##################################################
-- 1. INNER JOIN : 두 테이블에서 조건이 일치하는 행(교집합)
SELECT u.userID, u.name, u.birthYear
FROM usertbl u;

-- KKH는 구매이력 없으므로 제외
SELECT u.userID, u.name, u.birthYear, b.prodName, b.price, b.amount
FROM usertbl u 
INNER JOIN buytbl b ON u.userID = b.userID
ORDER BY u.userID;


-- 2. LEFT JOIN : 왼쪽 테이블 전체를 기준으로, 오른쪽 테이블에 일치하는 행이 없으면 NULL로 채움
-- usertbl을 기준으로 구매내역을 포함
SELECT u.userID, u.name, u.birthYear, b.prodName, b.price, b.amount
FROM usertbl u 
LEFT JOIN buytbl b ON u.userID = b.userID
ORDER BY u.userID;

-- 3. RIGHT JOIN : 오른쪽 테이블 전체를 기준으로, 왼쪽 테이블에 일치하는 행이 없으면 NULL로 채움
-- buytbl 기준이므로 모든 구매내역 포함
SELECT u.userID, u.name, u.birthYear, b.prodName, b.price, b.amount
FROM usertbl u 
RIGHT JOIN buytbl b ON u.userID = b.userID
ORDER BY u.userID;

-- 구매한 적 없는 회원 추출
SELECT u.userID, u.name, u.birthYear, b.userID, b.prodName, b.price, b.amount
FROM usertbl u 
LEFT JOIN buytbl b ON u.userID = b.userID
WHERE b.userID IS NULL
ORDER BY u.userID;

-- 4. CROSS JOIN : 두 테이블의 모든 행을 조합, 조건 없이 곱집합을 만듬
-- 사용이유 : 테스트 대용량 데이터 생성, 모든 경우의 수 테이블 생성 : 추천시스템, 매칭서비스 
-- 상품 색상과 사이즈 옵션 조합, 회원별 추천 상품 후보 생성, 날짜와 시간대 조합
SELECT u.name, b.prodName
FROM usertbl u
CROSS JOIN buytbl b;

SELECT count(*)  # 120개(10 * 12)
FROM usertbl u
CROSS JOIN buytbl b;

# 쇼핑몰 상품 옵션 조합 : 색상과 사이즈를 조합해서 상품 옵션을 생성
CREATE TABLE color_tbl (
    color VARCHAR(20)
);
INSERT INTO color_tbl VALUES
('RED'), ('BLUE'), ('BLACK');

CREATE TABLE size_tbl (
    size VARCHAR(10)
);
INSERT INTO size_tbl VALUES
('S'), ('M'), ('L');
-- 색상 3개 × 사이즈 3개 = 9가지 옵션
SELECT c.color, s.size
FROM color_tbl c
CROSS JOIN size_tbl s;

-- 요일별 시간표 생성
CREATE TABLE day_tbl (
    day_name VARCHAR(10)
);
INSERT INTO day_tbl VALUES
('월요일'), ('화요일'), ('수요일');
CREATE TABLE time_tbl (
    time_name VARCHAR(20)
);
INSERT INTO time_tbl VALUES
('오전'), ('오후');
-- 6가지 조합이 나옴
SELECT d.day_name, t.time_name
FROM day_tbl d
CROSS JOIN time_tbl t;

-- 5. SELF JOIN : 같은 테이블을 별칭을 다르게 해서 두 번 사용, 소셜 앱에서 같은 지역 유저 추천, 팀 매칭 등에 활용
-- 자신보다 키가 큰 회원 찾기(조직도, 계층구조 표현시 사용)
-- 같은 지역(addr)에 사는 회원끼리 매칭
SELECT A.name AS 회원1, B.name AS 회원2, A.addr
FROM usertbl A
INNER JOIN usertbl B ON A.addr = B.addr
WHERE A.userID < B.userID;  -- 자기 자신을 제외 하거나 중복 조합 방지 

-- 자신보다 키가 큰 회원 찾기
SELECT A.name AS 회원,
       A.height AS 내키,
       B.name AS 비교회원,
       B.height AS 비교회원키
FROM usertbl A
INNER JOIN usertbl B
    ON A.height < B.height
ORDER BY A.height;

-- 같은 나이의 회원 찾기 : usertbl
SELECT
    A.name AS 회원1,
    B.name AS 회원2,
    A.birthYear AS 생일
FROM usertbl A
INNER JOIN usertbl B
    ON A.birthYear = B.birthYear
WHERE A.userID < B.userID;

-- 회사 조직도 (직원과 상사 찾기)
CREATE TABLE employee_tbl (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(20),
    manager_id INT
);
INSERT INTO employee_tbl VALUES
(1, '김대표', NULL),
(2, '이부장', 1),
(3, '박과장', 2),
(4, '최대리', 3),
(5, '정과장', 2);

SELECT
    A.emp_name AS 직원,
    B.emp_name AS 상사
FROM employee_tbl A
LEFT JOIN employee_tbl B
    ON A.manager_id = B.emp_id;

##################################################
# UNION : 두 개 이상의 SELECT 결과를 아래로 합치기(행이 증가)
# 두 SELECT의 컬럼 수와 데이터 타입이 반드시 일치
# 결과의 컬럼명은 첫 번째 SELECT의 것을 따름
##################################################
 -- 1. 기본 UNION - 중복 제거
 -- 서울 거주 회원 + 키 176 이상 회원
SELECT userID, name, addr, height
FROM usertbl
WHERE addr = '서울'
UNION
SELECT userID, name, addr, height
FROM usertbl
WHERE height >= 176;
 
 