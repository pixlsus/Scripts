#!/bin/bash

# Version 0.1
# originally from https://discuss.pixls.us/t/annotation-with-imagemagick-watermark-ish/1813/6

#---------------------------------------------------------------------------
# Variables.
#---------------------------------------------------------------------------

MULTIPLIER=0.05 # Percentage of the image height the footer height will be.
LOGOMULTIPLIER=0.04 # The size of the logo in relation to the image height.
POINTSIZEMULTIPLIER=0.020 # Font size in relation to the image height.
HORIZONTAL_OFFSET=0.015 # How far to indent the logo and text relative to the image height.
LOGODARK="/path/to/your/dark_logo.png"
LOGOBRIGHT="/path/to/your/bright_logo.png"
FONTDARK="srgb(10%,10%,10%)"
FONTBRIGHT="srgb(90%,90%,90%)"
COPYRIGHTHOLDER="Your Name Here"
COMMENTTAG="usercomment" # Change this to 'comment' if if you use that tag.
PREFIX="pixls.us_" # The prefix for the new files.
FORMAT=jpg # Define the output format here.

############################################################################
# WARNING: ONLY TOUCH STUFF BELOW THIS POINT IF YOU KNOW WHAT YOU ARE  DOING.
############################################################################

#---------------------------------------------------------------------------
# Here we go.
#---------------------------------------------------------------------------

for i in "$@"
do

		# Extract height and width of the image.
		WIDTH=$(identify -quiet -format "%w" "$i")
		HEIGHT=$(identify -quiet -format "%h" "$i")

		# Calculate footer height (FH).
		FH="$(echo "$HEIGHT*$MULTIPLIER" | bc)"

		# Calculate new image height without logo (IH).
		IH="$(echo "$HEIGHT-$FH" | bc)"

		# Calculate logo height (LH).
		LH="$(echo "$HEIGHT*$LOGOMULTIPLIER" | bc)"

		# Extract the value of the comment tag.
		COMMENT=$(exiftool -s -s -s -m -"$COMMENTTAG" "$i")

		# Extract the average color of the image to use as fill.
		FILL=$(convert "$i" -quiet -scale 1x1\! -format '%[pixel:s]' info:-)

		printf " "$i": Dark or bright logo and font? [D/B]" ; read -e -p ": " CHOICE

		case $CHOICE in
				[dD]* )
						TEXTCOLOR="$FONTDARK"
						LOGO="$LOGODARK"
						;;

				* )
						TEXTCOLOR="$FONTBRIGHT"
						LOGO="$LOGOBRIGHT"
						;;

		esac

		# Calculate the pointsize (PS).
		PS="$(echo "$HEIGHT*$POINTSIZEMULTIPLIER" | bc)"

		# Get the year for the copyright notice.
		FULLDATE=$(exiftool -s -s -s -CreateDate "$i")
		YEAR=${FULLDATE:0:4}

		# Calculate horizontal comment offset (HO).
		HO="$(echo "$WIDTH*$HORIZONTAL_OFFSET" | bc)"

		# Calculate horizontal logo offset (LO).
		LO="$(echo "$WIDTH*$HORIZONTAL_OFFSET*0.75" | bc)"

		# Calculate horizontal copyright offset (CO)
		LOGOWIDTH=$(identify -quiet -format "%w" "$LOGO")
		LOGOHEIGHT=$(identify -quiet -format "%h" "$LOGO")
		RATIO="$(echo "$LOGOHEIGHT/$LH" | bc -l)"
		LW="$(echo "$LOGOWIDTH/$RATIO" | bc)"
		CO="$(echo "($LO*2)+$LW" | bc)"

		# Do the magic on the image.
		convert "$i" -resize x$IH \
						\( +clone \
						-quiet \
						-fill "$FILL" \
						-draw 'color 0,0 reset' \
						-resize x$FH! \
						-fill "$TEXTCOLOR" \
						-pointsize "$PS" \
						-gravity east \
						-annotate +$HO+0 "$COMMENT" \
						-gravity west \
						-annotate +$CO+0 "© $YEAR $COPYRIGHTHOLDER" \
						-gravity west \
						\( "$LOGO" -resize x$LH \) \
						-geometry +$LO+0 -composite \) \
						-append "$PREFIX""${i%.*}"."$FORMAT"
done
