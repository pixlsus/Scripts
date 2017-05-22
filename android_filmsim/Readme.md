# A full Android FOSS raw imageing pipeline (tutorial)

As an Android user, amateur photographer, and FOSS advocate, I've long wished for a fully FOSS imaging pipeline on Android. I often use my Android phone for photography. It's always on me and the camera hardware in them keeps getting better and better. There's been some great FOSS Android software improvements recently too. I've finally figured out a fully FOSS pipeline that can go from raw image capture right through to a final, processed image. This post is meant to share the pipeline I've discovered, and I hope it will be a guide for others who want to implement a similar imaging pipeline.

Before we get started, here's some quick links to all the things you are going to need to pull this off. 

> ***Required Android Apps***
> 1. [Open Camera](https://f-droid.org/repository/browse/?fdfilter=open+camera&fdid=net.sourceforge.opencamera)
> 2. [Amaze File Manager](https://f-droid.org/repository/browse/?fdfilter=amaze&fdid=com.amaze.filemanager)
> 3. [Termux](https://f-droid.org/repository/browse/?fdfilter=termux&fdid=com.termux)
> 4. [Termux API](https://f-droid.org/repository/browse/?fdfilter=oi&fdid=com.termux.api)
> 5. [Termux Widget](https://f-droid.org/repository/browse/?fdfilter=termux&fdid=com.termux.widget)
>
> ***Required files***
> 1. The [filmsim.sh](https://github.com/PixlsStuff/Scripts/tree/master/android_filmsim) script.
> 2. Some [hald-CLUT film emulation files](http://blog.patdavid.net/2015/03/film-emulation-in-rawtherapee.html).

## Capturing raw images on Android

This part is easy thanks to the really great [Open Camera](https://f-droid.org/repository/browse/?fdfilter=open+camera&fdid=net.sourceforge.opencamera) app. This is a truly great camera app, with many excellent capabilities. Most importantly to me, it is FOSS, offers manual exposure controls, and allows raw image capture in .dng format. To enable raw image capture, you must have a phone that implements the "Camera2 API". [Here is a list](http://www.smartphonesnap.com/articles/list-android-phones-that-take-raw-photos) of some phones that support this API. My phone is the Nexus 5x, and Open Camera raw capture works very well with it. You must enable this feature to be able to capture raw images

1. Within Open Camera, open the settings (cogwheel icon).
2. Scroll down, and check "Use Camera2 API". 
3. Click the "Photo Settings" option, and tap "RAW"
4. Select "JPEG and DNG (RAW)". 

Now, you will save both a jpeg and a .dng raw file of every image you shoot with the Open Camera app.

## Developing raw images on Android

This has been the more difficult part of the problem to overcome. But I've recently solved this gap in large part thanks to the very cool FOSS app called [Termux](https://f-droid.org/repository/browse/?fdfilter=termux&fdid=com.termux). Termux is a really brilliant solution to install a minimal Debian-based CLI Linux distro on Android *without the need for root*. Termux is really awesome, and includes many smart ways to interact with the terminal using your phone's hardware keys and onscreen keyboard. Read the help [here](https://termux.com/help.html) to learn some of these shortcuts. They will be useful. Now, what's really cool and useful for us is that you can install several of your favorite command line image processing tools, which the Temux project has precompiled for ARM processors and hosted for you in its apt repository. For us, the two important tools are dcraw and imagemagick.

#### Setting up Termux

First things first, however: we need to get Termux installed, and then add a few little bells and whistles that will come in handy.

1. Using f-droid (or the Play Store), install the [Termux](https://f-droid.org/repository/browse/?fdfilter=termux&fdid=com.termux) app, the [Termux API](https://f-droid.org/repository/browse/?fdfilter=oi&fdid=com.termux.api) app, and the [Termux Widget](https://f-droid.org/repository/browse/?fdfilter=termux&fdid=com.termux.widget) apps on your phone.
2. Open a Termux session by tapping on the Termux app. 
3. Update the repositories and upgrade the Termux system to the latest releases: 
    `apt update && apt upgrade` 
4. Install some packages that our filmsim.sh script requires:
    `apt install termux-api coreutils dcraw graphicsmagick`. 
5. Give Termux access to your file storage:
    `termux-setup-storage` 
 A little pop-up will appear asking if you want to give Termux permission to access your file storage. Accept this. 

We now have Termux ready to go, but we aren't finished yet. We will have to arrange some files and get our script set up to be run as widget. We can do that with [Amaze File Manager](https://f-droid.org/repository/browse/?fdfilter=amaze&fdid=com.amaze.filemanager) and from the Termux command line itself. The main directory for Termux is `storage`, and from there you can `cd storage\dcim\`, where you can stage these files in the next steps.

#### An Android RAW development approach

The raw development approach that I came up with relies on using your favorite hald CLUTs to alter the colors of your raw images to a final jpeg right from the command line. I use @patdavid's awesome [film emulation hald CLUTs](http://blog.patdavid.net/2015/03/film-emulation-in-rawtherapee.html). This is accomplished using [dcraw](https://www.cybercom.net/~dcoffin/dcraw/) to decode the RAW image, and [graphicsmagick](http://www.graphicsmagick.org/) to apply the hald-CLUT tone adjustments. These two tools are the heart of my filmsim.sh script, which helps you to automate that process. We installed dcraw and graphicsmagick already, but we need to get some other things set up for all this to work:

1. Using Amaze File Manager, create a new folder in "dcim" named "haldCLUT." 
2. Extract some of your favorite of Pat's hald CLUT's there (you probably don't want to extract all of them, since they are large files). You can find a couple of my personal favorites [here](https://github.com/PixlsStuff/Scripts/tree/master/android_filmsim).
3. Download the [filmsim.sh script](https://github.com/PixlsStuff/Scripts/tree/master/android_filmsim) to your downloads directory.
4. Using Termux, copy to the script to a special location so that it can be used as a widget:
   `cp storage/downloads/filmsim.sh $HOME/.shortcuts/filmsim.sh`
5. We can now install a Termux widget by long-pressing the background of your main Android desktop. Choose the single widget, and choose "filmsim.sh" from the list of available scripts to launch with the widget. You should now see a new button on your Android desktop named "filmsim.sh". We are ready to go!

#### Let's get processing!

1. Capture a raw camera image. Use the Open Shot app on your phone, or use your "real" camera. 
2. If you used an external camera, mount the SD card, or otherwise transfer the raw file of your image to your phone.
3. Start the "filmsim.sh" script by tapping on the Termux widget icon you created for it in the instructions above. A Termux session will open, and you will be greeted with a series of pop up dialogs to guide you through the operations.
4. In the first popup dialog, enter the extension of the raw file you will load. For example, enter ".dng" for a raw file in the Adobe DNG format, or ".orf" for a raw file in the Olympus raw format. Don't leave off the "." Tap "Okay" to proceed to the next step.
5. In the next pop up dialog, navigate to the location of the raw file you want to process. If you use Open Camera, this will be in `/dcim/OpenCamera/`. Note that you can also pull a file directly from a mounted SD card or other connected external storage device. Tap "Okay" to proceed to the next step.
6. In the next pop up dialog, navigate to the hald-CLUT file you want to use to process the colors in your raw file. This could also be on an external drive. Tap "Okay" to proceed to the next step.
7. In the final pop up dialog, enter the full name of the processed output file created from your raw image. This should have the appropriate file extension. For example, enter "my_processed_image.jpg" to save out a JPEG, or "my_processed_image.png" to save out a PNG. You can enter any common image file format. Tap "Okay" to start the image processing operation.
8. Be patient while the program works. If you raw file is large and your phone not so great, this could take a while.
9. When the operation is done, it will ask you to "Press any key to exit". When you do so, the Termux session will terminate. You can find your image in the `/dcim/Camera` directory. It should also now show up in your gallery app.

*NOTE: PERHAPS ADD A YOUTUBE VIDEO?*

#### Code:

If you want to see how the sausage is made, here's the code from filmsim.sh:

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


#### Notes:

1. Dcraw can process pretty much any kind of camera raw file. So you can process any raw file you want. Just tell it the proper file extension when it asks you too. (e.g., .orf for Olympus raw files). 
2. The file picker dialog produced by Termux-API also alloys access to the SD card or external OTG storage. For me, this means I can process .orf raw files from my Olympus OM-D directly from an OTG card reader plugged into the phone. 
3. This makes for a pretty powerful mobile photo studio to go from camera raw to processed JPEG, and then upload to social media with your phone...

#### Examples:

Here is a link to a [sample .dng raw image](https://github.com/PixlsStuff/Scripts/blob/master/android_filmsim/Sample_Image/IMG_20170114_162311.dng) captured with my Nexus 5x phone and Open Camera.

Here's what the image looked like straight out of the camera:

![SOOC](https://raw.githubusercontent.com/PixlsStuff/Scripts/master/android_filmsim/Sample_Image/IMG_20170114_162311.jpg)

Here's what it looks like with a Kodak Vista hald-CLUT applied:

![Vista](https://raw.githubusercontent.com/PixlsStuff/Scripts/master/android_filmsim/Sample_Image/IMG_20170114_162311_Vista.jpg)
 