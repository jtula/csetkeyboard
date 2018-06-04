"""Recebe um arquivo com frases e imprime as palavras uma por linha, em ordem aleatorio"""

f = open("frasesEN.txt")
f.readline()
lista = []
for fr in f:
    pals = fr.strip()[0:-1].split(" ")
    for p in pals:
        lista.append(p+".")

import random
random.shuffle(lista)
for l in lista:
    print l
