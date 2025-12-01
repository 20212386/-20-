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