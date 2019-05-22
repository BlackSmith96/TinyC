#!/usr/bin/python
# -*- coding: UTF-8 -*-

import sys
import os

if len(sys.argv) != 2:
	print 'Usage: python compiler.py source.c'
	exit(1)
else:
	if sys.argv[1][-2:] != '.c':
		print 'Input file format is incorrect.'
		exit(1)

os.system('./tinyC ' + sys.argv[1])
os.system('nasm -g -f elf64 -F dwarf ' + 'print_func.asm');
os.system('nasm -g -f elf64 -F dwarf ' + 'readint_func.asm');
os.system('nasm -g -f elf64 -F dwarf ' + sys.argv[1] + '.asm');
os.system('ld -g -o ' + sys.argv[1][:-2] + ' ' + sys.argv[1] + '.o ' + ' print_func.o readint_func.o')
#print('ld -g -o ' + sys.argv[1][:-2] + ' ' + sys.argv[1] + '.o ' + ' print_func.o readint_func.o')
exit(0)