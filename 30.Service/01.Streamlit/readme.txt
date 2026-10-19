설치 : pip install streamlit
프로젝트 파일폴더로 이동 : cd C:\Project_U\30.Service\01. Streamlit
실행 : streamlit run 01.text.py

= 가상환경만들기
conda create -n myenv python=3.14

= 가상환경 확인
conda env list

= 가상환경 접속
conda activate myenv

= 가상환경 나가기
conda.bat deactivate

= 가상환경 삭제
conda env remove -n myenv


= 가상환경에 라이브러리 설치  -requirements.text
conda install -r requirements.text

= 기본 채널에 없는 패키지
conda install -c conda-forge lib명

= conda에 없는 lib설치
pip install lib명

= 환경 내보내기
conda env export -n myenv -f environment.yml

= 환경 불러오기 (다른 PC에서)
conda env create -f environment.yml