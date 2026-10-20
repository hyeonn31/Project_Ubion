from datetime import date          # 날짜 다루기 (조회 기간 입력 등에 사용 예정)

import pandas as pd                # 표(DataFrame) 다루기
import plotly.express as px        # 마우스를 올리면 값이 보이는 인터랙티브 그래프
import streamlit as st             # 웹 화면 만들기

# 같은 폴더의 finance.py에서 만들어 둔 상수와 함수 가져오기
# → 데이터 처리(finance.py)와 화면(app.py)을 파일로 나눠서 관리
from finance import (
    COLUMNS, MAX_AMOUNT, add_features, csv_bytes, empty_records,
    load_sample, read_csv_bytes, summarize, validate_records,
)

# 브라우저 탭 제목 / layout="wide" : 화면을 가로로 넓게 사용
# ⚠ 다른 st. 명령보다 반드시 먼저 실행되어야 함
st.set_page_config(page_title="나의 입출금 정리표",layout="wide")

# session_state : 화면이 다시 실행(rerun)돼도 값이 사라지지 않는 저장소 (딕셔너리처럼 사용)
# Streamlit은 버튼 클릭·입력 때마다 파일 전체를 처음부터 다시 실행하기 때문에
# 일반 변수는 매번 초기화됨 → 계속 유지할 데이터는 session_state에 저장
if "records" not in st.session_state:          # 처음 접속했을 때만 (records가 아직 없을 때)
    st.session_state.records = load_sample()   # 샘플 CSV를 읽어서 거래 내역으로 저장
    st.session_state.revision = 0              # 데이터 버전 번호 (데이터가 바뀔 때마다 +1)


# period : 조회기간, view_kind : 수입 또는 지출 구분, view_categories : 조회할 항목
# 데이터가 새로 저장된 직후(reset_filters가 True)라면 필터 선택값을 지워서 기본값으로 되돌림
# pop(키, 기본값) : 값을 꺼내면서 동시에 삭제. 키가 없으면 기본값(False) 반환 → 한 번만 실행됨
if st.session_state.pop("reset_filters",False):
    for key in ["period", "view_kind","view_categories"]:
        st.session_state.pop(key, None)      # 키가 없어도 에러 나지 않게 기본값 None

# message가 있으면 데이터 return하고 없으면 None을 return
# 꺼내면서 삭제하므로 안내 메시지는 딱 한 번만 화면에 표시됨
message = st.session_state.pop("message",None)


# 새 거래 내역을 검증한 뒤 저장하고, 화면을 새로 그리는 함수
def save_records(frame: pd.DataFrame, message:str) -> None:   # -> None : 돌려주는 값 없음
    clean = validate_records(frame)          # 규칙 검사 (틀리면 ValueError → 아래 줄은 실행 안 됨)
    st.session_state.records = clean         # 검사 통과한 데이터로 교체
    st.session_state.revision += 1           # 데이터 버전 +1
    st.session_state.reset_filters = True    # 다음 실행 때 필터 초기화하라는 표시
    st.session_state.message = message       # 다음 실행 때 보여줄 안내 메시지 (예: "저장되었습니다")
    st.rerun()                               # 지금 바로 파일 전체를 다시 실행 → 바뀐 데이터로 화면 갱신


