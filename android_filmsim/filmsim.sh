#!/data/data/com.termux/files/usr/bin/sh
cd storage/dcim/Camera
rawext=`termux-dialog -t "Raw file type" -i "dng"`
rawf="temp."$rawext
hc="haldCLUT.png"
echo > $rawf
echo > $hc
rawfMDSUM=`stat -c %Y $rawf`
echo "Choose the raw file you want to process."
termux-storage-get $rawf
while [ `stat -c %Y $rawf` -eq $rawfMDSUM ]; do
sleep 2
done
echo "Choose the hald-CLUT you want to use."
hcMDSUM=`stat -c %Y $hc`
termux-storage-get $hc
while [ `stat -c %Y $hc` -eq $hcMDSUM ]; do
sleep 2
done
out=`termux-dialog -t "Output image file" -i "example.jpg"`
echo "Processing. Please be patient...."
dcraw -c $rawf | convert - $hc -hald-clut $out
rm $rawf $hc
exit 0
