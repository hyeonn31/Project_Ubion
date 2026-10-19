import streamlit as st
import FinanceDataReader as fdr # 주식, 환율, 지수 데이터를 가져오는 라이브러리
import datetime

st.title('종목차트검색')

# 사이드바: 입력칸만
with st.sidebar:
    # 날짜 선택 달력 (기본값: 2025-08-27)
    date = st.date_input(
        "조회 시작일을 선택해 주세요",
        datetime.datetime(2025,8,27)
    )

    # 종목코드 입력칸 (기본값: 005930 삼성전자)
    code = st.text_input("종목코드", value="005930")

# 본문: 종목코드와 날짜가 모두 입력됐을 때만 실행 (빈칸이면 에러 방지)
if code and date:
    # 선택한 날짜부터 오늘까지의 주가 데이터 가져오기
    df = fdr.DataReader(code, date)
    data = df.sort_index(ascending=True).loc[:,'Close']

    tab1, tab2 = st.tabs(['차트','데이터'])

    with tab1:
        # 종가(Close)로 선 그래프 그리기 (x축: 날짜, y축: 가격)
        st.line_chart(data)

    with tab2:
        # 최신 날짜가 위로 오게 정렬
        st.dataframe(df.sort_index(ascending=False))

    with st.expander('컬럼설명'):
        st.markdown('''
        - Open : 시가
        - High : 고가
        - Low : 저가
        - Close : 종가
        - Volume : 거래량
        - Change : 등락률
        ''')
