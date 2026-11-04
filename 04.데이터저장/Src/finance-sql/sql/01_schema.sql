-- 교육용 허구 금융 데이터 전용. 관리자 최초 초기화용.
USE finance;
CREATE TABLE fin_customers (
    customer_id INT PRIMARY KEY,
    customer_alias VARCHAR(40) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE fin_accounts (
    account_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    currency CHAR(3) NOT NULL DEFAULT 'KRW',
    opening_balance DECIMAL(18,2) NOT NULL,
    balance DECIMAL(18,2) NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES fin_customers(customer_id),
    CHECK (currency = 'KRW'),
    CHECK (opening_balance >= 0 AND balance >= 0),
    CHECK (opening_balance = TRUNCATE(opening_balance, 0) AND balance = TRUNCATE(balance, 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE fin_transfer_requests (
    request_id VARCHAR(64) CHARACTER SET ascii COLLATE ascii_bin PRIMARY KEY,
    from_account_id INT NOT NULL,
    to_account_id INT NOT NULL,
    amount DECIMAL(18,2) NOT NULL,
    currency CHAR(3) NOT NULL,
    created_at DATETIME NOT NULL COMMENT '학습 정책: Asia/Seoul 현지 시각, naive DATETIME',
    FOREIGN KEY (from_account_id) REFERENCES fin_accounts(account_id),
    FOREIGN KEY (to_account_id) REFERENCES fin_accounts(account_id),
    CHECK (from_account_id <> to_account_id),
    CHECK (currency = 'KRW' AND amount > 0 AND amount = TRUNCATE(amount, 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE fin_ledger_entries (
    entry_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    external_id VARCHAR(80) CHARACTER SET ascii COLLATE ascii_bin NOT NULL UNIQUE,
    account_id INT NOT NULL,
    posted_at DATETIME NOT NULL,
    amount DECIMAL(18,2) NOT NULL COMMENT '계좌 기준: 입금 양수, 출금 음수',
    status VARCHAR(16) NOT NULL,
    transfer_request_id VARCHAR(64) CHARACTER SET ascii COLLATE ascii_bin NULL,
    FOREIGN KEY (account_id) REFERENCES fin_accounts(account_id),
    FOREIGN KEY (transfer_request_id) REFERENCES fin_transfer_requests(request_id),
    UNIQUE KEY uq_transfer_account (transfer_request_id, account_id),
    INDEX idx_ledger_status_date (status, posted_at),
    INDEX idx_ledger_account_date (account_id, posted_at),
    CHECK (status IN ('posted', 'pending', 'reversed')),
    CHECK (amount <> 0 AND amount = TRUNCATE(amount, 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE fin_daily_cashflow (
    business_date DATE PRIMARY KEY,
    posted_count INT NOT NULL,
    inflow DECIMAL(20,2) NOT NULL,
    outflow DECIMAL(20,2) NOT NULL,
    net_flow DECIMAL(20,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE fin_statement_lines (
    source_id VARCHAR(80) CHARACTER SET ascii COLLATE ascii_bin PRIMARY KEY,
    account_id INT NOT NULL,
    booked_at DATE NOT NULL,
    amount DECIMAL(18,2) NOT NULL,
    currency CHAR(3) NOT NULL,
    FOREIGN KEY (account_id) REFERENCES fin_accounts(account_id),
    CHECK (currency = 'KRW' AND amount <> 0 AND amount = TRUNCATE(amount, 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
