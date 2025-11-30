#include <stdio.h>
#include <stdlib.h>
#include <string.h>

//학생 구조체
typedef struct Node{
    char id[20];
    char name[30];
    int score;
    struct Node* next;
} Node;

void add_node(Node** head, char* id, char* name, int score){
    Node* new_node = (Node*)malloc(sizeof(Node));
    if(new_node == NULL) return;

    strcpy(new_node -> id, id);
    strcpy(new_node -> name, name);
    new_node -> score = score;
    new_node -> next = *head;
    *head = new_node;
}

void swap_data(Node* a, Node* b){
    int temp_score = a -> score;
    a -> score = b-> score;
    b-> score = temp_score;

    char temp_str[30];

    strcpy(temp_str, a->name);
    strcpy(a->name, b->name);
    strcpy(b->name, temp_str);

    strcpy(temp_str, a->id);
    strcpy(a->id, b->id);
    strcpy(b->id, temp_str);
}

void bubble_sort(Node* head){
    if( head == NULL) return;

    int swap;
    Node* pre = NULL;
    Node* curr;

    do{
        swap = 0;
        curr = head;

        while(curr->next != pre){
            if (curr -> score < curr -> next -> score){
                swap_data(curr,curr->next);
                swap = 1;
            }
            curr = curr -> next;
        }
        pre = curr;
    }while(swap);
}

void print_list(Node* node){
    printf("\n=== 성적 석차 리스트 ===\n");
    printf("등수\t학번\t\t이름\t점수\n");
    printf("---------------------------------------\n");

    int rank = 1;
    while(node != NULL){
        printf("%d등\t%s\t%s\t%d\n", rank++, node->id, node->name, node->score);
        node = node->next;
    }
    printf("----------------------------------------\n");
}

int main(){
    Node* head = NULL;
    char input_id[20];
    char input_name[30];
    int input_score;

    while(scanf("%s %s %d", input_id,input_name, &input_score) != EOF){
        add_node(&head, input_id, input_name, input_score);
    }

    bubble_sort(head);

    print_list(head);

    return 0;
}