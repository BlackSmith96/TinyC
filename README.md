# TinyC

### 实验环境

* Ubuntu 18.04 64-bit
* make
* flex
* bison
* nasm
* python2.7

### 运行说明

​	`make clean`

​	`make`

   `python compiler.py source.c`

​	`./source`

ps.文件夹中的`file.c`和`test.c`均为测试代码

### 调试说明

​	`gdb source`

 ### 编译过程

源代码-> Pcode和x86汇编混合的汇编文件(*.asm*文件)->*Nasm*宏->汇编文件->目标程序

### 语法特性说明

* 函数
  * 必须存在`main`函数
  * 函数在调用前必须定义(ps.后面改进的话可以支持函数申明)
  * 函数返回类型只有`void`、`int`
* 变量
  * 类型
    * `int`
  * 声明
    * 在声明时不能初始化
* 库函数
  * `readint()`
    * 返回值`int`
    * 使用时必须结合赋值语句
  * `print('....',arg1,arg2...)`
    * 返回值`void`
    * 输出格式中目前只支持`%d`

### 语义分析

​    语义分析的主要部分通过`HashTable`中记录各个函数的参数、变量信息。同时`HashTable`记录了参数和变量的内存位置。

### 代码生成

​	实现方法为Pcode.

### Runtime

​    参考linux汇编内存模型