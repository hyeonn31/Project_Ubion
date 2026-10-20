# 실행 : streamlit run app.py
import random

import streamlit as st

from questions import QUESTIONS, run_code

st.set_page_config(page_title="Project_U 복습 퀴즈", layout="wide")

# session_state : rerun 돼도 유지되는 저장소 (현재 문제 번호, 맞힌 문제 번호)
if "idx" not in st.session_state:
    st.session_state.idx = 0
    st.session_state.solved = set()

# ───────────── 사이드바 : 단원 선택, 이동, 진도 ─────────────
with st.sidebar:
    st.subheader("단원 선택")
    topics = ["전체"] + list(dict.fromkeys(q["topic"] for q in QUESTIONS))   # 순서 유지하며 중복 제거
    topic = st.selectbox("단원", topics, label_visibility="collapsed")

    # 선택한 단원의 문제 번호 목록
    ids = [i for i, q in enumerate(QUESTIONS) if topic == "전체" or q["topic"] == topic]
    if st.session_state.idx not in ids:
        st.session_state.idx = ids[0]
    pos = ids.index(st.session_state.idx)

    col1, col2, col3 = st.columns(3)
    if col1.button("◀ 이전", width="stretch"):
        st.session_state.idx = ids[pos - 1]          # 처음에서 누르면 마지막으로
        st.rerun()
    if col2.button("랜덤", width="stretch"):
        st.session_state.idx = random.choice(ids)
        st.rerun()
    if col3.button("다음 ▶", width="stretch"):
        st.session_state.idx = ids[(pos + 1) % len(ids)]
        st.rerun()

    solved_here = len(st.session_state.solved & set(ids))
    st.progress(solved_here / len(ids), text=f"완료 {solved_here} / {len(ids)}")
    st.caption(f"전체 완료 {len(st.session_state.solved)} / {len(QUESTIONS)}")
    if st.button("진도 초기화", width="stretch"):
        st.session_state.solved = set()
        st.rerun()

# ───────────── 본문 : 문제 ─────────────
i = st.session_state.idx
q = QUESTIONS[i]
gradable = q.get("run", True)
setup = q.get("setup", "")

done = " ✅" if i in st.session_state.solved else ""
st.title(f"Q{pos + 1}. {q['topic']}{done}")
st.caption(f"출처 : {q['src']}  ·  {'자동 채점' if gradable else '정답 비교(자가 채점)'}")
st.markdown(q["q"])

if setup:
    st.write("**주어진 코드** (자동으로 먼저 실행됨)")
    st.code(setup, language="python")

# key 를 문제별로 → 다른 문제 갔다 와도 작성한 코드 유지
code = st.text_area("내 코드", key=f"code_{i}", height=220, placeholder="여기에 코드를 작성하세요")

if gradable:
    if st.button("채점하기", type="primary"):
        mine = run_code(setup + "\n" + code)
        expected = run_code(setup + "\n" + q["answer"])
        if code.strip() and mine == expected:
            st.success("정답입니다! 🎉")
            st.session_state.solved.add(i)
        else:
            st.error("출력이 다릅니다. 아래 결과를 비교해 보세요.")
        left, right = st.columns(2)
        left.write("내 출력")
        left.code(mine or "(출력 없음)", language="text")
        right.write("기대 출력")
        right.code(expected, language="text")
else:
    if st.button("다 풀었어요 (완료 표시)"):
        st.session_state.solved.add(i)
        st.rerun()

with st.expander("모범 답안 보기"):
    st.code(q["answer"], language="python")
