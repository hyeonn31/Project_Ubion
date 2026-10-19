import streamlit as st
import FinanceDataReader as fdr # 주식, 환율, 지수 데이터를 가져오는 라이브러리
import datetime

# 날짜 선택 달력 (기본값: 2025-08-27)
date = st.date_input(
    "조회 시작일을 선택해 주세요",
    datetime.datetime(2025,8,27)
)


# 종목코드 입력칸 (기본값: 005930 삼성전자)
code = st.text_input("종목코드", value="005930")

# 종목코드와 날짜가 모두 입력됐을 때만 실행 (빈칸이면 에러 방지)
if code and date:
    # 선택한 날짜부터 오늘까지의 주가 데이터 가져오기
    # 열: Open(시가), High(고가), Low(저가), Close(종가), Volume(거래량), Change(등락률)
    df = fdr.DataReader(code, date)

    # 종가(Close)로 선 그래프 그리기 (x축: 날짜, y축: 가격)
    st.line_chart(df['Close'])
