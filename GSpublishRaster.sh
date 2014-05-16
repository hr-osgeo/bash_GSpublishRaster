#!/bin/bash

#-------------------------------------------------------------------------------
# Name:        GSpublishRaster
# Purpose:
#
# Author:      Darko Boto darko.boto@gmail.com
# Description: Get all geotiff from current directory and publish in to Geoserver WMS service
# Created:     10.02.2014
# Copyright:   (c) darko.boto 2014
# Licence:     MIT
#-------------------------------------------------------------------------------

# Geoserver REST url
rest_url="http://localhost:8080/geoserver-2.3.0/rest/workspaces/"
username=admin
password=geoserver
raster_srs=EPSG:3765

# current directory name will be workspace and WMS name
workspace=${PWD##*/}
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "\n"
echo "---- CREATE WORKSPACE-a " $workspace " ----"
echo "\n"

curl -v -u $username:$password -XPOST -H "Content-type: text/xml" \
   -d "<workspace><name>"$workspace"</name></workspace>"  \
   $rest_url

# For all geotif in directory create geoserver store and set store properties
for raster in *.tif
do
        raster_name="${raster%.*}"

	echo "\n"
        echo "---- STORE-a REGISTRATION FOR COVERAGE " $raster " ----"
	echo "\n"

        curl -u $username:$password -v -XPOST -H 'Content-type: text/xml' \
                -d "<coverageStore> \
                        <name>$raster_name</name> \
                        <enabled>true</enabled> \
                        <type>GeoTIFF</type> \
                        <url>$DIR/$raster</url> \
                        <workspace>$workspace</workspace> \
                </coverageStore>" \
                $rest_url$workspace/coveragestores?configure=all

        echo "\n"
	echo "---- INITIALIZE LAYER-a " $raster_name " ----"
	echo "\n"

        curl -u $username:$password -v -XPOST -H 'Content-type: text/xml' \
                -d "<coverage> \
                        <name>$raster_name</name> \
                        <title>$raster_name</title> \
                        <nativeCRS>$raster_sr</nativeCRS>
                        <srs>$raster_srs</srs> \
                </coverage>" \
                $rest_url$workspace/coveragestores/$raster_name/coverages
done

echo "\n"
echo "---- THE END ----"
echo "\n"