# ───────────────────────── 사이드바 : 조회 조건 입력 ─────────────────────────
with st.sidebar:                     # 이 블록 안(들여쓴 부분)은 왼쪽 사이드바에 그려짐
    st.subheader("조회 설정")         # 작은 제목

    # 저장된 거래 내역의 날짜에서 "YYYY-MM"만 뽑아 → 중복 제거 → 리스트로 → 오름차순 정렬
    # 예: ["2026-01-05", "2026-01-08", "2026-02-03"] → ["2026-01", "2026-02"]
    months = sorted(st.session_state.records["날짜"].str[:7].unique().tolist())
    # key="period" : 위젯 이름
    # → 선택값이 st.session_state.period에도 자동 저장됨 (앞에서 필터 초기화할 때 이 이름으로 지움)
    # 선택지 = ["전체 기간"] + 월 목록 (리스트끼리 + 하면 이어 붙여짐)
    period = st.selectbox("조회 기간", ["전체 기간"] + months, key="period")

    # 숫자 입력
    # min/max_value : 입력 가능한 범위, value : 기본값, step : +/- 버튼 한 번에 바뀌는 크기
    threshold = st.number_input(
      label="큰 지출 기준 (원)", min_value=0, max_value=MAX_AMOUNT ,value=100000, step=5000, key="threshold"
    )
    
    # 한 달에 이만큼은 남기고 싶다는 목표 금액 (월별 그래프의 기준선 등에 사용 예정)
    target = st.number_input(
                             
      label="월별 남은금액 목표 (원)", min_value=0, max_value=MAX_AMOUNT, value=700000, step=5000, key="target"
    )
    
    st.divider()        # 가로 구분선
    st.caption("아래 버튼은 현재 세션 내역을 바꿉니다. 필요하면 먼저 전체 csv를 내려 받으세요")   # 작은 회색 안내글

    # 버튼 만들기
    # st.button은 "이번 실행에서 클릭됐으면 True"를 돌려줌 → 클릭한 그 순간에만 if 안이 실행됨
    # width="stretch" : 버튼을 사이드바 가로 폭에 꽉 차게
    if st.button("가상 예제로 되돌리기",key="reset_sample", width="stretch"):
        save_records(load_sample(), "가상 예제 18건을 불러왔습니다.")          # 샘플 CSV로 교체

    if st.button("빈 정리표로 시작",key="start_empty",width="stretch"):
        save_records(empty_records(), "빈 정리표를 만들었습니다. 내역을 추가해주세요")   # 0행짜리 빈 표로 교체

    st.caption("세션 메모리 보관 브라우저 새로고침/연결 종료 시 초기화될 수 있습니다.")

# ───────────────────────── 본문(오른쪽) : 결과 화면 ─────────────────────────
st.title("나의 입출금 정리표 만들기")                                # 큰 제목
st.write("내역을 입력하고, 월별 흐름과 지출 항목을 한눈에 확인하세요.")   # 일반 글
st.caption("처음 보이는 18건은 가상 학습 데이터 입니다. 남은 금액은 기간 내 수입-지출이며 통장 잔액이 아닙니다.")

# 파생변수 만들기
# 저장된 전체 내역에 "월", "표시" 열 추가 (큰 지출 기준은 사이드바에서 입력한 threshold)
# number_input은 소수(float)로 돌려줄 수 있어서 int()로 정수 변환
all_records = add_features(st.session_state.records, int(threshold))
# 조회 기간 필터 (조건 표현식 : A if 조건 else B)
# "전체 기간"이면 전체 복사본, 아니면 "월" 열이 선택한 달과 같은 행만 남김
filtered = all_records.copy() if period == "전체 기간" else all_records[all_records["월"] == period].copy()

# 항목별 지출 합계표, 월별 요약표 두 개를 한 번에 받기 (아래 그래프/표에 사용 예정)
categorise, monthly = summarize(filtered)
# .loc[행 조건, 열] : 구분이 "수입"인 행의 "금액" 열만 → 합계 → 정수로
total_income = int(filtered.loc[filtered["구분"] =="수입", "금액"].sum())
total_expense = int(filtered.loc[filtered["구분"] =="지출", "금액"].sum())

total_balance = total_income - total_expense   # 남은 금액 = 수입 - 지출

# KPI(핵심 지표) 카드 4개
kpi1, kpi2, kpi3, kpi4 = st.columns(4)          # 화면을 가로 4칸으로 나눔
kpi1.metric("수입 합계", f"{total_income:,}원")   # metric : 제목 + 큰 숫자 카드, :, → 천 단위 쉼표
kpi2.metric("지출 합계", f"{total_expense:,}원")
kpi3.metric("기간 내 남은 금액", f"{total_balance:,}원")
kpi4.metric("조회내역", f"{len(filtered):,}건")   # len(표) = 행 개수 = 거래 건수

# 지금 어떤 기간을 보고 있는지 안내 (f-string으로 period 값을 끼워 넣음)
st.caption(f"현재 조회: {period}. 내역 관리, 전체 csv 백업은 기간 필터와 관계없이 전체 데이터를 사용합니다.`")
