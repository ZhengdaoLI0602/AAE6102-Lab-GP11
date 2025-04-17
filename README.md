Apart from the markdown version, a clear PDF version is available at: https://github.com/ZhengdaoLI0602/AAE6102-Lab-GP11/blob/main/AAE6102_LAB%20report_Group11.pdf


In this laboratory report, we will leverage the RTKLIB (GUI) to process the U-Blox RINEX data in the medium urban case of the UrbanNav dataset. As for the coding part, run the main script with the prefix "main\_evaluation\_" to generate the evaluated results and the figures. All the used figures in this report have also been include in the folder "Figures" in the repository.

### 1 RTKLIB Settings

The file path settings are summarized in the following Table 1.

![Table1](/Users/lisijia/Desktop/Figure/Table1.png)

### 2 Parameters and Analysis

Parameters regarding positioning mode, filter settings, and satellite selection criteria will be tuned and analyzed in the following paragraphs. For the convenience of comparison, we configure the following settings to be a benchmark, as summarized in the Table 2. For each tuned parameter, the evaluation will be conducted in the following several aspects:

- **2D trajectory**: showing the scatter plot of latitude-longitude coordinates throughout all epochs.

- **2D positioning error**: showing the positioning quality throughout all epochs, as well as the corresponding root means square error (RMSE) and standard deviation (STD).

- **Number of valid satellite signals**: the number of satellites signals used for positioning, which reflects the extent of open-sky view of the surroundings and the quality of the signals.

  ![Table2](/Users/lisijia/Desktop/Figure/Table2.png)

#### 2.1 Filter Type

Foward filter means that the data is processed from the earliest epoch to the latest one, and the physical scenario with forward filter is real-time positioning. The backward filter means the data is reversely processed from the latest epoch to the earliest one, which is applied in post-processing. The backward setting may improve the positioning accuracy by using ''future'' data to support ''historical'' data. Additionally, the combined filtering combines both the forward and backward process, which stores all the forward-processed data, then implements a Rauch-Tung-Striebel (RTS) smoother to smoothen the states along the trajectory during the backward filtering.

Since we are using ''kinematic'' positioning mode by default, the Kalman filter is active, the forward, backward, and combined filtering may generate different positioning results, and we will discuss as follows. 

![Figure1](/Users/lisijia/Desktop/Figure/Figure1.png)

![Table3](/Users/lisijia/Desktop/Figure/Table3.png)

It can be seen from both Figure 1 and Table 3 that the combined filtering type provides the most improvement to the positioning results given by the medium urban GNSS dataset. The combined mode has the lowest RMSE and STD, while the backward mode slightly improves the positioning accuracy and precision compared to the forward mode. Notably, the combined mode takes the longest processing time as it contains both a forward and backward process. Besides, the Kalman filtering mode does not set satellite selection thus the three filtering mode receives approximately the same number of valid satellites, as shown in Figure 1c. Notably, there might be zero number of valid satellites in ``kinematic" mode because it set strict selection standards, including continuous phase lock and resolved ambiguities. For these particular epochs, the Kalman filter will propagate the model prediction without the update of GNSS measurements. As a result, positioning solution is available for all epochs.

#### 2.2 Elevation mask

An elevation mask of 30 degree is applied to all epochs, and only the satellite signals with an elevation angle higher than 30 degrees will be utilized for positioning. This setting is designed to filter out non-line-of-sight (NLOS) or multipath satellites that might get blocked by tall buildings in the urban scenario.

The positionings given by the benchmark settings and the tuned SNR mask will be compared in Figure 2, and the 2D RMSE and STD of the positionings are displayed in Table 4.

![Table4](/Users/lisijia/Desktop/Figure/Table4.png)

