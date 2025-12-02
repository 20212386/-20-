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

# ==========================
#  학번 / 점수 입력 함수
# ==========================

read_student_id() {
    while [ 1 ] 
    do
        echo "학번을 입력하세요: "
        read student_id

        # 비어있는지 확인
        if [ -z "$student_id" ]
        then
            echo "학번은 비어 있을 수 없습니다."
            continue
        fi

        # 숫자 이외의 문자가 섞였는지 확인 (*[!0-9]* 패턴이면 숫자가 아닌 문자가 있음)
        case "$student_id" in
            ''|*[!0-9]*)
            # 공백이거나, 숫자가 아닌 문자가 하나라도 포함된 경우
                echo "학번은 숫자만 입력해야 합니다.";;
            *)
                if [ "${#student_id}" -ne 9 ]
                then
                    echo "학번은 9자리여야 합니다."
                    continue
                fi
                echo "유효한 학번입니다."
                break;;
        esac
    done
}

read_score() {

}

