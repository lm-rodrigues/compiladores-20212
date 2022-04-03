#!/bin/bash

for i in {0..9}
do
    ./etapa3 < ./testes/w0$i > ./testes/w0$i-resultado
done


for i in {10..76}
do
    ./etapa3 < ./testes/w$i > ./testes/w$i-resultado
done
