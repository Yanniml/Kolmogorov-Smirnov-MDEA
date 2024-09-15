Step 1: Load S037.SH.L.sess6.4chans.mat
\newline
The matrix DATA contains 4 columns; 

1st column corresponds to an EEG signal

2nd column corresponds to an EKG signal

3rd column corresponds to an Respiratory signal

4th column corresponds to

Step 2: Determine optimal stripe size by running Stripe_size_search

E.g., for the first column of DATA matrix
[Stripe_out]=Stripe_size_search(DATA(:,1)',1,60*512,40,512,0,0,0);

Second argument points to the row index you want to process (here 1)

Third argument is the window size in # of samples

Fourth argument is the window overlap in seconds

Fifth argument is the sampling rate here 512

The rest of the arguments should be set to 0 in this version

Step 3: 

