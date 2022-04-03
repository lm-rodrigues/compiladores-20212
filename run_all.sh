#!/bin/bash

for i in {0..41}
do
    ./etapa4 < ./testes-e4/certos/cert$i > ./testes-e4/certos/cert$i-resultado
done


for i in {0..74}
do
    ./etapa4 < ./testes-e4/com-erros/err$i > ./testes-e4/com-erros/err$i-resultado
done
