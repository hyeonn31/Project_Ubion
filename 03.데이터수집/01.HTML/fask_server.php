<?php
     // POST로 넘어온 값 받기
    $id = $_POST['id'] ?? '';
    $pw = $_POST['pw'] ?? '';

    // 간단한 로그인 검증 예시 (실제로는 DB와 연동해야 함)
    $valid_id = "admin";
    $valid_pw = "1234";

    if ($id === $valid_id && $pw === $valid_pw) {
        echo "<h2>로그인 성공 🎉</h2>";
        echo "<p>안녕하세요, {$id}님!</p>";
    } else {
        echo "<h2>로그인 실패 ❌</h2>";
        echo "<p>아이디 또는 비밀번호가 잘못되었습니다.</p>";
    }
>