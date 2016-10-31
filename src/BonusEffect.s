	PRESERVE8

	AREA	BonusEffect, CODE, READONLY
	IMPORT	main
	IMPORT	getPicAddr
	IMPORT	putPic
	IMPORT	getPicWidth
	IMPORT	getPicHeight
	EXPORT	start

start

	BL	getPicAddr			; 	load the start address of the image in R4
	MOV	R4, R0				;
	BL	getPicHeight		; 	load the height of the image (rows) in R5
	MOV	R5, R0				;
	BL	getPicWidth			; 	load the width of the image (columns) in R6
	MOV	R6, R0				;

	LDR R9, =0xA1800000		;	int[] copyAddress;
	MOV	R10, #0		 		;	int i = 0;
	MOV	R8,	#0		 		;	int j = 0;
	MOV	R3,	R6				;	int N = picture.width;
							;
copyForLoopPixelj			;	
	CMP	R8,	R5				;	while(j<pictureHeight)
	BEQ	endCopyForLoopPixelj;  	{
	LDR R10, =0				;		i = 0;
copyForLoopPixeli			;
	CMP	R10,	R6			;		while(i<pictureWidth)
	BEQ	endCopyForLoopi		;		{
	MOV	R0,	R4				;		
	MOV R1, R10				;
	MOV R2, R8				;
	MOV R3, R6				;
	BL	getPixel			;	 		temp = getPixel(startAddress, i, j, pictureWidth);
	MUL	R7,	R6,	R8			;
	ADD	R7,	R7,	R10			;
	STR	R0,	[R9, R7,LSL	#2]	;	 		copyAddress[i][j] = temp;
	ADD	R10,	R10,	#1	;	  		i++;
	B copyForLoopPixeli 	;		 }
endCopyForLoopi				;
	ADD	R8,	R8,	#1			;		 j++;
	B	copyForLoopPixelj	;	 }
endCopyForLoopPixelj		;

	MOV	R10, #0		 		;    i = 0;
	MOV	R8,	#0		 		;	 j = 0;
	MOV R7, #5				;	 radius = 5;

blurForLoopPixelj			;	 BLURRING THE IMAGE
	CMP	R8,	R5				;	 while(j<pictureHeight)
	BEQ	endBlurForLoopPixelj; 	 {
	LDR R10, =0				;	 	i = 0;	
blurForLoopPixeli			;
	CMP	R10,	R6			;		while(i<pictureWidth)
	BEQ	endBlurForLoopi		;  		{
	MOV	R0,	R10				;			
	MOV R1, R8				;
	MOV R2, R7				;
	MOV R3, R9				;
	STR	R6, [sp, #-4]!		;
	BL	getAverageRed		;	 		temp = getAverageRed(i,j,radius,startAddress,pictureWidth);
	ADD sp, sp, #4			;
	STR	R0, [sp, #-4]!		;
	MOV	R0,	R9				;		
	MOV R1, R10				;
	MOV R2, R8				;
	MOV R3, R6				;
	BL setPixelR			;	 		setRed(startAddress,i,j,pictureWidth,temp);
	ADD sp, sp, #4			;
	MOV	R0,	R10				;		
	MOV R1, R8				;
	MOV R2, R7				;
	MOV R3, R9				;
	STR	R6, [sp, #-4]!		;
	BL	getAverageGreen		;	 		temp = getAverageGreen(i,j,radius,startAddress,pictureWidth);
	ADD sp, sp, #4			;
	STR	R0, [sp, #-4]!	    ;
	MOV	R0,	R9				;		
	MOV R1, R10				;
	MOV R2, R8				;
	MOV R3, R6				;
	BL setPixelG			;	 		setGreen(startAddress,i,j,pictureWidth,temp);
	ADD sp, sp, #4			;
	MOV	R0,	R10				;		
	MOV R1, R8				;
	MOV R2, R7				;
	MOV R3, R9				;
	STR	R6, [sp, #-4]!		;
	BL	getAverageBlue		;	 		temp = getAverageBlue(i,j,radius,startAddress,pictureWidth);
	ADD sp, sp, #4			;
	STR	R0, [sp, #-4]!		;
	MOV	R0,	R9				;		
	MOV R1, R10				;
	MOV R2, R8				;
	MOV R3, R6				;
	BL setPixelB			;	 		setBlue(startAddress,i,j,pictureWidth,temp);
	ADD sp, sp, #4		    ;
	ADD	R10,	R10,	#1	;	 		i++;
	B blurForLoopPixeli 	; 	 	} 
endBlurForLoopi				;
	ADD	R8,	R8,	#1			;	 	j++;
	B	blurForLoopPixelj	;
endBlurForLoopPixelj		; 	}

	MOV	R11, #0		 		;    i = 0;
	MOV	R8,	#0		 		;	 j = 0;

setupForLoopPixelj			;  CHANGING THE IMAGE TO NEGATIVE - ADDING IT TO THE BLUR - GRAYSCALING THAT - AND CREATING A BLANK CANVAS
	CMP	R8,	R5				;  while(j<pictureHeight)
	BEQ	endSetupForLoopPixelj; { 
	LDR R11, =0				;		i = 0;
setupForLoopPixeli			;
	CMP	R11,	R6			;  		while(i<pictureWidth)
	BEQ	endSetupForLoopi	;		{
	
	MOV	R0,	R9				;		
	MOV R1, R11				;
	MOV R2, R8				;
	MOV R3, R6				;
	BL	getPixel			;		 	temp = getPixel(edges, i, j, pictureWidth);
	MOV R10, R0				;  			tempTwo = temp;
		
	MOV	R0,	R4				;		
	MOV R1, R11				;
	MOV R2, R8				;
	MOV R3, R6				;
	BL	getPixel			;			temp = getPixel(canvas, i, j, pictureWidth);
		
	BL changeToNeg			;			temp = changeToNegative(temp);
	MOV R1, R0				;
	MOV R0, R10				;
	BL addNegToBlur			;			temp = addNegToBlur(temp, tempTwo);
	BL grayscale			;			temp = grayscale(temp);

	MUL	R7,	R6,	R8			;
	ADD	R7,	R7,	R11			;
	STR	R0,	[R9, R7,LSL	#2]	;			edges[i][j] = temp;

	LDR R0, =0xFFFFFF		;
	MUL	R7,	R6,	R8			;
	ADD	R7,	R7,	R11			;
	STR	R0,	[R4, R7,LSL	#2]	;			canvas[i][j] = Color.WHITE;

	ADD	R11,	R11,	#1	;			i++;
	B setupForLoopPixeli 	;
endSetupForLoopi			;		}
	ADD	R8,	R8,	#1			;		j++;
	B	setupForLoopPixelj  ;  		
endSetupForLoopPixelj		;  }
	BL putPic

forever
	LDR R0, =0				;
	LDR R1, =0				;
	MOV R2, R4				;
	MOV	R3, R6				;
	STR	R9, [sp, #-4]!		;
	STR R1, [sp, #-4]!		;
	BL sketchImage			; sketchImage(0,0,canvas,pictureWidth,edges,0);	
	ADD sp, sp, #4			;
	ADD sp, sp, #4			; 
	MOV R8, #0
blankingForLoopPixelj
	CMP	R8,	R5				;  while(j<pictureHeight)
	BEQ	endBlankingForLoopPixelj; { 
	LDR R11, =0				;		i = 0;
blankingForLoopPixeli			;
	CMP	R11,	R6			;  		while(i<pictureWidth)
	BEQ	endBlankingForLoopi	;		{
	
	LDR R0, =0xFFFFFF		;
	MUL	R7,	R6,	R8			;
	ADD	R7,	R7,	R11			;
	STR	R0,	[R4, R7,LSL	#2]	;			canvas[i][j] = Color.WHITE;

	ADD	R11,	R11,	#1	;			i++;
	B blankingForLoopPixeli 	;
endBlankingForLoopi			;		}
	ADD	R8,	R8,	#1			;		j++;
	B	blankingForLoopPixelj  ;  		
endBlankingForLoopPixelj		;  }
	BL putPic
	B forever
	B cool					;

	;GET PIXEL VALUE [i,j]					
	;PARAMETERS: R0 start address				
	;			 R1 i								
	;			 R2 j									
	;			 R3 picture width							
	;RETURNS:	 R0 pixel value									
getPixel						;									
	STMFD	sp!,	{R4,LR}		;
	MUL	R4,	R3,	R2				;
	ADD	R4,	R4,	R1				;
	LDR	R0,	[R0,	R4,	LSL	#2]	;
	LDMFD	sp!,	{R4,pc}		;

	;SKETCH	IMAGE				
	;PARAMETERS: R0 	i				
	;			 R1 	j
	;			 R2 	blankCanvasStartAddress
	;			 R3 	picture width
	;			 R12+4  edgesStartAddress
	;			 R12 	pixelsDrawnSinceLastDisplayUpdate
	;FUNCTION:   TAKES IN AN IMAGE AND SKETCHES IT							
	;RETURNS:	 void
sketchImage						; void sketch(int i, int j, int[][] blankCanvas, int[][] edges, int pixelsDrawnSinceLastDisplayUpdate)
	STMFD sp!, {R4-R12,LR}		; {
	MOV R5, R0					; 	int i = parameter0
	MOV R6, R1					; 	int j = parameter1;
	MOV R10, R2					; 	int[][] blankCanvas = parameter2;
	MOV	R8,	R3					; 	int pictureWidth = parameter3;
	ADD R7, R5, #1				; 	int maxPixeli = i + 1; 
	ADD R12, R6, #1				; 	int maxPixelj = j + radius
drawPixel						;
	MUL	R11,	R6,	R8			;	
	ADD	R11,	R11,	R5		;	
	STR	R0,	[R10, R11,LSL	#2]	;	blankCanvas[i][j] = edges[i][j];
	LDR R9, =1					; 	radius = 1;
	ADD R7, R5, R9				;	maxPixeli = i + 1;  
	ADD R12, R6, R9				;	maxPixelj = j + 1;
	SUB R5, R5, #1				; 	int i -= 1;
	SUB R6, R6, #1				; 	int j -= 1;
	LDR R1, [sp, #40]			;
	ADD R1, R1, #1				;	pixelsDrawnSinceLastDisplayUpdate++;
	CMP R1, #80					;	if( pixelsDrawnSinceLastDisplayUpdate >= 40)									<=======INPUT HOW OFTEN BL PUTPIC SUBROUTINE IS CALLED
	BLT dontDisplay				;	{
	BL	putPic					;		updateDisplay();
	LDR R1, =0 					;		pixelsDrawnSinceLastDisplayUpdate = 0;
dontDisplay						;	}
	STR R1, [sp, #40]			;
moveRight						;   while(edgeNotFound)
	CMP R9, #300				;   {
	BGT finishedSketch			;
	CMP R5, R7					;		while(i <= maxPixeli)
	BGT endMoveRight			;		{
	CMP R5, #0					;	   		if(i >= 0
	BLT notOnImageRight			;	   		  &&
	CMP R6, #0					;	   			 j >= 0
	BLT notOnImageRight			;
	MUL	R11,	R8,	R6			;	
	ADD	R11,	R11,	R5		;		
	LDR	R0,	[R10,	R11,LSL	#2]	;				  	&&
	LDR R1, =0xFFFFFF			;
	CMP R0, R1					;   					edges[i][j] != Color.WHITE)
	BNE alreadyDrawnRight		;			{
	MUL R11,	R8, R6			;
	ADD	R11,	R11,	R5		;
	LDR	R3,	[SP, #44]			; 	
	LDR	R0,	[R3,	R11,LSL	#2]	;
	LDR R1, =0xEEEEEE			;
	CMP R0, R1					;   			if(edges[i][j] == anEdge) 
	BLT drawPixel				;	   	  		{  drawPixel(blankCanvas[i][j]);}
alreadyDrawnRight				;			
notOnImageRight					;			}
	ADD	R5,	R5,	#1				; 			i++;
	B 	moveRight				;		}
endMoveRight					;
	SUB R5, R5, #1				;		i--;
moveDown						;
	CMP R6, R12					;		while(j <= maxPixelj)
	BGT endMoveDown				;		{
	CMP R5, #0					;			if(i >= 0
	BLT notOnImageDown			;			  &&
	CMP R6, #0					;				j >= 0
	BLT notOnImageDown			;
	MUL	R11,	R8,	R6			;
	ADD	R11,	R11,	R5		;
	LDR	R0,	[R10,	R11,LSL	#2]	;				 	&&
	LDR R1, =0xFFFFFF			;
	CMP R0, R1					;   					edges[i][j] != Color.WHITE)
	BNE alreadyDrawnDown		;			{
	MUL	R11,	R8,	R6			;
	ADD	R11,	R11,	R5		;
	LDR	R3,	[SP, #44]			; 	
	LDR	R0,	[R3,	R11,LSL	#2]	;
	LDR R1, =0xEEEEEE			;
	CMP R0, R1					;   			if(edges[i][j] == anEdge)
	BLT drawPixel				;	   	  		{  drawPixel(blankCanvas[i][j]);}
alreadyDrawnDown				;
notOnImageDown					;			}
	ADD	R6,	R6,	#1				; 			j++;
	B 	moveDown				;		}
endMoveDown						;
	SUB R6, R6, #1
	SUB R7, R7, R9				;
	SUB R7, R7, R9				;
moveLeft						;
	CMP R5, R7					;		while(i >= maxPixeli)
	BLT endMoveLeft				;		{
	CMP R5, #0					;			if(i >= 0
	BLT notOnImageLeft			;				&&
	CMP R6, #0					;					j >= 0
	BLT notOnImageLeft			;
	MUL	R11,	R8,	R6			;
	ADD	R11,	R11,	R5		;
	LDR	R0,	[R10,	R11,LSL	#2]	;				  	&&
	LDR R1, =0xFFFFFF			;
	CMP R0, R1					;   					edges[i][j] != Color.WHITE)
	BNE alreadyDrawnLeft		;			{
	MUL	R11,	R8,	R6			;
	ADD	R11,	R11,	R5		;
	LDR	R3,	[SP, #44]			; 	
	LDR	R0,	[R3,	R11,LSL	#2]	;
	LDR R1, =0xEEEEEE			;
	CMP R0, R1					;   			if(edges[i][j] == anEdge)
	BLT drawPixel				;	   	  		{  drawPixel(blankCanvas[i][j]);}
alreadyDrawnLeft				;	   		}
notOnImageLeft					;
	SUB	R5,	R5,	#1				; 	   		i--;
	B 	moveLeft				;		}
endMoveLeft						;
	ADD R5, R5, #1				;		i++;
	SUB R12, R12, R9			;		maxPixeli -= radius;
	SUB R12, R12, R9			;		maxPixeli -= radius;
moveUp							;
	CMP R6, R12					;		while(j >= maxPixelj)
	BLT endMoveUp				;		{
	CMP R5, #0					;			if(i >= 0
	BLT notOnImageUp			;				&&
	CMP R6, #0					;					j >= 0
	BLT notOnImageUp			;
	MUL	R11,	R8,	R6			;
	ADD	R11,	R11,	R5		;
	LDR	R0,	[R10,	R11,LSL	#2]	;				  	  &&
	LDR R1, =0xFFFFFF			;
	CMP R0, R1					;   					edges[i][j] != Color.WHITE)
	BNE alreadyDrawnUp			;
	MUL	R11,	R8,	R6			;		 	{
	ADD	R11,	R11,	R5		;
	LDR	R3,	[SP, #44]			; 	
	LDR	R0,	[R3,	R11,LSL	#2]	;
	LDR R1, =0xEEEEEE			;		 	
	CMP R0, R1					;   	 		if(edges[i][j] == anEdge)
	BLT drawPixel				;	   	  		{  drawPixel(blankCanvas[i][j]);}  
alreadyDrawnUp					;		 	}
notOnImageUp					;
	SUB	R6,	R6,	#1				; 		 	j--;
	B 	moveUp					;		}
endMoveUp						;
	SUB R5, R5, #1				;		i--;
	ADD R7, R7, R9				;		maxPixeli += radius;
	ADD R7, R7, R9				;		maxPixeli += radius;
	ADD R12, R12, R9 			;		maxPixelj += radius;
	ADD R12, R12, R9			;		maxPixelj += radius;
	ADD R9, R9, #2				;		radius += 2;
	ADD R7, R7, #1				;		maxPixeli++;
	ADD R12, R12, #1			;		maxPixelj++;
	B	moveRight				; 	}	
finishedSketch					;
	LDMFD sp!,	{R4-R12,PC}		;}

	;GRAYSCALE 					
	;PARAMETERS: R0 PIXEL VALUE
	;FUNCTION:   CONVERTS A PIXEL TO GRAYSCALE							
	;RETURNS:	 R0 GRAYSCALE PIXEL
grayscale					  		  ;	int grayscale(int pixelValue){
	STMFD sp!, {R4-R10,LR}			  ;	
	LDR R4, =0						  ;	int index = 0;
	LDR R5,	=0xFF					  ;	partOfColorBeingDealtWith = 255;
	LDR R7, =0						  ;	AmountOfBitsColorBeingDealtWithIsOffBy = 0;
	LDR R10, =3						  ; numberOfComponents = 3;
	LDR R9, =0						  ; totalOfAddedComponents = 0;
forLoop1GS				  	  		  ;	
	CMP R4, #3						  ;	while(index<3)
	BGE endForLoop1GS	  	  		  ;	{
	MOV R6, R0						  ;		tempPixelValue = pixelValue2;
	AND R6,	R6, R5					  ;		tempPixelValue = tempPixelValue1.partOfColorBeingDealtWith;
	LSR R6, R7						  ;		tempPixelValue1 = tempPixelValue1/(AmountOfBitsColorBeingDealtWithIsOffBy^2);
	BIC R0, R5						  ;		actualColorValue -= actualColorValue.partOfColorBeingDealtWith;
	CMP R6, #255					  ;		if(tempColorValue>255)
	BLT	lessThanTwoFiveFiveGS		  ;		{
	LDR R6, =255					  ;			tempColorValue = 255;
lessThanTwoFiveFiveGS	  			  ;		}
	CMP R6, #0						  ;		else if(tempColorValue<0)
	BGT	addItUpGS					  ;		{
	LDR R6, =0						  ;			tempColorValue = 0;
addItUpGS							  ;		}
	ADD R9, R6, R9					  ;		totalOfComponents += tempColorValue;
	LSL R5, #8						  ;		partOfColorBeingDealtWith = partOfColorBeingDealtWith*2^8;
	ADD R7, #8						  ;		AmountOfBitsColorBeingDealtWithIsOffBy += 8;
	ADD R4, R4, #1					  ;		index ++;
	B forLoop1GS		  			  ;	 }
endForLoop1GS					  	  ;
	MOV R0, R9						  ;
	MOV R1, R10						  ;
	BL divide						  ;	int averageComponentValue = totalOfComponents/numberOfComponents
	MOV R9, R0						  ;
	LDR R0, =0						  ;
	LDR R4, =0						  ;	int index = 0;
	LDR R5,	=0xFF					  ;	partOfColorBeingDealtWith = 255;
	LDR R7, =0						  ;	AmountOfBitsColorBeingDealtWithIsOffBy = 0;
forLoop2GS				  	  		  ;	
	CMP R4, #3						  ;	while(index<3)
	BGE endForLoop2GS	  	  		  ;	{
	LSL R9, R7						  ;		tempColorValue = tempColorValue*(AmountOfBitsColorBeingDealtWithIsOffBy^2);
	ADD R0, R9, R0					  ;		actualColorValue += tempColorValue;
	LSR R9, R7
	LSL R5, #8						  ;		partOfColorBeingDealtWith = partOfColorBeingDealtWith*2^8;
	ADD R7, #8						  ;		AmountOfBitsColorBeingDealtWithIsOffBy += 8;
	ADD R4, R4, #1					  ;		index ++;
	B	forLoop2GS
endForLoop2GS					  	  ;		  
	LDMFD sp!,	{R4-R10,PC}			  ;	}

	;GET PIXEL DIFFERENCE 					
	;PARAMETERS: R0 PIXEL VALUE				
	;			 R1 PIXEL VALUE
	;FUNCTION:   TAKES IN TWO PIXELS AND RETURNS THE DIFFERENCE OF THE PIXELS							
	;RETURNS:	 R0 red component difference
getPixelDifference					  	 	  ;	int unsharpMask(int pixelValue1, int pixelValue2){
	STMFD sp!, {R4-R8,LR}			  ;	
	LDR R4, =0						  ;	int index = 0;
	LDR R5,	=0xFF					  ;	partOfColorBeingDealtWith = 255;
	LDR R7, =0						  ;	AmountOfBitsColorBeingDealtWithIsOffBy = 0;
forLoopPD				  	  		  ;	
	CMP R4, #3						  ;	while(index<3)
	BGE endForLoopPD	  	  		  ;	{
	MOV R6, R0						  ;		tempPixelValue1 = pixelValue2;
	AND R6,	R6, R5					  ;		tempPixelValue1 = tempPixelValue1.partOfColorBeingDealtWith;
	LSR R6, R7						  ;		tempPixelValue1 = tempPixelValue1/(AmountOfBitsColorBeingDealtWithIsOffBy^2);
	MOV R8, R1						  ;		tempPixelValue1 = pixelValue2;
	AND R8,	R8, R5					  ;		tempPixelValue2 = tempPixelValue2.partOfColorBeingDealtWith;
	LSR R8, R7						  ;		tempPixelValue2 = tempPixelValue2/(AmountOfBitsColorBeingDealtWithIsOffBy^2);
	SUB R6, R8, R6					  ;		tempColorValue = tempPixelValue2 - tempPixelValue1;
	BIC R0, R5						  ;		actualColorValue -= actualColorValue.partOfColorBeingDealtWith;
	CMP R6, #255					  ;		if(tempColorValue>255)
	BLT	lessThanTwoFiveFivePD		  ;		{
	LDR R6, =255					  ;			tempColorValue = 255;
lessThanTwoFiveFivePD	  			  ;		}
	CMP R6, #0						  ;		else if(tempColorValue<0)
	BGT	storeItUpPD					  ;		{
	LDR R6, =0						  ;			tempColorValue = 0;
storeItUpPD							  ;		}
	LSL R6, R7						  ;		tempColorValue = tempColorValue*(AmountOfBitsColorBeingDealtWithIsOffBy^2);
	ADD R0, R6, R0					  ;		actualColorValue += tempColorValue;
	LSL R5, #8						  ;		partOfColorBeingDealtWith = partOfColorBeingDealtWith*2^8;
	ADD R7, #8						  ;		AmountOfBitsColorBeingDealtWithIsOffBy += 8;
	ADD R4, R4, #1					  ;		index ++;
	B forLoopPD		  				  ;	 }
endForLoopPD					  	  ;						  
	LDMFD sp!,	{R4-R8,PC}			  ;	}

	;ADD NEG TO BLUR
	;PARAMETERS: R0 blur color value
	;			 R1 negative color value
	;FUNCTION:   Adds a pixel value to another pixel value
	;RETURNS:	 R0 the	result of the addition
addNegToBlur					  	  ;	int addNegToBlur(int blurColorValue, int negativeColorValue){
	STMFD sp!, {R4-R8,LR}			  ;	
	LDR R4, =0						  ;	int index = 0;
	LDR R5,	=0xFF					  ;	partOfColorBeingDealtWith = 255;
	LDR R7, =0						  ;	AmountOfBitsColorBeingDealtWithIsOffBy = 0;
forLoopANTG				  			  ;	
	CMP R4, #3						  ;	while(index<3)
	BGE endForLoopANTG	  	  		  ;	{
	MOV R6, R0						  ;		tempBlurColorValue = blurColorValue;
	AND R6,	R6, R5					  ;		tempBlurColorValue = tempBlurColorValue.partOfColorBeingDealtWith;
	LSR R6, R7						  ;		tempBlurColorValue = tempBlurColorValue/(AmountOfBitsColorBeingDealtWithIsOffBy^2);
	MOV R8, R1						  ;		tempNegativeColorValue = negativeColorValue;
	AND R8,	R8, R5					  ;		tempNegativeColorValue = tempNegativeColorValue.partOfColorBeingDealtWith;
	LSR R8, R7						  ;		tempNegativeColorValue = tempNegativeColorValue/(AmountOfBitsColorBeingDealtWithIsOffBy^2);
	ADD R6, R8, R6					  ;		tempColorValue = tempNegativeColorValue + tempBlurColorValue;
	BIC R0, R5						  ;		actualColorValue -= actualColorValue.partOfColorBeingDealtWith;
	CMP R6, #255					  ;		if(tempColorValue>255)
	BLT	lessThanTwoFiveFiveANTG		  ;		{
	LDR R6, =255					  ;			tempColorValue = 255;
lessThanTwoFiveFiveANTG				  ;		}
	CMP R6, #0						  ;		else if(tempColorValue<0)
	BGT	storeItUpANTG				  ;		{
	LDR R6, =0						  ;			tempColorValue = 0;
storeItUpANTG						  ;		}
	LSL R6, R7						  ;		tempColorValue = tempColorValue*(AmountOfBitsColorBeingDealtWithIsOffBy^2);
	ADD R0, R6, R0					  ;		actualColorValue += tempColorValue;
	LSL R5, #8						  ;		partOfColorBeingDealtWith = partOfColorBeingDealtWith*2^8;
	ADD R7, #8						  ;		AmountOfBitsColorBeingDealtWithIsOffBy += 8;
	ADD R4, R4, #1					  ;		index ++;
	B forLoopANTG		  	 		  ;	 }
endForLoopANTG					  	  ;	 return actualColorValue;					  
	LDMFD sp!,	{R4-R8,PC}			  ;	}

	;CHANGE TO NEG
	;PARAMETERS: R0 color value
	;FUNCTION:   Changes the color to its negative
	;RETURNS:	 R0 changed color
changeToNeg					  	 	  ;	int changeToNeg(int color value){
	STMFD sp!, {R4-R8,LR}			  ;	
	LDR R4, =0						  ;	int index = 0;
	LDR R5,	=0xFF					  ;	partOfColorBeingDealtWith = 255;
	LDR R7, =0						  ;	AmountOfBitsColorBeingDealtWithIsOffBy = 0;
	LDR R8, =255					  ;
forLoopChangeToNeg				  	  ;	
	CMP R4, #3						  ;	while(index<3)
	BGE endForLoopChangeToNeg	  	  ;	{
	MOV R6, R0						  ;		tempColorValue = actualColorValue;
	AND R6,	R6, R5					  ;		tempColorValue = tempColorValue.partOfColorBeingDealtWith;
	LSR R6, R7						  ;		tempColorValue = tempColorValue/(AmountOfBitsColorBeingDealtWithIsOffBy^2);
	SUB R6, R8, R6					  ;		tempColorValue = 255 - tempColorValue;
	BIC R0, R5						  ;		actualColorValue -= actualColorValue.partOfColorBeingDealtWith;
	CMP R6, #255					  ;		if(tempColorValue>255)
	BLT	lessThanTwoFiveFiveNeg		  ;		{
	LDR R6, =255					  ;			tempColorValue = 255;
lessThanTwoFiveFiveNeg				  ;		}
	CMP R6, #0						  ;		else if(tempColorValue<0)
	BGT	storeItUpNeg				  ;		{
	LDR R6, =0						  ;			tempColorValue = 0;
storeItUpNeg						  ;		}
	LSL R6, R7						  ;		tempColorValue = tempColorValue*(AmountOfBitsColorBeingDealtWithIsOffBy^2);
	ADD R0, R6, R0					  ;		actualColorValue += tempColorValue;
	LSL R5, #8						  ;		partOfColorBeingDealtWith = partOfColorBeingDealtWith*2^8;
	ADD R7, #8						  ;		AmountOfBitsColorBeingDealtWithIsOffBy += 8;
	ADD R4, R4, #1					  ;		index ++;
	B forLoopChangeToNeg		  	  ;	 }
endForLoopChangeToNeg			  	  ;	 return actualColorValue;					  
	LDMFD sp!,	{R4-R8,PC}			  ;	}

	;GET AVERAGE RED					
	;PARAMETERS: R0 i				
	;			 R1 j
	;			 R2 radius
	;			 R3 startAddress
	;			 R12 picture width
	;FUNCTION:   TAKES IN A PIXEL AND RETURNS THE AVERAGE RED COMPONENT OF THE PIXELS WITHIN ITS A SQUARE (RADIUS*2+1)^2							
	;RETURNS:	 R0 average red component
getAverageRed				; int getAverageRed(int i, int j, int radius, int[] startAddress, int pictureWidth)
	STMFD sp!, {R4-R11,LR}	; {
	MOV R4, #0				; 	int totalOfAddedComponents = 0;
	SUB R5, R0, R2			; 	int currentPixeli = i + radius;
	SUB R6, R1, R2			; 	int currentPixelj = j + radius;
	ADD R7, R0, R2			; 	int maxPixeli = i + radius;
	LDR	R8,	[SP, #36]		; 	int pictureWidth = stackParameter;
	MOV R9, R2				; 	int radius = parameter2;
	ADD R12, R1, R2			; 	int maxPixelj = j + radius
	MOV R10, R3				; 	int startAddress = parameter3;
	LDR R11, =0				; 	int numberOfContributingPixels = 0;
innerForLoopR				; 
	CMP R6, R12				; 	while(currentPixelj <= maxPixelj)
	BGT	endInnerForLoopR	; 	{
innerMostForLoopR			;
	CMP R5, R7				;		while(currentPixeli <= maxPixeli)
	BGT endInnerMostForLoopR;		{
	MOV R0, R10				;
	MOV R1, R5				;
	MOV R2, R6				;
	MOV R3, R8				;
	BL	getPixelR			;			startAddress[currentPixeli][pixelj].getRedComponent();
	CMP R5, #0				;   		if(currentPixeli >=0
	BLT dontAddToTotalR		;	   	  	  &&
	CMP R6, #0				;        		currentPixelj >=0
	BLT dontAddToTotalR		;			 	 &&
	CMP R5, R8				;   	 	  	  currentPixeli <=width
	BGE dontAddToTotalR		;	   				&&
	CMP R6, #0x97			;        	  		 currentPixelj <=0
	BGE dontAddToTotalR		;			{
	ADD R4, R4, R0			;				totalOfAddedComponents += startAddress[currentPixeli][currentPixelj].redComponent;
	ADD R11, R11, #1		;				numberOfContributingPixels++;
dontAddToTotalR				;   		}
	ADD	R5,	R5,	#1			; 			currentPixeli++;
	B 	innerMostForLoopR	;		}
endInnerMostForLoopR		;		
	SUB R5, R5, R9			;		currentPixeli -= radius;
	SUB R5, R5, R9			;		currentPixeli -= radius;
	ADD	R6,	R6,	#1			; 		currentPixelj++;
	B	innerForLoopR		; 	}	
endInnerForLoopR			;
	MOV R0, R4				;
	MOV R1, R11				;
	BL  divide				; 	return totalOfAddedComponents/numberOfContributingPixels;
	LDMFD sp!,	{R4-R11,PC}	; }

	;GET AVERAGE BLUE					
	;PARAMETERS: R0 i				
	;			 R1 j
	;			 R2 radius
	;			 R3 startAddress
	;			 R12 picture width
	;FUNCTION:   TAKES IN A PIXEL AND RETURNS THE AVERAGE BLUE COMPONENT OF THE PIXELS WITHIN ITS A SQUARE (RADIUS*2+1)^2							
	;RETURNS:	 R0 average blue component
getAverageBlue				; int getAverageBlue(int i, int j, int radius, int[] startAddress, int pictureWidth)
	STMFD sp!, {R4-R11,LR}	; {
	MOV R4, #0				; 	int totalOfAddedComponents = 0;
	SUB R5, R0, R2			; 	int currentPixeli = i - radius;
	SUB R6, R1, R2			; 	int currentPixelj = j - radius;
	ADD R7, R0, R2			; 	int maxPixeli = i + radius;
	LDR	R8,	[SP, #36]		; 	int pictureWidth = stackParameter;
	MOV R9, R2				; 	int radius = parameter2;
	ADD R12, R1, R2			; 	int maxPixelj = j + radius
	MOV R10, R3				; 	int[] startAddress = parameter3;
	LDR R11, =0				; 	int numberOfContributingPixels = 0;
innerForLoopB				; 
	CMP R6, R12				; 	while(currentPixelj <= maxPixelj)
	BGT	endInnerForLoopB	; 	{	
innerMostForLoopB			;
	CMP R5, R7				;		while(currentPixeli <= maxPixeli)
	BGT endInnerMostForLoopB;		{	
	MOV R0, R10				;
	MOV R1, R5				;
	MOV R2, R6				;
	MOV R3, R8				;
	BL	getPixelB			;		startAddress[currentPixeli][pixelj].getBlueComponent();
	CMP R5, #0				;   	if(currentPixeli >=0
	BLT dontAddToTotalB		;	   	  &&
	CMP R6, #0				;        	currentPixelj >=0
	BLT dontAddToTotalB		;			  &&
	CMP R5, R8				;   	 	    currentPixeli <=pictureWidth
	BGE dontAddToTotalB		;	   			 &&
	CMP R6, #0x97			;        	  	   currentPixelj <=0)
	BGE dontAddToTotalB		;		{
	ADD R4, R4, R0			;			totalOfAddedComponents += startAddress[currentPixeli][currentPixelj].blueComponent;
	ADD R11, R11, #1		;			numberOfContributingPixels++;
dontAddToTotalB				;   	}
	ADD	R5,	R5,	#1			; 			currentPixeli++;
	B 	innerMostForLoopB	;		}
endInnerMostForLoopB		;			
	SUB R5, R5, R9			;		currentPixeli -= radius;
	SUB R5, R5, R9			;		currentPixeli -= radius;
	ADD	R6,	R6,	#1			; 		currentPixelj++;
	B	innerForLoopB		; 	}	
endInnerForLoopB			;
	MOV R0, R4				;
	MOV R1, R11				;
	BL	divide				; 	return totalOfAddedComponents/numberOfContributingPixels;
	LDMFD sp!,	{R4-R11,PC}	; }

	;GET AVERAGE GREEN					
	;PARAMETERS: R0 i				
	;			 R1 j
	;			 R2 radius
	;			 R3 startAddress
	;			 R12 picture width
	;FUNCTION:   TAKES IN A PIXEL AND RETURNS THE AVERAGE GREEN COMPONENT OF THE PIXELS WITHIN ITS A SQUARE (RADIUS*2+1)^2  							
	;RETURNS:	 R0 average green component
getAverageGreen				; int getAverageGreen(int i, int j, int radius, int[] startAddress, int pictureWidth)
	STMFD sp!, {R4-R11,LR}	; {
	MOV R4, #0				; 	totalOfAddedComponents = 0;
	SUB R5, R0, R2			; 	int currentPixeli = i - radius;
	SUB R6, R1, R2			; 	int currentPixelj = j - radius;
	ADD R7, R0, R2			; 	int maxPixeli = i + radius
	LDR	R8,	[SP, #36]		; 	int pictureWidth = stackParameter
	MOV R9, R2				; 	int radius = parameter2;
	ADD R12, R1, R2			; 	int maxPixelj = j + radius
	MOV R10, R3				; 	int[] startAddress = parameter3;
	LDR R11, =0				; 	int numberOfContributingPixels = 0;
innerForLoopG				;
	CMP R6, R12				; 	while(currentPixelj <= maxPixelj)
	BGT	endInnerForLoopG	; 	{
innerMostForLoopG			;
	CMP R5, R7				;		while(currentPixeli <= maxPixeli)
	BGT endInnerMostForLoopG;		{	
	MOV R0, R10				;
	MOV R1, R5				;
	MOV R2, R6				;
	MOV R3, R8				;
	BL	getPixelG			;		startAddress[currentPixeli][currentPixelj].getGreenComponent();
	CMP R5, #0				;   	if(currentPixeli >=0
	BLT dontAddToTotalG		;	   	  &&
	CMP R6, #0				;        	currentPixelj >=0
	BLT dontAddToTotalG		;			  &&
	CMP R5, R8				;   	 	   currentPixeli <= pictureWidth
	BGE dontAddToTotalG		;	   			 &&
	CMP R6, #0x97			;        	  	   currentPixelj <= pictureHeight)
	BGE dontAddToTotalG		;		{
	ADD R4, R4, R0			;			totalOfAddedComponents += pixelArray[currentPixeli][currentPixelj].greenComponent;
	ADD R11, R11, #1		;			numberOfContributingPixels++;
dontAddToTotalG				;   	}
	ADD	R5,	R5,	#1			; 			currentPixeli++;
	B 	innerMostForLoopG	;		}
endInnerMostForLoopG		;		  
	SUB R5, R5, R9			;		currentPixeli -= radius;
	SUB R5, R5, R9			;		currentPixeli -= radius;
	ADD	R6,	R6,	#1			; 		currentPixelj++;
	B	innerForLoopG		; 	}	
endInnerForLoopG			;
	MOV R0, R4				;
	MOV R1, R11				;
	BL  divide				; 	return totalOfAddedComponents/numberOfContributingPixels;
	LDMFD sp!,	{R4-R11,PC}	; }

	;DIVIDE					
	;PARAMETERS: R0 number				
	;			 R1 divisor
	;FUNCTION:   Divides a number by a divisor 							
	;RETURNS:	 R0 quotient
divide						; int divide(int number, int divisor)
	STMFD sp!, {R7-R9,LR}	; {
	MOV R7, R0				; 	int number = parameter1;
	MOV R8, R1				; 	int divisor = parameter2;
	MOV R9, #0				; 	int count = 0;
divideForLoop				;
	CMP R7, R8				; 	while(number >= divisor)
	BLT endDivideForLoop	; 	{
	SUB R7, R7, R8			; 		number = number - divisor;
	ADD R9, R9, #1			; 		count++;
	B divideForLoop			; 	}
endDivideForLoop			;
	MOV R0, R9				;  	return count;
	LDMFD sp!,	{R7-R9,PC}	; }

	;GET RED COMPONENT OF PIXEL [i,j]		 
	;PARAMETERS: R0 start address				 
	;			 R1 i								 
	;			 R2 j									 
	;			 R3 picture width							 
	;RETURNS:	 R0 red component								 
getPixelR
	STMFD sp!, {R4-R5,LR}
	MUL	R4,	R3,	R2
	ADD	R4,	R4,	R1
	LDR	R5,	[R0, R4,LSL	#2]
	AND	R0, R5, #0x000000FF
	LDMFD sp!,	{R4-R5,PC}

	;GET GREEN COMPONENT OF PIXEL [i,j]	   
	;PARAMETERS: R0 start address			   
	;			 R1 i							   
	;			 R2 j								   
	;			 R3 picture width						   
	;RETURNS:	 R0 green component							  
getPixelG
	STMFD sp!, {R4-R5,LR}
	MUL	R4,	R3,	R2
	ADD	R4,	R4,	R1
	LDR	R5,	[R0,	R4,	LSL	#2]
	AND	R0,	R5,	#0x0000FF00
	LSR R0, #8
	LDMFD sp!,	{R4-R5,pc}

	;GET BLUE COMPONENT OF PIXEL [i,j]		  
	;PARAMETERS: R0 start address				  
	;			 R1 i								  
	;			 R2 j									 
	;			 R3 picture width							 
	;RETURNS:	 R0 blue component								  
getPixelB
	STMFD sp!, {R4-R5,LR}
	MUL	R4,	R3,	R2
	ADD	R4,	R4,	R1
	LDR	R5,	[R0,	R4,	LSL	#2]
	AND	R0,	R5, #0x00FF0000
	LSR	R0,	#16
	LDMFD sp!,	{R4-R5,pc}
									   	
	;SET RED COMPONENT OF PIXEL [i,j]
	;PARAMETERS: R0  start address 			
	;			 R1  i						
	;			 R2  j							
	;			 R3  picture width					
	;			 R12 value to be set					
	;RETURNS:	 null										
setPixelR
		STMFD	sp!,	{R4-R6, LR}
		MOV R6, R1
		LDR	R5,	[SP, #16]
		MUL	R6,	R3,	R2
		ADD	R6,	R6,	R1
		LDR	R4,	[R0,	R6,	LSL	#2]
		AND R4, R4, #0xFFFFFF00
		ADD R4, R4, R5
		STR R4, [R0, R6, LSL #2]
		LDMFD	sp!,	{R4-R6, PC}

	;SET GREEN COMPONENT OF PIXEL [i,j]		
	;PARAMETERS: R0  start address				
	;			 R1  i								
	;			 R2  j									
	;			 R3  picture width							
	;			 R12 value to be set							
	;RETURNS:	 null												
setPixelG
		STMFD	sp!,	{R4-R6, LR}
		MOV R6, R2
		LDR	R5,	[SP, #16]
		MUL	R6,	R3,	R2
		ADD	R6,	R6,	R1
		LDR	R4,	[R0,	R6,	LSL	#2]
		AND R4, R4, #0xFFFF00FF
		LSL R5, #8
		ADD R4, R4, R5
		STR R4, [R0, R6, LSL #2]
		LDMFD	sp!,	{R4-R6, PC}

	;SET BLUE COMPONENT OF PIXEL [i,j]
	;PARAMETERS: R0  start address
	;			 R1  i
	;			 R2  j
	;			 R3  picture width
	;			 R12 value to be set
	;RETURNS:	 null
setPixelB
		STMFD	sp!,	{R4-R6, LR}
		MOV R6, R1
		LDR	R5,	[SP, #16]
		MUL	R6,	R3,	R2
		ADD	R6,	R6,	R1
		LDR	R4,	[R0,	R6,	LSL	#2]
		AND R4, R4, #0xFF00FFFF
		LSL R5, #16
		ADD R4, R4, R5
		STR R4, [R0, R6, LSL #2]
		LDMFD	sp!,	{R4-R6, PC}

cool
 		BL	putPic		; re-display the updated image

stop	B	stop


	END	