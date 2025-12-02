feature/backup
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

echo "[2] 기능 1 - C프로그램으로 정렬 수행 (파이프로 C 프로그램 호출) "
cat "$DATA_FILE" | "$EXE_FILE" > "$SORTED_FILE"

echo "[3] 기능 2 - awk로 리포트 생성 "
awk -f make_report.awk "$SORTED_FILE" > "$REPORT_FILE"

echo "[4] 완료!"

echo "정렬 결과 : $SORTED_FILE"
echo "리포트    : $REPORT_FILE"



# [팀원 C] 타임스탬프 자동 백업 함수
backup_with_timestamp() {
    DATA_FILE="grade_data.txt"  # 성적 DB 파일
    BACKUP_DIR="backup"         # 백업 폴더 이름

    # 1) 백업 폴더 없으면 생성
    if [ ! -d "$BACKUP_DIR" ]; then
        mkdir -p "$BACKUP_DIR"
    fi

    # 2) 데이터 파일 존재 확인
    if [ ! -f "$DATA_FILE" ]; then
        echo "[ERROR] 데이터 파일(${DATA_FILE})이 없습니다."
        return 1
    fi

    # 3) 날짜+시간으로 백업 파일명 만들기
    DATE=$(date +%Y%m%d_%H%M)   # 예: 20251201_2130
    BACKUP_FILE="${BACKUP_DIR}/backup_${DATE}.tar.gz"

    # 4) tar로 압축
    tar -czf "$BACKUP_FILE" "$DATA_FILE"

    # 5) 결과 출력
    if [ $? -eq 0 ]; then
        echo "[SUCCESS] 백업 완료: ${BACKUP_FILE}"
    else
        echo "[FAILURE] 백업 실패"
        return 1
    fi
}

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
main
