-- 08. DML과 TCL (Oracle Database 19c)

-- 1) 변경 전 확인
SELECT emp_id, emp_name, bonus
FROM sqld_emp
WHERE emp_id = 105
ORDER BY emp_id;

SAVEPOINT before_lab_dml;

-- 2) UPDATE: NULL을 0으로 처리하여 보너스 100을 가산한다.
UPDATE sqld_emp
SET bonus = NVL(bonus, 0) + 100
WHERE emp_id = 105;

-- 3) INSERT: 전용 실습 데이터에만 임시 매출 1건을 추가한다.
INSERT INTO sqld_sales (sale_id, dept_id, sale_month, amount)
VALUES (99, 40, '2024-03', 1000);

-- 4) 변경 중간 상태 확인
SELECT emp_id, emp_name, bonus
FROM sqld_emp
WHERE emp_id = 105
ORDER BY emp_id;

SELECT sale_id, dept_id, sale_month, amount
FROM sqld_sales
WHERE sale_id = 99
ORDER BY sale_id;

-- 5) SAVEPOINT 이후의 INSERT/UPDATE만 되돌린다.
ROLLBACK TO before_lab_dml;

-- 6) 되돌림 확인: 105의 bonus=300, sale_id=99는 0행
SELECT emp_id, emp_name, bonus
FROM sqld_emp
WHERE emp_id = 105
ORDER BY emp_id;

SELECT sale_id, dept_id, sale_month, amount
FROM sqld_sales
WHERE sale_id = 99
ORDER BY sale_id;

-- 7) 혹시 남아 있을 수 있는 현재 세션의 미확정 DML도 모두 폐기한다.
ROLLBACK;
