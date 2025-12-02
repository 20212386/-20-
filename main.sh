#!/usr/bin/env bash

########################################
# 공통 설정
########################################
DATA_FILE="grade_data.txt"
SORTED_FILE="sorted.txt"
REPORT_FILE="report.txt"
EXE_FILE="./grade.exe"

########################################
# 0. 성적 정렬 + 리포트 생성 (네가 한 기능)
########################################
run_grade_flow() {
    echo "[1] 성적 데이터 파일 확인 중"

    if [ ! -f "$DATA_FILE" ]; then
        echo "데이터 파일이 존재하지 않습니다: $DATA_FILE"
        return 1
    fi

    if [ ! -f "$EXE_FILE" ]; then
        echo "C 프로그램 실행 파일이 없습니다: $EXE_FILE"
        return 1
    fi

    echo "[2] 기능 1 - C프로그램으로 정렬 수행 (파이프로 C 프로그램 호출)"
    cat "$DATA_FILE" | "$EXE_FILE" > "$SORTED_FILE"

    echo "[3] 기능 2 - awk로 리포트 생성"
    awk -f make_report.awk "$SORTED_FILE" > "$REPORT_FILE"

    echo "[4] 완료!"
    echo "정렬 결과 : $SORTED_FILE"
    echo "리포트    : $REPORT_FILE"
}

########################################
# [팀원 C] 디스크 모니터링 + 안전 종료
########################################
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

########################################
# [팀원 C] 타임스탬프 자동 백업
########################################
backup_with_timestamp() {
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

safe_exit() {
    echo
    echo "[INFO] 프로그램을 안전하게 종료합니다. 백업을 수행합니다..."
    backup_with_timestamp
    echo "[INFO] 종료 완료."
    exit 0
}

########################################
# [팀원 B] 입력값 검증 + DB CRUD
########################################
read_student_id() {
    while true
    do
        echo "학번을 입력하세요: "
        read student_id

        # 비어있는지 확인
        if [ -z "$student_id" ]; then
            echo "학번은 비어 있을 수 없습니다."
            continue
        fi

        # 숫자 이외의 문자가 섞였는지 확인
        case "$student_id" in
            ''|*[!0-9]*)
                echo "학번은 숫자만 입력해야 합니다."
                ;;
            *)
                if [ "${#student_id}" -ne 9 ]; then
                    echo "학번은 9자리여야 합니다."
                    continue
                fi
                break
                ;;
        esac
    done
}

read_score() {
    while true
    do
        echo "점수를 입력하세요 (0~100): "
        read score

        if [ -z "$score" ]; then
            echo "점수는 비어 있을 수 없습니다."
            continue
        fi

        case "$score" in
            ''|*[!0-9]*)
                echo "점수는 숫자만 입력해야 합니다."
                continue
                ;;
            *)
                if [ "$score" -lt 0 ] || [ "$score" -gt 100 ]; then
                    echo "점수는 0 이상 100 이하만 입력할 수 있습니다."
                    continue
                fi
                break
                ;;
        esac
    done
}

save_student() {
    read_student_id

    # 이미 같은 학번이 있는지 체크
    if grep -q "^$student_id " "$DATA_FILE"; then
        echo "이미 존재하는 학번입니다. 기존 데이터를 덮어쓰려면 나중에 '수정 기능'에서 처리하세요."
        return
    fi
    echo "이름을 입력하세요: "
    read name

    read_score

    echo "$student_id $name $score" >> "$DATA_FILE"
    echo "DB에 저장 완료: $student_id $name $score
}

search_student() {
    echo "===== 학생 검색 ====="
    read_student_id

    result=$(grep "^$student_id " "$DATA_FILE")

    if [ -z "$result" ]; then
        echo "해당 학번($student_id)의 정보가 DB에 없습니다."
    else
        echo "검색 결과: $result"
    fi
}

update_score() {
    echo "===== 점수 수정 ====="
    read_student_id

    # 해당 학번 존재 여부 확인
    if ! grep -q "^$student_id " "$DATA_FILE"; then
        echo "해당 학번($student_id)의 정보가 DB에 없습니다."
        return
    fi

    old_line=$(grep "^$student_id " "$DATA_FILE")
    student_name=$(echo "$old_line" | awk '{print $2}')

    # 새 점수 입력
    read_score

    cp "$DATA_FILE" "${DATA_FILE}.bak"

    sed -i "s/^$student_id .*/$student_id $student_name $score/" "$DATA_FILE"

    echo "$student_id ($student_name) 의 점수를 $score 로 수정했습니다."
}


delete_student() {
    echo "===== 학생 삭제 ====="
    read_student_id

    if ! grep -q "^$student_id " "$DATA_FILE"; then
        echo "해당 학번($student_id)의 정보가 DB에 없습니다."
        return
    fi

    cp "$DATA_FILE" "${DATA_FILE}.bak"

    sed -i "/^$student_id /d" "$DATA_FILE"

    echo "학번 $student_id 의 정보를 삭제했습니다."
}

########################################
# 메인 메뉴
########################################
show_menu() {
    echo
    echo "===== 메인 메뉴 ====="
    echo "1) 성적 정렬 + 리포트 생성"
    echo "2) 학생 추가"
    echo "3) 학생 검색"
    echo "4) 점수 수정"
    echo "5) 학생 삭제"
    echo "6) 디스크 모니터링 (Ctrl+C로 종료 → 백업)"
    echo "0) 종료"
    echo "======================"
}

main() {
    while true
    do
        show_menu
        echo -n "메뉴 선택: "
        read choice

        case "$choice" in
            1) run_grade_flow ;;
            2) save_student ;;
            3) search_student ;;
            4) update_score ;;
            5) delete_student ;;
            6) monitor_disk ;;   # Ctrl+C 누르면 safe_exit -> backup 실행
            0)
                echo "프로그램을 종료합니다."
                break
                ;;
            *)
                echo "잘못된 선택입니다."
                ;;
        esac
    done
}

########################################
# Ctrl+C 신호 처리 + 메인 실행
########################################
trap safe_exit SIGINT
main
//fix: main.sh  통합 및 에러 수정


