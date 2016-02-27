/*
 * Author: Kevin Kelm
 * Email: triggur@gmail.com
 * Date: 2015-02-21
 * Version: 1.0.1
 * License: Creative Commons CC-BY (Attribution)
 *
 */

// 1.0.0 -- first release
// 1.0.1 -- added filled imprints
// 1.0.2 -- made inner flanges an option and defaulted it to false

// NOTE: to play with the example files, scroll down to the
// little commented out blocks further down, and uncomment
// only the one you want to experiment with.
// Sorry in advance for using absolute paths in my filesystem.
// In general, the most frequently changed constants are
// declared near the top of the file and they get more esoteric
// the further down you go.

// ====================================
// Tunable constants:

// This names the DXF file to be used as the cutter outline.
// OpenSCAD's implementation of DXF is missing a lot of
// fairly standard features, so pretty much everything needs
// to be a bunch of straight lines; splines and AutoCAD's
// polyline curves don't work correctly.  In my experience
// the best bet is to go from EPS to DXF; that seems to fix
// the problems I've had.  There's free online converters
// like https://cloudconvert.com/eps-to-dxf that can help
// with this.
// NOTE: In your 3D viewer, the shape will appear backwards
// because the print is upside down to accommodate the
// support flange.
cutFilename = "YOUR CUT FILE GOES HERE.dxf";

// Optionally, this second file can be used to generate
// a shallower "imprint" outline in the middle of the cookie.
// If you don't have such a file, comment this out.
imprintFilename = "YOUR IMPRINT FILE (IF ANY) GOES HERE.dxf";


// DXF has no inherent units. I'm also assuming all 
// printer software sees the world in millimeters.  If your
// software works differently or if your model's units are
// whacky, use this to scale it to mm.  An example
// would be something saved out of AutoCAD in inches.
scaleFactor = 5.5;

// Sometimes you don't want imprint edges, you want imprint
// areas.  Set this to true if you want the imprint regions
// filled as solid stamps.
fillImprints = false;

// This defines how many support strips to create through
// the middle of the cutter base in both directions.  These
// strips provider structure to support any wobbly peninsulas
// or floating imprints in the middle of the cutter. Also,
// you'll need to adjust these parameters if your shape has
// islands that the default 50mm spacing doesn't hit.
numSupportStrips = 0;
// This is the width of a support strip.  All measurements are in mm.
supportStripWidth = 10;
// This is how far apart strips are, center-to-center.
supportStripSpacing = 50;

// This represents how deep the cutter edge goes (but actually
// this includes the flange, so it's really the depth of the whole
// object).
cutDepth = 15;
// This is how deep the imprint edge goes (ditto).
imprintDepth = 10;
// This is how thick the cut blades are.
bladeThickness = 1.5;

// This is how thick the flange base should be.
flangeThickness = 2;
// And this is the radius of flange coming out from
// the edge. A small flange extends inward as well.
cutFlangeRadius = 7;
imprintFlangeRadius = cutFlangeRadius;
// Whether flanges should extend inside the perimeters or not.
// It's nice for stability, but it can also interfere with getting
// the dough out once the cookie is cut.
innerFlange = false;

// This represents the work area. This only matters
// to the extents of the internal support structure.
// 1000 mm is one hell of a cookie, but I'm not
// judging. Make this bigger if you need to.
workDiameter = 1000;



// =================================================
// Examples.  Uncomment only one of these to get
// that example file.  You'll have to modify the
// absolute paths.  Sorry about that.
// =================================================

// ======================
// smiley face settings
/*
cutFilename = "/Users/triggur/Projects/parametric-cookie-cutter/smiley_face_cut.dxf";
imprintFilename = "/Users/triggur/Projects/parametric-cookie-cutter/smiley_face_imprint.dxf";
scaleFactor = 5.5;
numSupportStrips = 2;
supportStripWidth = 5;
supportStripSpacing = 30;
imprintDepth = 10;
fillImprints = true;
imprintFlangeRadius = 0;
*/

