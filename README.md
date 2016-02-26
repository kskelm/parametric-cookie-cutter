# Parametric Cookie Cutter (PCC)
*** 

Parametric Cookie Cutter is (c) by KevinKelm triggur@gmail.com

Parametric Cookie Cutter is licensed under a Creative Commons Attribution 4.0 International License.

This package contains code to turn DXF-based outlines into cookie cutters for 3D printers.

## Versions ##
* 1.0.0 -- first release
* 1.0.1 -- added filled imprints

## Usage ##

Parametric Cookie Cutter (PCC) is intended to be used interactively by
fiddling with global variables in cookie_cutter.scad via OpenSCAD.  It may work with the command line, but I have no idea.

PCC generates shapes with the following features:
* A cutting edge that is by default 15mm deep.
* An imprint edge that is by default 10mm deep.
* A flange that sticks out from the top of the cutting edges and also extends toward the center a small distance.  This is for rigidity and to provide an easy surface to push on
* Optional strips going in both directions to support unconnected edges and internal peninsulas.

Broadly speaking, there are several categories of tunable
variables in this package.

### DXF files ###
PCC allows you to name up to two DXF files containing the outlines of the cookie cutter patterns:
* **cutFilename:**  This is the path to the DXF file containing the shape of the cookie cutter itself.  It's okay if curved edges have a low segment count; cookies are low resolution anyway.
* **imprintFilename:** This optional DXF file is used to create a shallower "imprint" patter, allowing features to be baked into the center.  In the included examples, the eyes and mouth of the smiley face and the trefoil of the radiation symbol are imprints.  If you don't want an imprint, set this value to an empty string.

OpenSCAD can import simple DXF files, but it can handle only a small subset of the kinds of geometry people commonly use in DXF files.  I have had no luck getting it to import anything with curves; they either come out as line segments or the file fails to load entirely.

The easiest way to handle this is to have your software output your shape to an EPS file and then convert that file to DXF format.  There are free online services like https://cloudconvert.com/eps-to-dxf to do this.  The resulting DXF file will probably work with PCC.

Note that when you see your shape in the 3D viewer, it will appear backwards; the design is flipped so the upper flange can be printed flat.

### Coordinates/Units ###
Now this is a hot mess.  A lot of people work in AutoCAD, which may be using inches, feet, millimeters, or light years.  In any case, DXF doesn't support units, so OpenSCAD has no way of knowing what the original intent was. As far as I know, most 3D printers think in millimeters, so that's my assumption in this package.

To compensate, I added a scaling variable so nobody has to go back to the original editor and go through the hassle of several format conversions. This scales only the DXF file contents, not the features of the flanges and such:
* **scaleFactor:** This is a multiplier used to mash around the geometry of the imported DXF files.  This will almost certainly be an iterative process to see if you like the size of your object in Cura or whatever you're using.

Your object is expected to be near the origin.  It must be a 2D path.  Shapes don't need to be closed. The work area is defined as about 1 meter square, specifically for the creation of support strips (see below).  1 meter is a hell of a cookie, but I'm not judging if you want it to be larger.  There's a constant in the file called **workDiameter** to declare this.

### Tuneables ###
+ ***Flanges***.  A flange is printed to strengthen the edges and provide a surface to press on to push the cutter into the dough.  It's a little thicker than the edges. It sticks out, and it also sticks into the shape a little as well.  Sometimes playing with the flange sizes gives you the ability to skip the support strips, but it's a matter of balance and personal preference.  The flanges are controlled by the following variables:
  - **cutFlangeRadius:** This is the distance in mm that the flange sticks out from the cut edges.  It also sticks into the shape by a fraction of the distance  (default 7).
  - **imprintFlangeRadius:** This is the radius for imprint flanges (defaults to the value of *cutFlangeRadius*).
 
+ ***Support strips.*** Some shapes have internal floating features (like the smiley face example) or wobbly thin features (like the pi example).  If you use imprints, you'll need to play close attention to this to make sure you have strips that support your internal unconnected edges.  PCC will generate strips as part of the flange, controlled by the following variables:
  - **numSupportStrips:** The number of strips to generate in both directions.  Set this to 0 if you don't want any.  Strips are centered along the origin.  Note that you can keep on incrementing this and see no result if you don't also decrease the spacing (described below).  This is necessary because I fould no convenient means to have OpenSCAD calculate the bounding box of the shape.
  - **supportStripWidth:** The width in mm of each strip (default 10)
  - **supportStripSpacing:** The number of mm between strips, center-to-center (default 50).
  
+ ***Cutting/Imprinting***. There are parameters to control how the edges are generated.  The variables are:
  - **fillImprints:** Set this to true if you want your imprints filled instead of being cutting edges.  If what you want is some mix of filled and not filled, you're going to have to do that yourself when you create the DXF by adding extra stuff inside the boundaries you want filled.  For instance if you wanted to fill in a circle, you could add additional concentric circles inside it and let the imprint blade thickness take care of actually filling the space.
  - **cutDepth:** This is the depth in mm of the edge.  This is a little bit of a misnomer because it's actually the depth of the entire object, including the flange.  The cut depth limits the depth of the cookie that can be cut.  If you want more height to accommodate thicker dough, change this (default 15).
  - **imprintDepth:** Like *cutDepth*, but for the imprint edges (default 10).  Note that the result is affected by the depth of the cookie dough; If the dough is thinner than **cutDepth**, then the imprint depth will be less pronounced.
  - **bladeThickness:** This is the thickness in mm of the cutting and imprint blades (default 1).

***Esoterica***.  The following variables are likely to be of no practical importance:
  - **workDiameter:** This is the area over which support strips are generated.  If your cookies are greater than 1 meter then I guess increase this value. This was only necessary because I couldn't get the OpenSCAD tricks to work that would let me calculate the bounding box of the DXF contents so as to constrain the size of the support strips automatically.
  
## Development ##

Feel free to fork this in github and request pulls.
