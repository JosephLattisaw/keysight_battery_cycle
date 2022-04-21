////////////////////////////////////////////////////////////////////////////////
// © Keysight Technologies 2016
//
// You have a royalty-free right to use, modify, reproduce and distribute
// the Sample Application Files (and/or any modified version) in any way
// you find useful, provided that you agree that Keysight Technologies has no
// warranty, obligations or liability for any Sample Application Files.
//
////////////////////////////////////////////////////////////////////////////////

#include "stdafx.h"

#include "visa.h"
#include <iostream>

void errorHandler(ViStatus status, ViSession sessionId)
{
	if (status < VI_SUCCESS)
	{
		printf("An error has occurred!\n");

		// To get more information about the error we can call viStatusDesc
		ViChar errorMessage[256];
		int error = viStatusDesc(sessionId, status, errorMessage);

		if (error >= VI_SUCCESS)
		{
	
			printf("\n\tError code: %d\n\tError description: %s\n",
				status,
				errorMessage);
		}
		else
		{
			printf("\n\tThere was an error getting the description of the original error!\n\tError code: %d\n\tOriginal error code: %d\n",
				error,
				status);
		}
	}
}


int main()
{

	// Change this variable to the address of your instrument
	ViRsrc VISA_ADDRESS = "USB0::0x008D::0x3502::MY58000516::0::INSTR";
	//ViRsrc VISA_ADDRESS = "USB0::0x2A8D::0x5101::MY58001093::0::INSTR";

	ViSession resourceManager;
	ViSession session;
	viOpenDefaultRM(&resourceManager);

	ViStatus status = 0;
	// Part 1:
	// 
	// Shows the mechanics of how to deal with an error in VISA when it occurs. 
	// To stimulate an error, the code will try to open a connection to an instrument at an invalid address...
	
	// First we'll provide an invalid address and see what error we get 
	//status = viOpen(resourceManager, "BAD ADDRESS", VI_NO_LOCK, 0, &session);
	
	if (status < VI_SUCCESS)
	{
		printf("An error has occurred!\n%d\n", status);

		// To get more specific information about the exception, we can check what kind of error it is and add specific error handling code
		// In this example, that is done in the errorHandler method
		errorHandler(status, resourceManager);
	}

	// Part 2:
	// 
	// Stimulate another error by sending an invalid query and trying to read its response. 
	// 
	// Before running this part, don't forget to set your instrument address in the 'VISA_ADDRESS' variable at the top of this method
	std::cout << "Im here right" << std::endl;
	status = viOpen(resourceManager, VISA_ADDRESS, VI_NULL, 0, &session);
	std::cout << "but im not here" << std::endl;
	
	// Misspell the *IDN? query as *IND?
	status = viPrintf(session, "*IDN?\n");
	
	if (status < VI_SUCCESS)
	{
		printf("You'll never get here, because the *IND? data will get sent to the instrument successfully; it's the instrument that won't like it.\n");
	}

	// Try to read the response (*IND?)
	ViChar idnResponse[100];
	status = viScanf(session, "%t", idnResponse);

	if (status < VI_SUCCESS)
	{
		printf("The scanf call will timeout, because the instrument doesn't know what to do with the command that we sent it.\nError code: %d\n", status);

		// Check the instrument to see if it has any errors in its queue
		ViChar rawError[100];
		int errorCode = -1;
		ViChar errorString[100];

        //TODO fix error handling windows version
		/*while (errorCode != 0)
		{
			viPrintf(session, "SYST:ERR?\n");
			viScanf(session, "%t", rawError);
			
			//sscanf_s(rawError, "%d, %100[^\n]", &errorCode, errorString, 100);
			printf("Instrument error code: %d, instrument error message: %s\n", errorCode, errorString);
		}*/
	} else {
	    std::cout << "idn: " << idnResponse << std::endl;
	}

	viClose(session);
	viClose(resourceManager);

	printf("\nPress any key to exit...");
	char keyBuffer[100];
	//scanf_s("%c", keyBuffer, 100);

    return 0;
}
