-- SQLD 강의 실습용 스키마 (Oracle Database 19c)


CREATE TABLE sqld_dept (
  dept_id   NUMBER(4)    CONSTRAINT pk_sqld_dept PRIMARY KEY,
  dept_name VARCHAR2(30) CONSTRAINT nn_sqld_dept_name NOT NULL
);

CREATE TABLE sqld_emp (
  emp_id     NUMBER(6)    CONSTRAINT pk_sqld_emp PRIMARY KEY,
  emp_name   VARCHAR2(30) CONSTRAINT nn_sqld_emp_name NOT NULL,
  dept_id    NUMBER(4),
  manager_id NUMBER(6),
  salary     NUMBER(10,2) CONSTRAINT nn_sqld_emp_salary NOT NULL,
  bonus      NUMBER(10,2),
  hire_date  DATE         CONSTRAINT nn_sqld_emp_hire_date NOT NULL,
  CONSTRAINT fk_sqld_emp_dept
    FOREIGN KEY (dept_id) REFERENCES sqld_dept(dept_id),
  CONSTRAINT fk_sqld_emp_manager
    FOREIGN KEY (manager_id) REFERENCES sqld_emp(emp_id),
  CONSTRAINT ck_sqld_emp_salary CHECK (salary >= 0),
  CONSTRAINT ck_sqld_emp_bonus CHECK (bonus IS NULL OR bonus >= 0)
);

CREATE TABLE sqld_blocked_dept (
  dept_id NUMBER(4)
  -- NULL을 의도적으로 보관한다. NOT IN과 NULL의 3값 논리 실습용이다.
);

CREATE TABLE sqld_sales (
  sale_id    NUMBER(6)    CONSTRAINT pk_sqld_sales PRIMARY KEY,
  dept_id    NUMBER(4)    CONSTRAINT nn_sqld_sales_dept NOT NULL,
  sale_month VARCHAR2(7)  CONSTRAINT nn_sqld_sales_month NOT NULL,
  amount     NUMBER(12,2) CONSTRAINT nn_sqld_sales_amount NOT NULL,
  CONSTRAINT fk_sqld_sales_dept
    FOREIGN KEY (dept_id) REFERENCES sqld_dept(dept_id),
  CONSTRAINT uq_sqld_sales_dept_month UNIQUE (dept_id, sale_month),
  CONSTRAINT ck_sqld_sales_month CHECK (REGEXP_LIKE(sale_month, '^20[0-9]{2}-(0[1-9]|1[0-2])$')),
  CONSTRAINT ck_sqld_sales_amount CHECK (amount >= 0)
);

COMMENT ON TABLE sqld_dept IS 'SQLD 실습용 부서';
COMMENT ON TABLE sqld_emp IS 'SQLD 실습용 사원';
COMMENT ON TABLE sqld_blocked_dept IS 'NOT IN NULL 함정 실습용 차단 부서';
COMMENT ON TABLE sqld_sales IS '집계·PIVOT 실습용 월별 부서 매출';
