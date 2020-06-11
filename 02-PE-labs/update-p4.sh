wget src.nop.hu/rtr.zip
mkdir a
unzip -d a/ rtr.zip
rm rtr.zip
mv a/misc/p4lang/forwarder.py p4src/
mv a/misc/p4lang/router.p4 p4src/
mv a/misc/p4lang/include/* p4src/include/
rm -Rf a
