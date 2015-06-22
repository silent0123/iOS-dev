//
//  main.c
//  SortAndSeek
//
//  This code including some main basic sort and seek algorithms
//  For Luca to learn these algorithms
//
//  Created by Luca on 22/6/15.
//  Copyright (c) 2015年 Luca. All rights reserved.
//

#include <stdio.h>
#include <time.h>
#include <stdlib.h>

#pragma mark - SWAP
void swap(int *a, int *b) {
    
    //swap the two value's pointer address, rather than just swap value copy
    //如果相同，则异或结果会为0.所以要避免
    if (*a != *b) {
        
        *a ^= *b;
        *b ^= *a;
        *a ^= *b;
    }

}

void *randomArrayGeneration(int arrayToRandomGenerate[], int length, int max) {
    
    srand((unsigned)time(NULL));
    
    for (int i = 0; i < length; i ++) {

        arrayToRandomGenerate[i] = 1+rand()%max;
    }

    return 0;
}

#pragma mark - SORTs
//basic bubbleSort O(n^2)
void bubbleSort(int *arrayToSort, int startPos, int endPos) {
    
    //注意，这个排序方法，每一次的冒泡排序都会将最大的顶到最末端，所以每一次只用扫描i到n-i就好，扫描一次之后i++
    
    int numberOfValue = endPos - startPos + 1;
    
    for (int i = 0; i < numberOfValue; i ++) {
        
        for (int j = 1; j < numberOfValue - i ; j ++) {
            
            if (arrayToSort[j - 1] > arrayToSort[j]) {

                swap(&arrayToSort[j - 1], &arrayToSort[j]);
                
            }
        }
    }

}

//improved bubbleSort O(n)
void bubbleSortWithFlag(int *arrayToSort, int startPos, int endPos) {
 
    int numberOfValue = endPos - startPos + 1;
    
    int flag = 1;   //设置一个标志位来检测本次向后的检测是否有数据交换，如果没有，则表示已经有序了
    int k = 0;
    
    
    while (flag) {
        
        flag = 0;
        
        for (int j = 1; j < numberOfValue - k; j ++) {
            
            
            if (arrayToSort[j - 1] > arrayToSort[j]) {
                swap(&arrayToSort[j - 1], &arrayToSort[j]);
                flag = 1;
            }
        }
        
        
        k ++;
        
    }
    
}

//inserSort O(n) to O(n^2)
void insertSort(int *arrayToSort, int startPos, int endPos) {

    int numberOfValue = endPos - startPos + 1;
    
    int i, j;
    for (i = 1; i < numberOfValue; i ++) {
        
        if (arrayToSort[i] < arrayToSort[i - 1]) {
            
            //如果没有找到逆序对，说明到目前为止，前面的数列都是有序的
            //如果找到了逆序对
            int temp = arrayToSort[i];
            for (j = i - 1; j >=0 && arrayToSort[j] > temp; j --) {
                
                //在已经排序的队列中找到比它大的数
                //并且将这个数之后的所有位置后移
                
                arrayToSort[j + 1] = arrayToSort[j];
            }
            
            //插入j + 1的位置。为什么这里j + 1，因为上面执行之后j-- 了
            arrayToSort[j + 1] = temp;
        }
    }

}

//注意，O(nlogn)平均时间复杂度的算法有：快速、归并、希尔、堆

//shellSort O(nlogn) -  其实是分组插入排序，分组方式通过gap确定
void shellSort(int *arrayToSort, int startPos, int endPos) {
    
    int numberOfValue = endPos - startPos + 1;
    
    int gap = numberOfValue/2;  //初始值为2个一组，分为总数/2组
    int i,j;
    
    for (gap = gap; gap > 0; gap /= 2) {
        
        //前半段
        for (i = 0; i < gap; i ++) {
            
            //后半段
            for (j = gap + i; j < numberOfValue; j += gap) {
                
                if (arrayToSort[j + i] < arrayToSort[j + i - gap]) {
                    
                    swap(&arrayToSort[j - gap + i], &arrayToSort[j + i]);
                }
            }
        }
    }
}

//selectSort O(n^2)
void selectSort(int *arrayToSort, int startPos, int endPos) {

    int numberOfValue = endPos - startPos + 1;
    int i,j;
    int minValueIndex = 0;
    
    //以start为基准，start+1开始逐个扫描，加入最后，初始化的时候，无序区为start
    for (i = 0; i < numberOfValue; i ++) {
        
        minValueIndex = i;
        
        for(j = i + 1; j < numberOfValue; j ++) {
            
            if (arrayToSort[j] < arrayToSort[minValueIndex]) {
                minValueIndex = j;
            }
        }
        
        //找到最小值，放到无序区的开头
        swap(&arrayToSort[i], &arrayToSort[minValueIndex]);
        
    }
    
    
}

//quickSort O(nlogn), 如已经有序 O(n^2)
//挖坑代码
int adjustArray(int *arrayToSort, int startPos, int endPos) {

    int i = startPos;
    int j = endPos;
    int baseValue = arrayToSort[startPos];  //首先以第一个为基准
    
    while (i < j) {
        
        while (j > i && arrayToSort[j] >= baseValue) {
            j --;
        }   //跳过所有比baseValue大的
        
        if (j > i) {
            //找到比baseValue小的
            //swap(&arrayToSort[i], &arrayToSort[j]);
            arrayToSort[i] = arrayToSort[j];
            i ++;
        }
        
        while (i < j && arrayToSort[i] <= baseValue) {
            //跳过所有比baseValue小的
            i ++;
        }
        
        if (i < j) {
            //找到比baseValue大的
            //swap(&arrayToSort[i], &arrayToSort[j]);
            arrayToSort[j] = arrayToSort[i];
            j --;
        }

    }
    
    //回填baseValue
    arrayToSort[i] = baseValue;
    
    return i ;
}
//分治法代码
void quickSort(int *arrayToSort, int startPos, int endPos) {

    if (startPos < endPos) {
        
        //startPos >= endPos，表示已经扫描结束
        
        int basePos = adjustArray(arrayToSort, startPos, endPos);
        quickSort(arrayToSort, startPos, basePos - 1);
        quickSort(arrayToSort, basePos + 1, endPos);
    }

}

#pragma mark - MAIN
int main(int argc, const char * argv[]) {
    
    int a[10];
    randomArrayGeneration(a, 10, 100);
    
    //bubbleSort(a, 0, 9);
    //bubbleSortWithFlag(a, 0, 9);
    //insertSort(a, 0, 9);
    //shellSort(a, 0, 9);
    selectSort(a, 0, 9);
    //quickSort(a, 0, 9);
    
    for (int i = 0; i < 10; i ++) {
        printf("%d, ", a[i]);
    }

    return 0;
}



