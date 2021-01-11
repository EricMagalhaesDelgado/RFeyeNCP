#include <stdint.h>

/** \brief Performs a single time capture
* \details Opens an NCP connection, requests a time capture in a "DSP Control" packet
* and closes the connection after receiving the data
*
* \param[out]       iData           array of I data retrieved (uV), needs to be allocated before the call
* \param[out]       qData           array of Q data retrieved (uV), needs to be allocated before the call
* \param[in/out]    bandwidthHz     bandwidth of the request (Hz), returned value is the real bandwidth received
* \param[in]        exactMode       requests for the exact bandwidth if value not 0 (response will take longer)
*                                   it will be ignored if streaming is also requested
* \param[in]        centerFreqMHz   central frequency of the time capture (MHz)
* \param[in]        streaming       request for streaming if value not 0
* \param[in]        numSamples      number of samples requested
* \param[in]        host            node's address (IP or hostname)
* \param[in]        port            node's NCP port
*/
__declspec(dllexport) void GetSingleTimeCapture(double* iData, double* qData, int* bandwidthHz,
	int exactMode, int centerFreqMHz, int streaming, int numSamples, const char *host, int32_t port);


/** \brief Starts a continuous time capture
* \details Opens an NCP connection and requests a time capture in a in a "DSP Loop" packet keeping the connection open
*
* \param[in]        bandwidthHz     bandwidth of the request (Hz)
* \param[in]        exactMode       requests for the exact bandwidth if value not 0 (response will take longer),
*                                   it will be ignored if streaming is also requested
* \param[in]        centerFreqMHz   central frequency of the time capture (MHz)
* \param[in]        streaming       request for streaming if value not 0
* \param[in]        numSamples      number of samples requested
* \param[in]        host            node's address (IP or hostname)
* \param[in]        port            node's NCP port
*/
__declspec(dllexport) void StartTimeCapture(int bandwidthHz, int exactMode, int centerFreqMHz, int streaming,
	int numSamples, const char *host, int32_t port);


/** \brief Gets a time capture packet from the open connection
*
* \param[out]       iData           array of I data retrieved (uV), needs to be allocated before the call
* \param[out]       qData           array of Q data retrieved (uV), needs to be allocated before the call
* \param[out]       bandwidthHz     real bandwidth received
* \param[in]        numSamples      number of samples requested
*/
__declspec(dllexport) void GetTimeCaptureData(double* iData, double* qData, int* bandwidthHz, int numSamples);


/** \brief Closes the NCP connection of the time capture
*/
__declspec(dllexport) void EndTimeCapture();


/** \brief Start a continuous sweep
* \details Opens an NCP connection, requests a sweep in a "DSP Loop" packet keeping the connection open
* and returns the estimated number of (equal or greater than) the samples that will be returned
*
* \param[in]    startFreqMHz    start frequency of the sweep (MHz)
* \param[in]    stopFreqMHz     stop frequency of the sweep (MHz)
* \param[in]    bandwidthHz     span of the sweep (Hz)
* \param[out]   numSamples      estimation of number of samples returned in each sweep
* \param[in]    host            node's address (IP or hostname)
* \param[in]    port            node's NCP port
*/
__declspec(dllexport) void StartSweep(int startFreqMHz, int stopFreqMHz, int bandwidthHz, int* numSamples,
    const char *host, int port);


/** \brief Gets a sweep packet from the open connection
*
* \param[out]   sweepData       array of sweep data received received (dBm), needs to be allocated before the call
* \param[out]   startFreqMHz    actual start frequency of the sweep (MHz)
* \param[out]   startFreqmHz    actual start frequency of the sweep (mHz)
* \param[out]   bandwidthHz     real bandwidth received
* \param[out]   numSamples      actual number of samples returned
*/
__declspec(dllexport) void GetSweepData(double* sweepData, int* startFreqMHz, int* startFreqmHz,
    int* bandwidthHz, int* numSamples);


/** \brief Closes the NCP connection of sweep
*/
__declspec(dllexport) void EndSweep();
