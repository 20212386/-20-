#!/usr/bin/env bash

# ==========================================
# 1. 전역 변수 설정
# ==========================================
DATA_FILE="grade_data.txt"
SORTED_FILE="sorted.txt"
REPORT_FILE="report.txt"
EXE_FILE="./grade.exe"
BACKUP_DIR="backup"

# ==========================================
# 2. 시스템 관리 및 백업 함수 (팀원 강경아)
# ==========================================

# 타임스탬프 자동 백업 함수
backup_with_timestamp() {
    # 1) 백업 폴더 없으면 생성
    if [ ! -d "$BACKUP_DIR" ]; then
        mkdir -p "$BACKUP_DIR"
    fi

    # 2) 데이터 파일 존재 확인
    if [ ! -f "$DATA_FILE" ]; then
        return 1
    fi

    # 3) 날짜+시간으로 백업 파일명 만들기
    DATE=$(date +%Y%m%d_%H%M)
    BACKUP_FILE="${BACKUP_DIR}/backup_${DATE}.tar.gz"

    # 4) tar로 압축
    tar -czf "$BACKUP_FILE" "$DATA_FILE" &> /dev/null

    # 5) 결과 출력
    if [ $? -eq 0 ]; then
        echo "[SUCCESS] 백업 완료: ${BACKUP_FILE}"
    else
        echo "[FAILURE] 백업 실패"
    fi
}

# 안전 종료 함수 (Ctrl+C 시 호출)
safe_exit() {
    echo
    echo "[INFO] 프로그램을 안전하게 종료합니다. 자동 백업을 수행합니다..."
    backup_with_timestamp
    echo "[INFO] 종료 완료."
    exit 0
}

# 디스크 모니터링 함수
monitor_disk() {
    while true; do
        clear
        echo "===== 실시간 디스크 사용량 모니터링 ====="
        df -h | head -n 10
        echo "-----------------------------------------"
        echo "3초마다 새로고침됩니다. (메뉴로 돌아가려면 Ctrl+C를 누르세요)"
        sleep 3
    done
}

# ==========================================
# 3. 데이터 입력 및 관리 함수 (팀원 이정현)
# ==========================================

# 학번 입력 및 검증
read_student_id() {
    while true; do
        echo -n "학번을 입력하세요 (9자리 숫자): "
        read student_id

        if [ -z "$student_id" ]; then
            echo ">> 학번은 비어 있을 수 없습니다."
            continue
        fi

        # 숫자만 있는지, 9자리인지 확인
        case "$student_id" in
            *[!0-9]*) echo ">> 숫자로만 입력해주세요.";;
            *)
                if [ "${#student_id}" -ne 9 ]; then
                    echo ">> 학번은 9자리여야 합니다." 
                else
                    break
                fi
                ;;
        esac
    done
}

# 점수 입력 및 검증
read_score() {
    while true; do
        echo -n "점수를 입력하세요 (0~100): "
        read score

        if [ -z "$score" ]; then
            echo ">> 점수는 비어 있을 수 없습니다."
            continue
        fi

        case "$score" in
            *[!0-9]*) echo ">> 숫자로만 입력해주세요.";;
            *)
                if [ "$score" -lt 0 ] || [ "$score" -gt 100 ]; then
                    echo ">> 점수는 0 이상 100 이하만 가능합니다."
                else
                    break
                fi
                ;;
        esac
    done
}

# 학생 정보 저장 (입력) 
save_student() {
    echo "===== [학생 정보 입력] ====="
    read_student_id
    
    # 중복 확인
    if grep -q "^$student_id " "$DATA_FILE" 2>/dev/null; then
        echo ">> [경고] 이미 존재하는 학번입니다."
        return
    fi

    echo -n "이름을 입력하세요: "
    read name
    read_score

    echo "$student_id $name $score" >> "$DATA_FILE"
    echo ">> DB에 저장되었습니다: $student_id $name $score"
}

# 학생 검색
search_student() {
    echo "===== [학생 검색] ====="
    echo -n "검색할 학번을 입력하세요: "
    read student_id
    
    result=$(grep "^$student_id " "$DATA_FILE" 2>/dev/null)

    if [ -z "$result" ]; then
        echo ">> 해당 학번($student_id)의 정보가 없습니다."
    else
        echo ">> 검색 결과: $result"
    fi
}

