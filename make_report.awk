#make_report.awk
#입력 형식: 학번 이름 점수
#출력: 학번, 이름, 점수, 합/불 + 전체 평균, 최고점

BEGIN{
    total = 0
    count = 0
    max = -1

    print "===== 성적 리포트 ====="
    printf "학번\t\t이름\t점수\t판정\n"
    print "-----------------------------------"
}

{
    id = $1
    name = $2
    score = $3 + 0

    total += score
    count++

    if (score > max) {
        max = score
        top_id = id
        top_name = name
    }

    pass = (score >= 70 ? "합격" : "불합격")
    printf "%s\t%s\t%d\t%s\n", id, name, score, pass
}

END {
    if (count > 0) {
        avg = total / count
        print "-----------------------------------"
        printf "평균 점수: %.2f\n", avg
        printf "최고 점수: %d (%s)\n", max, top_name
    }
    else {
        print "데이터가 없습니다."
    }
}