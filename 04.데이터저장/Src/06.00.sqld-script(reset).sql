CREATE DATABASE IF NOT EXISTS sqld_mysql_lab
	CHARACTER SET utf8mb4   -- 유니코드 지원 
	COLLATE utf8mb4_unicode_ci;   -- 문자열 비교 및 정렬 규칙 지정, _ci : 대소문자 구별 안함

USE sqld_mysql_lab;

# 외래 키 검사 일시 해제 : FK를 사용할 경우 참조 관계를 고려해서 테이블을 삭제해야 함
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS sqld_sales;
DROP TABLE IF EXISTS sqld_blocked_dept;
DROP TABLE IF EXISTS sqld_emp;
DROP TABLE IF EXISTS sqld_dept;

SET FOREIGN_KEY_CHECKS = 1;