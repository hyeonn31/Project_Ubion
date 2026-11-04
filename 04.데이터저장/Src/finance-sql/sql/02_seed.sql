-- 실제 고객/계좌가 아닌 고정 교육용 허구 데이터. 최초 1회만 실행.
USE finace;
INSERT INTO fin_customers VALUES (1, '고객A'), (2, '고객B'), (3, '고객C');
INSERT INTO fin_accounts VALUES
(101, 1, 'KRW', 1000000.00, 1120000.00),
(102, 2, 'KRW', 500000.00, 590000.00),
(103, 3, 'KRW', 200000.00, 190000.00);
INSERT INTO fin_transfer_requests VALUES
('seed-t01', 101, 102, 30000.00, 'KRW', '2025-01-11 10:00:00');
INSERT INTO fin_ledger_entries (external_id, account_id, posted_at, amount, status, transfer_request_id) VALUES
('E001', 101, '2025-01-10 09:00:00', 200000.00, 'posted', NULL),
('E002', 101, '2025-01-10 12:00:00', -50000.00, 'posted', NULL),
('E003', 101, '2025-01-11 10:00:00', -30000.00, 'posted', 'seed-t01'),
('E004', 102, '2025-01-11 10:00:00', 30000.00, 'posted', 'seed-t01'),
('E005', 102, '2025-01-11 14:00:00', 100000.00, 'posted', NULL),
('E006', 102, '2025-01-12 11:00:00', -40000.00, 'posted', NULL),
('E007', 103, '2025-01-12 13:00:00', -10000.00, 'posted', NULL),
('E008', 103, '2025-01-12 15:00:00', 50000.00, 'pending', NULL),
('E009', 101, '2025-01-12 16:00:00', -20000.00, 'reversed', NULL);
-- 이 강좌에서 reversed는 '잔액 반영 없이 취소된 시도'이다.
-- 이미 posted된 거래의 정정은 기존 행 변경이 아니라 별도 반대 부호 거래로 처리해야 한다.
