f = open("../frasesES.txt")
f.readline()
lista = []
for fr in f:
    for i in range(0, len(fr)-1):
        if fr[i] == fr[i+1]:
            print "Letra repetida em: ", fr
