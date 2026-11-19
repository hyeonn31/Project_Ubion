USE sqld_mysql_lab;

CREATE TABLE sqld_dept (
  dept_id   INT          NOT NULL,
  dept_name VARCHAR(30)  NOT NULL,
  CONSTRAINT pk_sqld_dept PRIMARY KEY (dept_id)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci
  COMMENT = 'SQLD 실습용 부서';

CREATE TABLE sqld_emp (
  emp_id     INT           NOT NULL,
  emp_name   VARCHAR(30)   NOT NULL,
  dept_id    INT           NULL,
  manager_id INT           NULL,
  salary     DECIMAL(10,2) NOT NULL,
  bonus      DECIMAL(10,2) NULL,
  hire_date  DATE          NOT NULL,
  CONSTRAINT pk_sqld_emp PRIMARY KEY (emp_id),
  CONSTRAINT fk_sqld_emp_dept
    FOREIGN KEY (dept_id) REFERENCES sqld_dept (dept_id),
  CONSTRAINT fk_sqld_emp_manager
    FOREIGN KEY (manager_id) REFERENCES sqld_emp (emp_id),
  CONSTRAINT ck_sqld_emp_salary CHECK (salary >= 0),
  CONSTRAINT ck_sqld_emp_bonus CHECK (bonus IS NULL OR bonus >= 0)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci
  COMMENT = 'SQLD 실습용 사원';

CREATE TABLE sqld_blocked_dept (
  dept_id INT NULL
  -- NULL을 의도적으로 보관한다. NOT IN과 NULL의 3값 논리 실습용이다.
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci
  COMMENT = 'NOT IN NULL 함정 실습용 차단 부서';

CREATE TABLE sqld_sales (
  sale_id    INT           NOT NULL,
  dept_id    INT           NOT NULL,
  sale_month VARCHAR(7)    NOT NULL,
  amount     DECIMAL(12,2) NOT NULL,
  CONSTRAINT pk_sqld_sales PRIMARY KEY (sale_id),
  CONSTRAINT fk_sqld_sales_dept
    FOREIGN KEY (dept_id) REFERENCES sqld_dept (dept_id),
  CONSTRAINT uq_sqld_sales_dept_month UNIQUE (dept_id, sale_month),
  CONSTRAINT ck_sqld_sales_month
	-- ^20 : 문자열로 시작, 숫자 20이옴, [0-9] : 숫자 0~9중 하나, {2} : [0-9]패턴이 2회 반복, 
    -- - : 하이픈 옴, 0[1-9] : 01, 09가 올 수 있음, | : 또는, 1[0-2] : 10, 12가 올 수 있음, $ : 문자열 끝 
    CHECK (REGEXP_LIKE(sale_month, '^20[0-9]{2}-(0[1-9]|1[0-2])$')),
  CONSTRAINT ck_sqld_sales_amount CHECK (amount >= 0)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci
  COMMENT = '집계와 피벗 실습용 월별 부서 매출';
