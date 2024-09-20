**Step 1: Load S037.SH.L.sess6.4chans.mat**
\newline
The matrix DATA contains 4 columns; 

1st column corresponds to an EEG signal

2nd column corresponds to an EKG signal

3rd column corresponds to an Respiratory signal

4th column corresponds to 2-Hz highpass filtered respiration signal

All data were sampled at 512 Hz

**Step 2: Determine optimal stripe size by running Stripe_size_search**

E.g., for the first column of DATA matrix
[Stripe_out]=Stripe_size_search(DATA(:,1)',1,60*512,40,512,0,0,0);

Second argument points to the row index you want to process (here 1)

Third argument is the window size in # of samples (seconds x sampling rate)

Fourth argument is the window overlap in seconds

Fifth argument is the sampling rate here 512

The rest of the arguments should be set to 0 in this version
Note: Data are transposed because function wants channels as rows and columns as samples (i.e., it needs a row vector, not column vector).


**Step 3: Run the MDEA approach to obtain entropy vs. log (window length)**

E.g., [delta, DE, de]  = MDEA(DATA(:,1), median(Stripe_out), 1, 0.4, 0.8, 1);
You can use as stripe size the median of the output of  Stripe_size_search

**Step 4a: Determine the linear region in the entropy vs log (window length) from which the slope (and therefore delta) will be extracted from**

E.g., [linearStartIndex, linearEndIndex, deltas] = findLinearPortion_v2(DE, de, 0.05, DATA(:,1)./median(Stripe_out), median(Stripe_out), 0);

The third argument is a threshold controlling the sensitivity of determining a linear region.

**or Step 4b: Alternative option to recover linear region for estimating complexity scale delta**
E.g., [linearStartIndex, linearEndIndex, deltas] = findTwoLinearPortions(DE, de, 0.005, DATA(:,1)./median(Stripe_out), median(Stripe_out), 0);

This is used for the  ECG signals. Check also Fig. 8 (top right) in paper.