Our expected outcome is that the RMSE and STD can decrease because Elevation mask should filter some "bad" satellite with potential NLOS or multipath. However, results in Table~\ref{tab: 2d rmse and std elevationmask} shows that this is not necessarily the case. This can be explained that when the degree is fixed to 30°, some functional satellites are also being excluded from the dataset, and this operation contributes to the drop of the positioning performance. An improvement could be setting the skymask which sets the elevation mask based on the azimuth angle. This will avoid the case that LOS satellite signals with low elevation is filtered out.

![Figure2](/Users/lisijia/Desktop/Figures/Figure2.png)

#### 2.3 Signal-Noise Ratio (SNR) mask

A SNR mask of 25 dB is applied to all epochs, and only the satellite signals with an elevation angle higher than 25 dB will be utilized for positioning. The logic lies that reflected or diffracted satellite signals tend to have lower SNR. A SNR mask is designed to filter out potential NLOS or destructive multipath satellites signals.

The positionings given by the benchmark settings and the tuned SNR mask will be compared in Figure 3, and the 2D RMSE and STD of the positionings are displayed in Table 5.

![Figure3](/Users/lisijia/Desktop/Figure/Figure3.png)

Same as the elevation mask options, when the SNR mask is applied in the RTKlib on the data, RMSE and STD become slightly larger.  Reasons may lie that the SNR mask with a fixed magnitude may filter out some LOS signal with low signal strength, thus decreasing the positioning accuracy. Improvement. A better approach could be replacing the fixed SNR mask to be the adaptive one that is based on the elevation angle.

![Table5](/Users/lisijia/Desktop/Figure/Table5.png)



#### 2.4 Constellation type

The setting of the single constellation (GPS only) will be explored in this section. The positionings given by the benchmark settings and the tuned constellation settings will be compared in Figure 4, and the 2D RMSE and STD of the positionings are displayed in Table 6.

![Table6](/Users/lisijia/Desktop/Figure/Table6.png)

As is expected, the performance of one single constellation (GPS) is worse than that given by multiple constellations. We can see in Figure 4a that the GPS positionings are more sparsely distributed with lower precision. Figure 4b  shows that there can also be large error up to 250m. Due to the reduced number of valid satellites (Figure 4c), both the RMSE and STD given by the single constellation are much higher than those given by multiple constellations. And there are only 1456 epochs having positioning results using GPS only.

![Figure4](/Users/lisijia/Desktop/Figure/Figure4.png)

#### 2.5 Positioning mode

As it shows in the Figure 5, there are 4 positioning modes used incomparison. Figure 5a shows the overall positioning performance in a moving scenario, where the green line represents the ground truth, the dark blue dots represents the positioninig trajactory via kinematic mode, the pink dots represents the positioning results of the static mode, the light blue dots are the trajectory of the single mode and the red lines are the results of the differential mode. 

![Figure5](/Users/lisijia/Desktop/Figure/Figure5.png)

- **Kinematic mode**:  The algorithm used in the kinematic mode is the combination of carrier phase differential and the real time kinematic (RTK), which estimates position and ambiguity in real-time using the extended kalman filter (EKF). It utilises the data from both the receiver and the reference base station, so that both the clock bias of the satellite and the receiver can be eliminated. The kinematic mode is suitable for dynamic scenarios, with the model incorporating velocity and state transition.

- **Static mode**: For static mode, it shares the similar algorithm as the kinematic mode, and it also requires both the receiver and the reference base station for positioning. Unlike the kinematic mode, the state model does not include velocity terms and the position is typically modeled as constant or slowly varying. Therefore, the static mode is not suitable for dynamic positioning and the use case for the static mode is usually the positioning of the ground truth.

- **Single mode**: The observables for the single point positioning (SPP) are only the pseudorange measurements, and it can derive the user's location directly by solving the positioning equation based on least squares (LS) and the EKF. However, due to the lack of the estimation of other error sources, such as the ionospheric delay, tropospheric delay, and multipath, the positioning accuracy of the SPP is not that satisfactory, compared to the kinematic mode and the static mode. 