# 학생 점수 수정
update_score() {
    echo "===== [점수 수정] ====="
    echo -n "수정할 학번 입력: "
    read student_id

    if ! grep -q "^$student_id " "$DATA_FILE" 2>/dev/null; then
        echo ">> 데이터가 없습니다."
        return
    fi

    read_score # 새 점수 입력

    # 백업 후 수정
    cp "$DATA_FILE" "${DATA_FILE}.bak"
    
    # 이름 추출 후 수정
    OLD_NAME=$(grep "^$student_id " "$DATA_FILE" | awk '{print $2}')
    sed -i "s/^$student_id .*/$student_id $OLD_NAME $score/" "$DATA_FILE"
    echo ">> 수정 완료되었습니다."
}

# 학생 삭제
delete_student() {
    echo "===== [학생 삭제] ====="
    echo -n "삭제할 학번 입력: "
    read student_id

    if ! grep -q "^$student_id " "$DATA_FILE" 2>/dev/null; then
        echo ">> 데이터가 없습니다."
        return
    fi

    cp "$DATA_FILE" "${DATA_FILE}.bak"
    sed -i "/^$student_id /d" "$DATA_FILE"
    echo ">> 삭제 완료되었습니다."
}

# ==========================================
# 4. 데이터 분석 및 C언어 연동 (팀원 김재영)
# ==========================================
# C언어 컴파일 자동화 함수
check_and_compile() {
    if [ ! -f "$EXE_FILE" ]; then
        echo ">> 실행 파일($EXE_FILE)이 없습니다. 컴파일을 시작합니다..."
        
        if [ -f "grade.c" ]; then
            gcc -o grade.exe grade.c
            if [ $? -eq 0 ]; then
                echo ">> [성공] 컴파일 완료!"
            else
                echo ">> [오류] 컴파일 실패! grade.c 코드를 확인하세요."
                return 1
            fi
        else
            echo ">> [오류] 소스코드(grade.c)가 없습니다."
            return 1
        fi
    fi
    return 0
}

process_data() {
    echo "===== [성적 정렬 및 분석] ====="
    
    check_and_compile
    if [ $? -ne 0 ]; then return; fi

    if [ ! -f "$DATA_FILE" ]; then
        echo ">> 데이터 파일이 없습니다. 먼저 데이터를 입력하세요."
        return
    fi

    echo "1. C 프로그램으로 정렬 수행 중..."
    cat "$DATA_FILE" | "$EXE_FILE" > "$SORTED_FILE"
    
    echo "2. 정렬 결과 확인:"
    cat "$SORTED_FILE"

    echo "3. 리포트 파일 생성 중..."
    if [ -f "make_report.awk" ]; then
        awk -f make_report.awk "$SORTED_FILE" > "$REPORT_FILE"
        echo ">> 리포트 생성 완료: $REPORT_FILE"
        echo ">> (내용 확인: cat $REPORT_FILE)"
    else
        echo ">> (make_report.awk 파일이 없어 리포트 생성 건너뜀)"
    fi
}

# ==========================================
# 5. 메인 메뉴 (프로그램 시작점)
# ==========================================
main() {
    # Ctrl+C 시그널 감지 설정
    trap safe_exit SIGINT

    # 데이터 파일 없으면 생성
    touch "$DATA_FILE" 2>/dev/null

    while true; do
        echo
        echo "=========================================="
        echo "   Linux Smart Grade Manager (L.S.G.M)    "
        echo "=========================================="
        echo "1. 학생 정보 입력 (Add)"
        echo "2. 학생 검색 (Search)"
        echo "3. 점수 수정 (Update)"
        echo "4. 학생 삭제 (Delete)"
        echo "5. 성적 정렬 및 분석 (C언어 연동)"
        echo "6. 디스크 모니터링"
        echo "7. 강제 백업 수행"
        echo "0. 종료 (Exit)"
        echo "=========================================="
        echo -n "메뉴를 선택하세요: "
        read choice

        case "$choice" in
            1) save_student ;;
            2) search_student ;;
            3) update_score ;;
            4) delete_student ;;
            5) process_data ;;
            6) monitor_disk ;;
            7) backup_with_timestamp ;;
            0) safe_exit ;;
            *) echo ">> 잘못된 입력입니다." ;;
        esac
        echo
        echo "엔터를 누르면 메뉴로 돌아갑니다..."
        read
    done
}

# 프로그램 시작
main

