# curve-my-gcode
A Matlab script to curve a planar G-code around an axis with a given radius.

Author : Jean-François Chauvette

jean-francois.chauvette@polymtl.ca

inspired and adapted from : 

G. Zhao, G. Ma, J. Feng, and W. Xiao, “Nonplanar slicing and path generation methods for robotic additive manufacturing,” The International Journal of Advanced Manufacturing Technology, vol. 96, no. 9–12, pp. 3149–3159, Jun. 2018, doi: 10.1007/s00170-018-1772-9.

## Basic usage
There are two ways to use this code: 

Case #1 : You have modeled a curved part in a CAD software and you want to print it according to it's base radius (the base radius is the biggest radius of the part, generally located at the part's base, which will be laying on top of the printing bed, i.e. the *first layer radius*). You just closed Catia and basically have not sliced any G-code yet. *For this case, go to Step 1*
Notes on the source 3D model:
* The STL origin must be under the part. The curvature of the part must be around the X and/or Y axis.
![Reference Frame example](/examples/ReferenceFrame.PNG)

Case #2 : You want to curve an already flat G-code, which probably comes from the slicing of a flat part. *For this case, go to Step 2*

**Step 1 : Obtain a flat G-code**
* Before running the Matlab code, you need to have modeled a part which contains a certain curved surface that you want to print according to the base radius (radius at the part's base or first layer radius) and have exported the .STL file in **ASCII format**, ready for import in Simplify3D. A .STL file in binary format will not work with the Matlab code.
* Instead of rushing directly into Simplify3D, run script "Step01_main_flatten.m" to flatten the STL according to the base radius. Follow the console instructions. You will obtain a flat STL of your part.
* Import your flat part in Simplify3D. 
	If using the Fanuc Robot, position the part flat on the print bed centered along the X and Y axis. 
	If using the Gantry Aerotech, position the part flat on the print bed at the origin (X=0 and Y=0)
* Slice your flatten part in Simplify3D as you would usually do in order to obtain a G-code file. The G-code will be a flat G-code and you will find yourself in Case #2. Go to Step 2 to continue.

**Step 2 : Curve a flat G-code**
* At this point, you have a flat G-code file.
* Run script `Step02_main_curve.m` to curve the G-code according to a given radius. Follow the console instructions.
  * If you did Step 1 before Step 2, follow to instructions to specify that you already flattened an STL prior to generating the G-code so that you don't have to calculate the base radius by yourself.
  * If you started from Step 2, you need to specify the radius at which you want the base/first layer radius to be curved at.
* You can specify a positive or a negative radius:
  * Positive radius will curve the part toward the +Z direction.
  * Negative radius will curve the part toward the -Z direction.
  * The part will always be curved by starting from the first layer, so you might want to slice your flattened G-code with a +Z offset if you choose to curve your G-code in the -Z direction. **Otherwise, the G-code will be in collision with the printing bed and you might damage your printer**.
  
**Always re-import your curved G-code into Simplify3D to verify the resulting G-code !**

## Limitations / to-do
`Step01_main_flatten.m` 
* Is only able to import ASCII STL format. It cannot read Binary STL format.
* Only flattens around the Y axis. So you need to position your datum reference system accordingly before exporting the STL from your CAD software.
* Only calculates positif radius (downward curvature will be flatten torward the -Z direction, so it will be curved even more!)