- **Differential mode**: As the improvement of the SPP, differential mode is enhanced by using the observables from the other reference base station, which utilize both the signals from the satellite and the reference base station to eliminate the error caused by the ionospheric delay and tropospheric delay. However, it requires both the receiver and the base station receive the same satellite signals. Therefore, the limitation of the differential mode is the restricted coverage. 

![Table7](/Users/lisijia/Desktop/Figure/Table7.png)

We can observe that the static positioning mode gives the worst performance. It has the highest 2d positioning error, as shown in Figure 5b. It has the least number of valid satellites (reflected in Figure 5d) and has the least number of epochs having positioning solutions (i.e., 932). Accordingly, the RMSE and STD are significantly higher than other modes. As explained in the previous paragraph, the static mode assumes constant or slowly-varying position model without considering the velocity, thus is not suitable for our dynamic dataset.   

Single mode represents SPP, which has the least strict selection standards for valid satellites, thus overall presenting the highest level in Figure 5d. It has the second largest RMSE and STD, given that the data is from uBlox F9P only. In contrast, the differential mode use observation dataset from both the reference station and the receiver, thus further reducing RMSE and STD. This mode also provides positioning solutions in almost every epochs (1535).

The benchmark (i.e.,  kinematic mode) considers both the pseudorange measurement and the carrier phase measurements, thus giving the least RMSE and STD shown in Table 7, as is expected for our dynamic dataset. 

The reason why the static mode has the worst positioning performance is obvious, as it is incapable of solving the errors caused by the ionospheric delay and the tropospheric delay. The differential mode outperforms the static mode is that the receiver has a certain mobility, and it is not suitable for static mode. 

As for the number of available satellites for different positioning mode, the single mode only requires the pseudorange measurements, therefore, it can have the most satellites for positioning. The number of available satellites for differential mode is a little bit less than the single mode, it is due to the fact that compared to the single mode, the differential additionally requires the reference base station to receive the signals from the same satellites. The reason why the static and the kinematic mode have less number of available satellites is that they ask for signals at both L1 and L2 frequency.

### 3 Strength and limitation of the library

#### 3.1 Strength

The RTKlib GUI has a graphical interface that is very helpful in terms of demonstration usage. It is especially friendly for users who have no coding knowledge. In addition, the graphical interface provides an interactive operation mode, and it is easy for the user to play with different settings. The results can be plotted well, and there are no further actions for the users to visualize the positioning results. Besides, compared to other software receivers, it compiles the given dataset quickly, since it is written in C. For the MATLAB-based software receivers, such as softgnss, the RTKlib saves time for running the code. Also, the RTKlib can cater for developing other embedded operating systems, and the real-time positioning platform can be built based on the RTKlib.

#### 3.2 Limitations

The current RTKLIB GUI version only supports a limited number of functions in the interface. The parameter that can be tuned is fixed and less flexible than the RTKLIB written in programming languages. Besides, the RTKlib is best written in C code, but it is very difficult for users to make any other modifications, such as the modification of the algorithm. It may require the users to have very solid coding capabilities. Therefore, in terms of doing research related to signal processing, other than using the output positioning results, the RTKlib has more limitations compared to the MATLAB-based software receivers.

#### 3.1 Suggestions for improvements:
- The process for selecting GNSS library needs improvement. Currently, when using the RTKlib for positioning, we need to input the original files from the UBLOX, and we need to select the needed types of satellites to do the positioning. Therefore, we have to do our own decision. Further improvements can be made for more automation. For example, the improved version of RTKlib could select the satellite constellations based on the received signal qualities and so on.
- The parameter tuning process can be further improved. Currently, we tune a parameter and conduct the processing throughout the whole dataset, which is time-consuming. If we deliberately extract a known GNSS-challenging fraction of the dataset to test the performance given by the tuned parameter, the process is expected to be shorter. We can more quickly switch through different values of the parameters, thus obtaining the optimal value more efficiently.