// ======================
// round trefoil settings
/*
cutFilename = "/Users/triggur/Projects/parametric-cookie-cutter/round_trefoil.dxf";
imprintFilename = "";
scaleFactor = 5;
numSupportStrips = 0;
*/


// ======================
// radiation settings
/*
cutFilename = "/Users/triggur/Projects/parametric-cookie-cutter/radioactive_cut.dxf";
imprintFilename = "/Users/triggur/Projects/Cookie Cutters/radioactive_imprint.dxf";
scaleFactor = 9;
numSupportStrips = 1;
supportStripWidth = 6;
imprintDepth = 9;
imprintFlangeRadius = 0;
cutFlangeRadius = 3.5;
*/


// ======================
// pi settings
/*
cutFilename = "/Users/triggur/Projects/parametric-cookie-cutter/pi.dxf";
imprintFilename = "";
scaleFactor = 5;
numSupportStrips = 0;
cutFlangeRadius = 6;
*/


// =================================================
// =================================================

cookieCutter();

/*
 * Given a DXF file representing a cut outline and
 * an optional file representing an imprint outline,
 * generate a cookie cutter object.  If "numSupportStrips"
 * is non-zero, also generate a grid inside the shape
 * for strength and to hold internal pieces in the right
 * place.
 */
module cookieCutter() {
  // cut edges offset to the outside and imprint edges offset to the inside.
  shellAndFlange(cutFilename, cutDepth, false, cutFlangeRadius, false );
  if (imprintFilename) {
    shellAndFlange(imprintFilename, imprintDepth, true, imprintFlangeRadius, fillImprints );
  } // if

  // create a grid of strips to support internal structures that's
  // bounded on the outside by the cookie cutter shape.
  if (numSupportStrips) {
    intersection() {
      union() {
          
        // x-strips
        stripStartX = -supportStripSpacing / 2 * (numSupportStrips - 1) - supportStripWidth / 2;
        for (stripNum = [0: numSupportStrips - 1]) {
          translate([stripStartX + stripNum * supportStripSpacing, -workDiameter / 2, 0]) {
            cube([supportStripWidth, workDiameter, flangeThickness]);
          } // translate
        } // for
        
        // y-strips
        stripStartY = -supportStripSpacing / 2 * (numSupportStrips - 1) - supportStripWidth / 2;
        for (stripNum = [0: numSupportStrips - 1]) {
          translate([-workDiameter / 2, stripStartY + stripNum * supportStripSpacing, -0]) {
            cube([workDiameter, supportStripWidth, flangeThickness]);
          } // translate
        } // for

      } // union
      linear_extrude(height = flangeThickness) {
        shape( cutFilename );
      } // extrude
    } // difference 

  } // if
} // cookieCutter

/*
 * convenience module because I load the same DXF files over and over
 * again.
 */
module shape( fileame ) {
  scale( [ scaleFactor, scaleFactor, 1] ) {
    mirror([1, 0, 0]) {
      import( fileame );
    } // mirror
  } // scale
} // shape

/*
 * Given a DXF file, create a cutter shell out
 * of it and then a flange used to strengthen
 * it and provider a surface to help push
 * it into the dough.
 */
module shellAndFlange(filename, depth, insideOffset, flangeRadius, filled ) {
  // make the shell outline
  linear_extrude(height = depth) {
    if( insideOffset ) {
      difference() {
        shape( filename );
        if( filled ) {
          cube( [0,0,0] );
        } else {
          offset(r = -bladeThickness ) {
            shape( filename );
          } // offset
        } // if-else
      } //difference
    } else {
      difference() {
        offset(r = bladeThickness ) {
          shape( filename );
        } // offset
        shape( filename );
      } // difference
    } // if-else
  } // extrude

  // make the flange around it 
  linear_extrude(height = flangeThickness ) {
    difference() {
      offset(r = flangeRadius) {
        shape( filename );
      } // offset
      if( innerFlange ) {
        offset(r = -flangeRadius / 3) {
          shape( filename );
        } // offset
      } else {
        shape( filename );
      } // if-else
    } // difference
  } // extrude

} // shellAndFlange