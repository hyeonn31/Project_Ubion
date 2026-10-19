import streamlit as st
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import numpy as np

import os
import matplotlib.font_manager as fm # 폰트 관련 용도 as fm


#list로 받은 데이터의 중복을 제거
def unique(list):
    x = np.array(list)
    return np.unique(x)

# 현재 폴더 안의 customFonts 폴더에 있는 폰트 리스트를 화면에 구성
def fontRegistered():
    font_dirs = [os.getcwd() + '/customFonts']
    
    # 지정된 경로에 있는 모든 폰트 파일 검색
    font_files = fm.findSystemFonts(fontpaths=font_dirs) # .ttf, .otf
    
    for font_file in font_files:
        fm.fontManager.addfont(font_file)
        
    # 폰트 매니저를 새로 로드, 캐시를 사용하지 않고 바로 커스텀 폰트 반영
    fm._load_fontmanager(try_read_cache=False)
    
fontRegistered()
fontNames = [f.name for f in fm.fontManager.ttflist]
fontName = st.selectbox("폰트 선택", unique(fontNames))

# DataFrame 생성
data = pd.DataFrame({
    '이름': ['영식', '철수', '영희'],
    '나이': [22, 31, 25],
    '몸무게': [75.5, 80.2, 55.1]
})

st.dataframe(data, use_container_width=True) 
plt.rcParams['font.family'] = fontName


fig, ax = plt.subplots()
ax.bar(data['이름'], data['나이'])
st.pyplot(fig)

barplot = sns.barplot(x='이름', y= '나이', data=data, ax=ax, palette='Set2')
fig = barplot.get_figure()


##### Barcode
# 1차원 배열을 픽셀 단위의 흑백 이미지로 시각화
code = np.array([
    1, 0, 1, 0, 1, 1, 1, 0, 1, 1, 0, 0, 0, 1, 0, 0, 1, 0, 1, 0, 0, 1, 1, 1,
    0, 0, 0, 1, 0, 1, 1, 0, 0, 0, 0, 1, 0, 1, 0, 0, 1, 1, 0, 0, 1, 0, 1, 0,
    1, 0, 1, 0, 0, 0, 0, 1, 0, 1, 1, 1, 0, 1, 0, 0, 1, 1, 0, 1, 1, 0, 0, 1,
    1, 0, 0, 1, 1, 0, 1, 0, 1, 1, 1, 0, 0, 1, 0, 0, 0, 1, 0, 0, 1, 0, 1])

pixel_per_bar = 4 #배열 원소 1개당 4픽셀로 표현하고 전체 이미지도 커짐
dpi = 100 # 이미지 해상도 : 1인치에 100식셀을 표현함(선명도 조절)

# len(code) * pixel_per_bar : 전체 데이터가 차지하는 총 픽셀 수 
# len(code) * pixel_per_bar / 픽셀 수를 인치 단위로 변환 

fig = plt.figure(figsize=(len(code) * pixel_per_bar / dpi, 2), dpi=dpi)

# 왼쪽, 아래, 가로 비율, 세로 비율
ax = fig.add_axes([0,0,1,1]) # span the whole figure
ax.set_axis_off() # 눈금, 테두리선을 전부 없앰


# 데이터를 넣을 경우(1,N)형태로 바꿔줘야 함(2D이미지로 나옴)
# cmap='binary' : 흑백으로 표현
# aspect= 'auto' : 가로 /세로의 비율을 자동으로 조절(이미지 왜곡을 피하기 위함)
# interpolation='nearest' : 이미지 보간법 (픽셀을 최대한 선명하게 표현, 바코드나, 이진 데이터 시각화에 적합)
ax.imshow(code.reshape(1,-1), cmap='binary', aspect='auto',
          interpolation='nearest')

st.pyplot(fig)