"""Recebe um arquivo com texto e elimina todos os caracteres latinos.
Obs. nao aceita os simbolos '! ?' nem outros caracteres especiais"""

# -*- coding: utf-8 -*-

import unicodedata, sys

def remove_accents(input_str):
    nkfd_form = unicodedata.normalize('NFKD', input_str)
    return u"".join([c for c in nkfd_form if not unicodedata.combining(c)])

filein = sys.argv[1]
fileout = filein+"_no_accents"

fin = open(filein, "rt")
fout = open(fileout, "wt")

for l in fin:
    print l
    fout.write ( remove_accents( unicode(l[0:len(l)-1],  "utf8") ).lower() +"\n" )
    #fout.write(remove_accents(unicode(l))+"\n")


