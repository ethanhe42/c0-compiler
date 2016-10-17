set -e

make clean
make 
./parser $1
