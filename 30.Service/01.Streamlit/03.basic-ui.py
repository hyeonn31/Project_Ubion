import pandas as pd
from datetime import datetime as dt
import datetime
import streamlit as st

# 버튼 클릭
button = st.button("버튼을 눌러보세요")


if button:
    st.write(":blue [버튼]이 눌렸습니다. :sparkles: ")
    

# 샘플 데이터 생성 & 파일 다운로드 버튼
dataframe = pd.DataFrame(
    {
        "first column": [1, 2, 3, 4],
        "second column": [10, 20, 30, 40],
    }
)

st.dataframe(dataframe)


# 다운로드 버튼 연결
st.download_button(
    label="CSV로 다운로드",
    data=dataframe.to_csv(),
    file_name="sample.csv",
    mime="text/csv",
)

# 라디오 선택 버튼 
mbti = st.radio("당신의 MBTI는 무엇입니까?", ("ISTJ",'ENFP','선택지 없음'))

# 다중 선택 박스
options = st.multiselect(
    "당신이 좋아하는 과일은 뭔가요?",
    ["망고", '오렌지', '사과 ', '바나나'],
    ["망고","오렌지"]
)

st.write(f"당신의 선택은: :red[{options}]입니다.")

if mbti == "ISTJ":
    st.write("당신은 :blue[현실주의자] 이시네요")
elif mbti == "ENFP":
    st.write("당신은 :green[활동가] 이시네요")
else:
    st.write("당신에 대해 :red[알고 싶어요]:grey_exclamation:")