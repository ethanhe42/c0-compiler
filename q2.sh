set -e

make clean
make 

testfolder="test"
for name in ${testfolder}/*.c; do
    echo parsing $name
    ./parser $name | xml_pp | tee ${name}.xml
done
