# curve-my-gcode
A Matlab script to curve a planar G-code around an axis with a given radius.

Author : Jean-François Chauvette
jean-francois.chauvette@polymtl.ca

inspired and adapted from : 
G. Zhao, G. Ma, J. Feng, and W. Xiao, “Nonplanar slicing and path generation methods for robotic additive manufacturing,” The International Journal of Advanced Manufacturing Technology, vol. 96, no. 9–12, pp. 3149–3159, Jun. 2018, doi: 10.1007/s00170-018-1772-9.

## Basic usage
There are two ways to use this code: 

Case #1. You have modeled a curved part in a CAD software and you want to print it according to it's base radius (the base radius is the biggest radius of the part, generally located at the part's base, which will be laying on top of the printing bed, i.e. the *first layer radius*). You just closed Catia and basically have not sliced any G-code yet. *For this case, go to Step 1*

or

Case #2. You want to curve an already flat G-code, which probably come from the slicing of a flat part. *For this case, go to Step 2*

###**Step 1 : Obtain a flat G-code**
* Before running the Matlab code, you need to have modeled a part which contains a certain curved surface that you want to print according to the base radius (radius at the part's base or first layer radius) and have exported the .STL file, ready for import in Simplify3D.
* Run script "Step01_main_flatten.m" to flatten the STL according to the base radius. Follow the console instructions.
* Slice your flatten part in Simplify3D as you would usually do in order to obtain a G-code file. The G-code will be a flat G-code and you will find yourself in Case #2. Go to Step 2 to continue.

###**Step 2 : Curve a flat G-code**
* At this point, you have a flat G-code file.
* Run script "Step02_main_curve.m" to curve the G-code according to a given radius. Follow the console instructions.
  * If you did Step 1 before Step 2, you can specify that you already flattened an STL prior to generating the G-code so that you don't have to calculate the base radius by yourself.
  * If you started from Step 2, you need to specify the radius at which you want the base/first layer radius to be curved at.
* You can specify a positive or a negative radius:
  * Positive radius will curve the part in the +Z direction.
  * Negative radius will curve the part in the -Z direction.
  * *The part will always be curved by starting from the first layer, so you might want to slice your flattened G-code with a +Z offset if you choose to curve your G-code in the -Z direction. **Otherwise, the part will collision the printing bed and you might damage your printer**.
  
**/!\ Always re-import your curved G-code into Simplify3D to verify the resulting G-code /!\**
