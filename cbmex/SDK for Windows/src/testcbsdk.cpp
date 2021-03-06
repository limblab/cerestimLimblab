///////////////////////////////////////////////////////////////////////
//
// Test SDK
//
// $Workfile: testsdk.cpp $
// $Archive: /Cerebus/Human/LinuxApps/cbmex/testsdk.cpp $
// $Revision: 1 $
// $Date: 10/22/12 12:00a $
// $Author: Ehsan $
//
// Purpose:
//  This is the test suite to run test stubs
//
//  Note:
//   Make sure only the SDK is used here, and not cbhwlib directly
//    this will ensure SDK is capable of whatever test suite can do
//   Do not throw exceptions, catch possible exceptions and handle them the earliest possible in this library
//

#include <map>
#include <string>
#include <vector>
#include "debugmacs.h"

#include "cbsdk.h"

// Author & Date:   Ehsan Azar    24 Oct 2012
// Purpose: Test openning the library
cbSdkResult testOpen(void)
{
    cbSdkConnectionType conType = CBSDKCONNECTION_DEFAULT;

    // Version can be read even before library open
    cbSdkVersion ver;
    cbSdkResult res = cbSdkGetVersion(&ver);

    printf("Initializing Cerebus real-time interface %d.%02d.%02d.%02d (protocol cb%d.%02d)...\n", ver.major, ver.minor, ver.release, ver.beta, ver.majorp, ver.minorp);

    cbSdkInstrumentType instType;
    res = cbSdkOpen(conType);
    switch (res)
    {
    case CBSDKRESULT_SUCCESS:
        break;
    case CBSDKRESULT_NOTIMPLEMENTED:
        printf("Not implemented\n");
        break;
    case CBSDKRESULT_INVALIDPARAM:
        printf("Invalid parameter\n");
        break;
    case CBSDKRESULT_WARNOPEN:
        printf("Real-time interface already initialized\n");
    case CBSDKRESULT_ERROPENCENTRAL:
        printf("Unable to open library for Central interface\n");
        break;
    case CBSDKRESULT_ERROPENUDP:
        printf("Unable to open library for UDP interface\n");
        break;
    case CBSDKRESULT_ERROPENUDPPORT:
        res = cbSdkGetType(NULL, &instType);
        if (instType == CBSDKINSTRUMENT_NPLAY || instType == CBSDKINSTRUMENT_REMOTENPLAY)
            printf("Unable to open UDP interface to nPlay\n");
        else
            printf("Unable to open UDP interface\n");
        break;
    case CBSDKRESULT_OPTERRUDP:
        printf("Unable to set UDP interface option\n");
        break;
    case CBSDKRESULT_MEMERRUDP:
        printf("Unable to assign UDP interface memory\n"
            " Consider using sysctl -w net.core.rmem_max=8388608\n"
            " or sysctl -w kern.ipc.maxsockbuf=8388608\n");
        break;
    case CBSDKRESULT_INVALIDINST:
        printf("Invalid UDP interface\n");
        break;
    case CBSDKRESULT_ERRMEMORYTRIAL:
        printf("Unable to allocate RAM for trial cache data\n");
        break;
    case CBSDKRESULT_ERROPENUDPTHREAD:
        printf("Unable to Create UDP thread\n");
        break;
    case CBSDKRESULT_ERROPENCENTRALTHREAD:
        printf("Unable to start Cerebus real-time data thread\n");
        break;
    case CBSDKRESULT_ERRINIT:
        printf("Library initialization error\n");
        break;
    case CBSDKRESULT_ERRMEMORY:
        printf("Library memory allocation error\n");
        break;
    case CBSDKRESULT_TIMEOUT:
        printf("Connection timeout error\n");
        break;
    default:
        printf("Unexpected error\n");
        break;
    }

    if (res >= 0)
    {    
        // Return the actual openned connection
        res = cbSdkGetType(&conType, &instType);
        if (res != CBSDKRESULT_SUCCESS)
            printf("Unable to determine connection type\n");
        res = cbSdkGetVersion(&ver);
        if (res != CBSDKRESULT_SUCCESS)
            printf("Unable to determine instrument version\n");

        if (conType < 0 || conType > CBSDKCONNECTION_CLOSED)
            conType = CBSDKCONNECTION_COUNT;
        if (instType < 0 || instType > CBSDKINSTRUMENT_COUNT)
            instType = CBSDKINSTRUMENT_COUNT;
        
        char strConnection[CBSDKCONNECTION_COUNT + 1][8] = {"Default", "Central", "Udp", "Closed", "Unknown"};
        char strInstrument[CBSDKINSTRUMENT_COUNT + 1][13] = {"NSP", "nPlay", "Local NSP", "Remote nPlay", "Unknown"};
        printf("%s real-time interface to %s (%d.%02d.%02d.%02d) successfully initialized\n", strConnection[conType], strInstrument[instType], ver.nspmajor, ver.nspminor, ver.nsprelease, ver.nspbeta);
    }
    
    return res;
}

// Author & Date:   Ehsan Azar    25 Oct 2012
// Purpose: Test closing the library
cbSdkResult testClose(void)
{
    cbSdkResult res = cbSdkClose();
    switch(res)
    {
    case CBSDKRESULT_SUCCESS:
        printf("Interface closed successfully\n");
        break;
    case CBSDKRESULT_WARNCLOSED:
        printf("Real-time interface already closed\n");
        break;
    default:
        printf("Unexpected error in closing the library!\n");
        break;
    }
    
    return res;
}

/////////////////////////////////////////////////////////////////////////////
// The test suit main entry
int main(int argc, char *argv[])
{
    cbSdkResult res = testOpen();
    if (res < 0)
        printf("testOpen failed (%d)!\n", res);
    else
        printf("testOpen succeeded\n");
    res = testClose();
    if (res < 0)
        printf("testClose failed (%d)!\n", res);
    else
        printf("testClose succeeded\n");
    
    return 0;
}
