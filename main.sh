feature/새기능이름

#!/usr/bin/env bash

DATA_FILE="grade_data.txt"
SORTED_FILE="sorted.txt"
REPORT_FILE="report.txt"
EXE_FILE="./grade.exe"

echo "[1] 성적 데이터 파일 확인 중"

if [ ! -f "$DATA_FILE" ]; then
    echo "데이터 파일이 존재하지 않습니다: $DATA_FILE"
    exit 1
fi

if [ ! -f "$EXE_FILE" ]; then
    echo "C 프로그램 실행 파일이 없습니다: $EXE_FILE"
    exit 1
fi

echo "[2] 기능 1 -C프로그램으로 정렬 수행 (파이프로 C 프로그램 호출) "
cat "$DATA_FILE" | "$EXE_FILE" > "$SORTED_FILE"

echo "[3]  기능 2 - awk로 리포트 생성 "
awk -f make_report.awk "$SORTED_FILE" > "$REPORT_FILE"

echo "[4] 완료!"
echo "정렬 결과 : $SORTED_FILE"
echo "리포트    : $REPORT_FILE"


# [팀원 C] 디스크 모니터링 함수
monitor_disk() {
    while true
    do
        clear
        echo "===== 디스크 사용량 ====="
        df -h | head -n 10
        echo
        echo "3초마다 새로고침됩니다. 종료하려면 Ctrl+C 를 누르세요."
        sleep 3
    done
}

# [팀원 C] 안전 종료 함수 (Ctrl+C 시 호출)
safe_exit() {
    echo
    echo "[INFO] 프로그램을 안전하게 종료합니다. 백업을 수행합니다..."
    backup_with_timestamp       # 1번 기능에서 만든 함수 재사용
    echo "[INFO] 종료 완료."
    exit 0
}

# Ctrl+C(SIGINT) 들어오면 safe_exit 실행
trap safe_exit SIGINT
main


search_student() {
    echo "===== 학생 검색 ====="
    read_student_id   # student_id 변수 설정
    # 대상 존재 여부 먼저 확인
    result=$(grep "^$student_id " "$DATA_FILE") #^는 student_id로 시작하고 그 뒤에 공백이 존재하는 줄을 의미 함

    if [ -z "$result" ]; then
        echo "해당 학번($student_id)의 정보가 DB에 없습니다."
    else
        echo "검색 결과: $result"
    fi
}

update_score() {
    echo "===== 점수 수정 ====="
    read_student_id   # student_id 변수 설정
    
    if ! grep -q "^$student_id " "$DATA_FILE"; then
        echo "해당 학번($student_id)의 정보가 DB에 없습니다."
        return
    fi

    # 새 점수 입력받기
    read_score        

    # 백업 파일을 하나 만들고 수정하는 방식 (실수 방지용)
    cp "$DATA_FILE" "${DATA_FILE}.bak"

    # 줄 전체를 "학번 점수" 형태로 교체
    sed -i "s/^$student_id .*/$student_id $score/" "$DB_FILE" #s:대체 .*:뒤에 뭐가 오든 전부

    echo "$student_id 의 점수를 $score 로 수정했습니다."
}

delete_student() {
    echo "===== 학생 삭제 ====="
    read_student_id 

    if ! grep -q "^$student_id " "$DATA_FILE"
    then
        echo "해당 학번($student_id)의 정보가 DB에 없습니다."
        return
    fi

    cp "$DATA_FILE" "${DATA_FILE}.bak"

    # 해당 학번으로 시작하는 줄 삭제
    sed -i "/^$student_id /d" "$DATA_FILE" #d: 삭제

    echo "학번 $student_id 의 정보를 삭제했습니다."
}